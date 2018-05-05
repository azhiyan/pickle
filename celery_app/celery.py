# -*- coding: utf-8 -*-

"""

    Module :mod:``


    LICENSE: The End User license agreement is located at the entry level.

"""

# ----------- START: Native Imports ---------- #
from __future__ import absolute_import, unicode_literals

import ast
import simplejson as json
# ----------- END: Native Imports ---------- #

# ----------- START: Third Party Imports ---------- #
from celery import Celery
from celery import bootsteps
from kombu import Consumer, Exchange, Queue

from jsonschema import Draft4Validator
from jsonschema.exceptions import ValidationError
# ----------- END: Third Party Imports ---------- #

# ----------- START: In-App Imports ---------- #
from core.utils.environ import (
    get_sim_details,
    get_rabbitmq_details,
    get_queue_details,
    get_amqp_connection_str
)

from core.logger.file_logger import central_logger_api

from core.scheduler.scheduler import TaskScheduler

from .schema import DUMMY_SCHEMA, SCHEDULE_NEW_STRICT_SCHEMA, SEND_SMS_STRICT_SCHEMA

from core.db.model import (
    JobDetailsModel, TransSmsModel, UserModel
)

from core.backend.utils.core_utils import (
    AutoSession
)

from core.sms.client import SendSMS
# ----------- END: In-App Imports ---------- #


__all__ = [
    # All public symbols go here.
]


def byteify(input):
    if isinstance(input, dict):
        return {byteify(key): byteify(value)
                for key, value in input.iteritems()}
    elif isinstance(input, list):
        return [byteify(element) for element in input]
    elif isinstance(input, unicode):
        return input.encode('utf-8')
    else:
        return input


def validate_payload(payload, schema=DUMMY_SCHEMA):

    try:
        if not isinstance(payload, (str, unicode)):
            raise Exception('message should be of type String, Got {}'.format(type(payload)))

        payload = byteify(json.loads(payload))

        if not isinstance(payload, dict):
            raise TypeError('payload must be of type dict, Got'.format(type(payload)))

        _errors = [error.message for error in Draft4Validator(schema).iter_errors(payload)]

        if _errors:
            _msg = 'PayloadSchemaValidationError: {}'.format(_errors)
            raise ValidationError(_msg)

    except json.JSONDecodeError as error:
        _error = 'While receiving payload {}, Got error: {}'
        central_logger_api(data=payload, error=_error.format(payload, str(error)))

    except Exception as error:
        _error = 'While receiving payload {}, Got error: {}'
        central_logger_api(data=payload, error=_error.format(payload, str(error)))

    else:
        return payload

    return False


class GeneralConsumerHelper(object):

    all_queues = get_queue_details()

    def create_queue(self):

        rmq = get_rabbitmq_details()

        return Queue(
            name=self.queue_name,
            exchange=Exchange(rmq['exchange']),
            routing_key=self.queue_name,
            durable=self.durable
        )

    def create_consumer(self, queue, channel):

        return [
            Consumer(
                channel,
                queues=[queue],
                callbacks=[self.when_message_received],
                accept=['json']
            )
        ]


class SMSConsumer(bootsteps.ConsumerStep, GeneralConsumerHelper):

    def get_consumers(self, channel):

        self.sim_details = get_sim_details()

        self.queue_name, self.durable = self.__class__.all_queues['central_sms_queue']

        return self.create_consumer(self.create_queue(), channel)

    def when_message_received(self, payload, message):

        payload = validate_payload(payload, SEND_SMS_STRICT_SCHEMA)

        if payload:
            sms_client = SendSMS(self.sim_details['serial_port'])
            result, response_msg = sms_client.send(
                message=payload['message'],
                recipient=payload['number']
            )

            if not result:
                with AutoSession() as session:
                    user_data = UserModel.fetch_one(session, phone_no1=payload['number'])
                    TransSmsModel.insert(session, 
                        user_idn=user_data.user_idn, 
                        message=payload['message']
                    )

        message.ack()


class LoggerConsumer(bootsteps.ConsumerStep, GeneralConsumerHelper):

    def get_consumers(self, channel):

        self.queue_name, self.durable = self.__class__.all_queues['central_logger_queue']

        return self.create_consumer(self.create_queue(), channel)

    def when_message_received(self, payload, message):

        payload = validate_payload(payload)

        if payload:
            central_logger_api(data=payload)

        message.ack()



class SchedulerConsumer(bootsteps.ConsumerStep, GeneralConsumerHelper):

    def get_consumers(self, channel):

        #
        # Instanciate the Singleton TaskScheduler class.
        self.scheduler = TaskScheduler()

        #
        # Start the scheduler if it's not in running state.
        if not self.scheduler.is_scheduler_running:
            self.scheduler()

            self.job_syncer()

        self.queue_name, self.durable = self.__class__.all_queues['scheduler_queue']

        return self.create_consumer(self.create_queue(), channel)

    def job_syncer(self):

        scheduled_jobs = list()

        with AutoSession() as session:

            scheduled_jobs = JobDetailsModel.scheduled_jobs(
                session, data_as_dict=True
            )

        for each_job in scheduled_jobs:
            each_job['job_action'] = 'add'
            try:
                self.scheduler.process_job(payload=each_job)
            except:
                # TODO: revisit
                pass

    def when_message_received(self, payload, message):

        payload = validate_payload(payload, SCHEDULE_NEW_STRICT_SCHEMA)

        if payload:
            result = self.scheduler.process_job(payload)

        message.ack()


con_str = get_amqp_connection_str()

application =  Celery(
    'celery_app',
    broker=con_str,
    backend=con_str,
    include=[]
)

application.steps['consumer'].add(SMSConsumer)
application.steps['consumer'].add(LoggerConsumer)
application.steps['consumer'].add(SchedulerConsumer)

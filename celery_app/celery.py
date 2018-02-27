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
    get_rabbitmq_details,
    get_queue_details,
    get_amqp_connection_str
)

from core.logger.file_logger import central_logger_api

from core.scheduler.scheduler import TaskScheduler

from .schema import SCHEDULE_NEW_STRICT_SCHEMA
# ----------- END: In-App Imports ---------- #

__all__ = [
    # All public symbols go here.
]


RMQ_EXCHANGE_NAME = 'test_exchange'


class GeneralConsumerHelper(object):

    all_queues = get_queue_details()

    def is_queue_durable(self):

        return True if self.durable == 'durable_true' else False

    def create_queue(self):

        return Queue(
            name=self.queue_name,
            exchange=Exchange(RMQ_EXCHANGE_NAME),
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

        self.queue_name, self.durable = self.__class__.all_queues['central_sms_queue']

        self.durable = self.is_queue_durable()

        return self.create_consumer(self.create_queue(), channel)

    def when_message_received(self, body, message):
        print 'Received message: {0!r}'.format(body)
        message.ack()


class LoggerConsumer(bootsteps.ConsumerStep, GeneralConsumerHelper):

    def get_consumers(self, channel):

        self.queue_name, self.durable = self.__class__.all_queues['central_logger_queue']

        self.durable = self.is_queue_durable()

        return self.create_consumer(self.create_queue(), channel)

    def when_message_received(self, body, message):
        try:
            body = json.loads(body)
        except Exception as error:
            central_logger_api(
                data=body,
                error='{}: {}'.format(error.__class__.__name__, str(error))
            )
        else:
            central_logger_api(data=body)

        message.ack()


DUMMY_SCHEMA = {
    'type': 'object',
    'additionalProperties': True,
    'properties': dict()
}


def validate_payload(payload, schema=DUMMY_SCHEMA):

    try:
        if not isinstance(payload, (str, unicode)):
            raise Exception('message should be of type String, Got {}'.format(type(payload)))

        #
        # ``ast.literal_eval`` converts a unicode object dict to python dict
        # with keys and values as ``str``.
        #
        # >>> ast.literal_eval(u"{u'city': u'coimbatore', u'name': u'Plant'}")
        # {u'city': u'coimbatore', u'name': u'Plant'}
        payload = ast.literal_eval(payload)

        if not isinstance(payload, dict):
            raise TypeError('payload must be of type dict, Got'.format(type(payload)))

        _errors = [error.message for error in Draft4Validator(schema).iter_errors(payload)]

        if _errors:
            _msg = 'ValidationError: {}'.format(_errors)
            print _msg
            raise ValidationError(_msg)

    except json.JSONDecodeError as error:
        print 'CRITICAL ERROR: {}'.format(str(error))

    except Exception as error:
        print 'CRITICAL ERROR: {}'.format(str(error))

    else:
        return payload

    return False


class SchedulerConsumer(bootsteps.ConsumerStep, GeneralConsumerHelper):

    def get_consumers(self, channel):

        self.queue_name, self.durable = self.__class__.all_queues['scheduler_queue']

        self.durable = self.is_queue_durable()

        return self.create_consumer(self.create_queue(), channel)

    def when_message_received(self, payload, message):

        payload = validate_payload(payload, SCHEDULE_NEW_STRICT_SCHEMA)

        if payload:
            #
            # Instanciate the Singleton TaskScheduler class.
            scheduler = TaskScheduler()

            #
            # Start the scheduler if it's not in running state.
            if not scheduler.is_scheduler_running:
                scheduler()

            scheduler.process_job(payload)

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

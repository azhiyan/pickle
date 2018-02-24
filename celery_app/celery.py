# -*- coding: utf-8 -*-

"""

    Module :mod:``


    LICENSE: The End User license agreement is located at the entry level.

"""

# ----------- START: Native Imports ---------- #
from __future__ import absolute_import, unicode_literals
# ----------- END: Native Imports ---------- #

# ----------- START: Third Party Imports ---------- #
from celery import Celery
from celery import bootsteps
from kombu import Consumer, Exchange, Queue
# ----------- END: Third Party Imports ---------- #

# ----------- START: In-App Imports ---------- #
from core.utils.environ import (
    get_rabbitmq_details,
    get_queue_details
)

from core.logger.file_logger import central_logger_api
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
                callbacks=[self.on_publish],
                accept=['json']
            )
        ]


class SMSConsumer(bootsteps.ConsumerStep, GeneralConsumerHelper):

    def get_consumers(self, channel):

        self.queue_name, self.durable = self.__class__.all_queues['central_sms_queue']

        self.durable = self.is_queue_durable()

        return self.create_consumer(self.create_queue(), channel)

    def on_publish(self, body, message):
        print 'Received message: {0!r}'.format(body)
        message.ack()


class LoggerConsumer(bootsteps.ConsumerStep, GeneralConsumerHelper):

    def get_consumers(self, channel):

        self.queue_name, self.durable = self.__class__.all_queues['central_logger_queue']

        self.durable = self.is_queue_durable()

        return self.create_consumer(self.create_queue(), channel)

    def on_publish(self, body, message):
        central_logger_api(body)
        message.ack()


class SchedulerConsumer(bootsteps.ConsumerStep, GeneralConsumerHelper):

    def get_consumers(self, channel):

        self.queue_name, self.durable = self.__class__.all_queues['scheduler_queue']

        self.durable = self.is_queue_durable()

        return self.create_consumer(self.create_queue(), channel)

    def on_publish(self, body, message):
        print 'Received message: {0!r}'.format(body)
        message.ack()


application =  Celery(
    'celery_app',
    broker='amqp://',
    backend='amqp://',
    include=['celery_app.tasks']
)

application.steps['consumer'].add(SMSConsumer)
application.steps['consumer'].add(LoggerConsumer)
application.steps['consumer'].add(SchedulerConsumer)

# -*- coding: utf-8 -*-

"""

    Module :mod:``


    LICENSE: The End User license agreement is located at the entry level.

"""

# ----------- START: Native Imports ---------- #
# ----------- END: Native Imports ---------- #

# ----------- START: Third Party Imports ---------- #
# ----------- END: Third Party Imports ---------- #

# ----------- START: In-App Imports ---------- #
# ----------- END: In-App Imports ---------- #

__all__ = [
    # All public symbols go here.
]


SCHEDULE_NEW_STRICT_SCHEMA = {
    'type': 'object',
    'additionalProperties': False,

    'properties': {

        'schedule_type': {
            'type': 'string',
            'enum': ['onetime', 'daily', 'weekly']
        },
        'recurrence': {
            'type': 'integer',
            'minimum': 0,
            'maximum': 30,
            'exclusiveMaximum': False
        },
        'start_date': {

            'type': 'object',

            'properties': {

                'date': {
                    'type': 'string',
                    'pattern': '^[0-9]{4}-[0-9]{,2}-[0-9]{,2}$'
                },
                'hour': {
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 23,
                    'exclusiveMaximum': False
                 },
                'minute': {
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 59,
                    'exclusiveMaximum': False
                },
                'second': {
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 59,
                    'exclusiveMaximum': False
                }
            },
            'required': ['date', 'hour', 'minute', 'second']

        },
        'day_of_week': {
            'type': 'string'
        },
        'job_action': {
            'type': 'string',
            'enum': ['add', 'update', 'remove']
        },
        'emit_event': {
            'type': 'string',
            'enum': []
        }
    },

    'required': ['schedule_type', 'job_action', 'start_date']
}

#!/usr/bin/env python
import unittest

from deferred import Deferred


class AsyncObject(object):
    def __init__(self):
        self.d = Deferred()

    def start(self):
        return self.d

    def close(self, value):
        self.d.resolve(value)


class TestDeferred(unittest.TestCase):
    def setUp(self):
        def on_resolve(*args, **kwargs):
            self.resolve_ran = True
            self.assertEqual(args, ['resolve'])
            self.assertEqual(kwargs, {'finish_type': 'resolve'})

        def on_error(*args, **kwargs):
            self.error_ran = True
            self.assertEqual(args, ['error'])
            self.assertEqual(kwargs, {'finish_type': 'error'})

        def on_always(*args, **kwargs):
            self.always_ran = True
            self.assertEqual(len(args), 1)
            self.assertIn(args[0], ('resolve', 'error'))
            self.assertEqual(len(kwargs), 1)
            self.assertIn(kwargs['finish_type'], ('resolve', 'error'))

        self.d = Deferred()
        self.d.then(on_resolve, error=on_error, always=on_always)
        self.resolve_ran = False
        self.error_ran = False
        self.always_ran = False

    def test_create(self):
        self.assertIsNotNone(self.d)

    def test_resolve(self):
        self.d.resolve('resolve', finish_type='resolve')
        self.assertTrue(self.d.finished)
        self.assertTrue(self.d.is_resolved)
        self.assertTrue(self.resolve_ran)
        self.assertFalse(self.error_ran)
        self.assertTrue(self.always_ran)

    def test_error(self):
        self.d.reject('error', finish_type='error')
        self.assertTrue(self.d.finished)
        self.assertFalse(self.d.is_resolved)
        self.assertFalse(self.resolve_ran)
        self.assertTrue(self.error_ran)
        self.assertTrue(self.always_ran)


if __name__ == '__main__':
    unittest.main()

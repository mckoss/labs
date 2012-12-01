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
            self.assertEqual(args, ['resolve'])
            self.assertEqual(kwargs, {'finish_type': 'resolve'})

        self.d = Deferred()
        self.d.then(on_resolve)

    def test_create(self):
        self.assertIsNotNone(self.d)

    def test_resolve(self):
        self.d.resolve('resolve', finish_type='resolve')
        self.assertTrue(self.d.finished)
        self.assertTrue(self.d.is_resolved)


if __name__ == '__main__':
    unittest.main()

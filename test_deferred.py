#!/usr/bin/env python
import unittest

from deferred import Deferred, When


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
            return 'ran_resolved'

        def on_error(*args, **kwargs):
            self.error_ran = True
            self.assertEqual(args, ['error'])
            self.assertEqual(kwargs, {'finish_type': 'error'})
            return 'ran_error'

        def on_always(*args, **kwargs):
            self.always_ran = True
            self.assertEqual(len(args), 1)
            self.assertIn(args[0], ('resolve', 'error'))
            self.assertEqual(len(kwargs), 1)
            self.assertIn(kwargs['finish_type'], ('resolve', 'error'))
            return 'ran_always'

        def on_after(*args, **kwargs):
            self.after_ran = True
            self.assertEqual(len(args), 1)
            self.assertEqual(len(kwargs), 0)
            self.assertIn(args[0], ('ran_resolved', 'ran_error'))

        self.d = Deferred()
        self.d\
            .then(on_resolve, error=on_error, always=on_always)\
            .then(on_after)
        self.resolve_ran = False
        self.error_ran = False
        self.always_ran = False
        self.after_ran = False

    def test_create(self):
        self.assertIsNotNone(self.d)

    def test_resolve(self):
        self.d.resolve('resolve', finish_type='resolve')
        self.assertTrue(self.d.finished)
        self.assertTrue(self.d.is_resolved)
        self.assertTrue(self.resolve_ran)
        self.assertFalse(self.error_ran)
        self.assertTrue(self.always_ran)
        self.assertTrue(self.after_ran)

    def test_error(self):
        self.d.reject('error', finish_type='error')
        self.assertTrue(self.d.finished)
        self.assertFalse(self.d.is_resolved)
        self.assertFalse(self.resolve_ran)
        self.assertTrue(self.error_ran)
        self.assertTrue(self.always_ran)
        self.assertTrue(self.after_ran)


class TestChain(unittest.TestCase):
    def test_plus(self):
        result = []

        def get_value():
            return 42

        def got_value(value):
            self.assertEqual(value, 42)
            return value * 2

        def got_value2(value):
            self.assertEqual(value, 84)
            result.append(value)

        d = Deferred()
        d.then(get_value)\
            .then(got_value)\
            .then(got_value2)

        self.assertEqual(result, [])
        d.resolve()
        self.assertEqual(result, [84])


class TestWhen(unittest.TestCase):
    def test_when(self):
        result = []

        def on_done(value):
            result.append(value)

        def on_all(*args):
            result.extend(args)
            return(sum(args))

        d1 = Deferred()
        d2 = Deferred()
        d3 = When(d1, d2)

        d1.then(on_done)
        d2.then(on_done)
        d3.then(on_all)\
            .then(on_done)

        self.assertEqual(result, [])

        d2.resolve(2)
        self.assertEqual(result, [2])

        d1.resolve(1)
        self.assertEqual(result, [2, 1, 2, 3, 1])


if __name__ == '__main__':
    unittest.main()

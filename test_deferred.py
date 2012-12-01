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


class TestDeffered(unittest.TestCase):
    def test_create(self):
        x = Deferred()
        self.assertIsNotNone(x)

    def test_resolve(self):
        returns = []
        def on_resolve(value):
            self.assertEqual(value, 'resolve')
            returns.append(value)

        d = Deferred()
        d.then(on_resolve)
        d.resolve('resolve')
        self.assertEqual(returns[0], 'resolve')


if __name__ == '__main__':
    unittest.main()

#!/usr/bin/env python
import unittest

from amb import AmbRun


class TestAmb(unittest.TestCase):
    def test_basic(self):
        def test(amb, fail):
            x = amb()
            if not x:
                fail()
            return x

        ar = AmbRun(test)
        result = ar.run()
        self.assertEqual(result, True)


if __name__ == '__main__':
    unittest.main()

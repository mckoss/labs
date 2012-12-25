#!/usr/bin/env python
import unittest

from amb import Runner, Fail


class TestAmb(unittest.TestCase):
    def test_basic(self):
        def test(amb):
            x = amb()
            if not x:
                raise Fail
            return x

        ar = Runner(test)
        result = ar.run()
        self.assertEqual(result, True)


if __name__ == '__main__':
    unittest.main()

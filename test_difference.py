#!/usr/bin/env python
import unittest

from difference import DiffState, find_difference_set


class TestDiffSet(unittest.TestCase):
    def test_create(self):
        d = DiffState(12)


class DifferenceSet(unittest.TestCase):
    def test_known(self):
        dsets = [[0, 1, 3],
                 [0, 1, 3, 9],
                 [0, 1, 4, 14, 16],
                 [0, 1, 3, 8, 12, 18],
                 [0, 1, 3, 13, 32, 36, 43, 52],
                 [0, 1, 3, 7, 15, 31, 36, 54, 63],
                 [0, 1, 3, 9, 27, 49, 56, 61, 77, 81],
                 ]

        for s in dsets:
            self.assertEqual(find_difference_set(len(s)), s)


if __name__ == '__main__':
    unittest.main()

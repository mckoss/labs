#!/usr/bin/env python
import unittest

from difference import DiffState, find_difference_set, sieve


class TestSieve(unittest.TestCase):
    def test_values(self):
        pp = sieve(100, prime_power=True)
        prefix = [2, 3, 4, 5, 7, 8, 9, 11]
        self.assertEqual(pp[:len(prefix)], prefix)

class TestDiffSet(unittest.TestCase):
    def test_create(self):
        d = DiffState(3)
        self.assertEqual(d.current, [0, 1])
        self.assertEqual(d.end, [0, 2])
        self.assertEqual(d.diff_map, [True, True, False, False])
        self.assertFalse(d.push(2))
        self.assertEqual(d.current, [0, 1])
        self.assertEqual(d.diff_map, [True, True, False, False])
        self.assertTrue(d.push(3))
        self.assertEqual(d.current, [0, 1, 3])
        self.assertEqual(d.diff_map, [True, True, True, True])


class DifferenceSet(unittest.TestCase):
    def setUp(self):
        self.dsets = [[0, 1, 3],
                      [0, 1, 3, 9],
                      [0, 1, 4, 14, 16],
                      [0, 1, 3, 8, 12, 18],
                      [0, 1, 3, 13, 32, 36, 43, 52],
                      [0, 1, 3, 7, 15, 31, 36, 54, 63],
                      [0, 1, 3, 9, 27, 49, 56, 61, 77, 81],
                      ]

    def test_find(self):
        for s in self.dsets:
            self.assertEqual(find_difference_set(len(s)), s)

    def test_ds(self):
        for s in self.dsets:
            k = len(s)
            ds = DiffState(k)
            ds.search()
            self.assertEqual(s, ds.current)


if __name__ == '__main__':
    unittest.main()

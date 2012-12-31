#!/usr/bin/env python
import unittest

from search import SearchSpace


class TestSearch(unittest.TestCase):
    def test_queens(self):
        q = Queens(8)
        self.assertEqual(q.run(),
                         [(0, 0), (1, 4), (2, 7), (3, 5), (4, 2), (5, 6), (6, 1), (7, 3)])


class Queens(SearchSpace):
    def __init__(self, size=8):
        super(Queens, self).__init__()
        self.size = size

    def check(self, place):
        def unique(n, s):
            if n in s:
                return False
            s.add(n)
            return True

        return unique(place[0], self.rows) and \
            unique(place[1], self.cols) and \
            unique(place[0] - place[1], self.diag1) and \
            unique(place[0] + place[1], self.diag2)

    def search(self):
        self.rows = set()
        self.cols = set()
        self.diag1 = set()
        self.diag2 = set()

        queens = []
        for i in range(self.size):
            place = (i, self.choose(self.size))
            if not self.check(place):
                return None
            queens.append(place)

        return queens


if __name__ == '__main__':
    unittest.main()

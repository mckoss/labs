#!/usr/bin/env python
import unittest

from search import SearchProgress, SearchSpace


class TestSearch(unittest.TestCase):
    def setUp(self):
        self.tests = [(1, [(0, 0)]),
                      (2, None),
                      (3, None),
                      (4, [(0, 1), (1, 3), (2, 0), (3, 2)]),
                      (5, [(0, 0), (1, 2), (2, 4), (3, 1), (4, 3)]),
                      (6, [(0, 1), (1, 3), (2, 5), (3, 0), (4, 2), (5, 4)]),
                      (7, [(0, 0), (1, 2), (2, 4), (3, 6), (4, 1), (5, 3), (6, 5)]),
                      (8, [(0, 0), (1, 4), (2, 7), (3, 5), (4, 2), (5, 6), (6, 1), (7, 3)]),
                      (10, [(0, 0), (1, 2), (2, 5), (3, 7), (4, 9), (5, 4), (6, 8), (7, 1), (8, 3), (9, 6)]),
                      (18, [(0, 0), (1, 2), (2, 4), (3, 1), (4, 7), (5, 14), (6, 11), (7, 15), (8, 12), (9, 16),
                            (10, 5), (11, 17), (12, 6), (13, 3), (14, 10), (15, 8), (16, 13), (17, 9)]),
                      (20, [(0, 0), (1, 2), (2, 4), (3, 1), (4, 3), (5, 12), (6, 14), (7, 11), (8, 17), (9, 19),
                            (10, 16), (11, 8), (12, 15), (13, 18), (14, 7), (15, 9), (16, 6), (17, 13), (18, 5),
                            (19, 10)]),
                      ]

    def test_queens(self):
        for test in self.tests[:9]:
            q = Queens(test[0])
            x = q.search()
            self.assertEqual(x, test[1])

    def test_backtrack_queens(self):
        for test in self.tests:
            q = BacktrackQueens(test[0])
            self.assertEqual(q.search(), test[1])


class Queens(SearchProgress, SearchSpace):
    def __init__(self, size=8):
        super(Queens, self).__init__()
        self.size = size

    def restart(self):
        super(Queens, self).restart()
        self.rows = set()
        self.cols = set()
        self.diag1 = set()
        self.diag2 = set()
        self.queens = []

    def check(self, place):
        if place[0] in self.rows or \
                place[1] in self.cols or \
                (place[0] - place[1]) in self.diag1 or  \
                (place[0] + place[1]) in self.diag2:
            return False

        self.rows.add(place[0])
        self.cols.add(place[1])
        self.diag1.add(place[0] - place[1])
        self.diag2.add(place[0] + place[1])
        return True

    def step(self):
        super(Queens, self).step()
        place = (self.depth, self.choose(self.size))
        if not self.check(place):
            return
        self.queens.append(place)
        self.accept()
        if self.depth == self.size:
            return self.queens

    def __str__(self):
        """ Represent as a board. """
        rows = []
        for place in self.queens:
            rows.append(' '.join(['X' if col == place[1] else '.' for col in range(self.size)]))
        return '\n'.join(rows)


class BacktrackQueens(Queens):
    """ Same a Queens - but can backtrack rather than restart. """
    def backtrack(self, choice):
        place = self.queens.pop()
        self.rows.remove(place[0])
        self.cols.remove(place[1])
        self.diag1.remove(place[0] - place[1])
        self.diag2.remove(place[0] + place[1])


if __name__ == '__main__':
    unittest.main()

#!/usr/bin/env python
import unittest

from amb import Runner, Fail, MonteCarloRunner


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

    def test_monte_carlo(self):
        def test(amb):
            x = amb()
            if not x:
                raise Fail
            return x

        ar = MonteCarloRunner(test)
        result = ar.run()
        self.assertEqual(result, True)

    def test_args(self):
        def test(amb, k):
            x = amb()
            if not x:
                raise Fail
            return k

        ar = Runner(test)
        result = ar.run(123)
        self.assertEqual(result, 123)

    def test_eight(self):
        ar = Runner(eight_queens)
        result = ar.run()
        self.assertEqual(result,
                         [[0, 0], [1, 4], [2, 7], [3, 5], [4, 2], [5, 6], [6, 1], [7, 3]])

    def test_eight_monte(self):
        ar = MonteCarloRunner(eight_queens)
        result = ar.run()
        self.assertEqual(len(result), 8)


def eight_queens(amb):
    rows = set()
    cols = set()
    diag1 = set()
    diag2 = set()

    def unique(n, s):
        if n in s:
            raise Fail
        s.add(n)

    def check(row, col):
        unique(row, rows)
        unique(col, cols)
        unique(row - col, diag1)
        unique(row + col, diag2)

    queens = []

    for i in range(8):
        place = [i, amb(8)]
        check(place[0], place[1])
        queens.append(place)

    return queens


if __name__ == '__main__':
    unittest.main()

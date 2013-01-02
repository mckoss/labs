#!/usr/bin/env python
import math
import argparse
from itertools import combinations

from search import SearchSpace, SearchProgress


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", default=3, type=int,
                        help="Starting point for size (k) of difference set search.")
    parser.add_argument("--end", default=103, type=int,
                        help="Ending point for size of difference set search.")
    parser.add_argument("--all", action="store_true",
                        help="Find all difference sets (does not stop a first solution.")
    parser.add_argument("prefix", default=[0, 1], type=int, nargs='*',
                        help="Search all solutions that have given prefix.")
    args = parser.parse_args()

    primes = sieve(args.end + 1, prime_power=True)

    for k in range(args.start, args.end + 1):
        print "\nDifference set (k = %d, m = %d)" % (k, k * (k -1) + 1)

        if k > 2 and k - 1 not in primes:
            print "Theorem: set k = %d does not exist (since %d is not a prime power)." % (k, k - 1)
            continue

        ds = DiffState(k, start=args.prefix, end=[1])
        unique_solutions = []
        while True:
            ds.search()
            if ds.is_solved():
                for soln in unique_solutions:
                    if ds.is_inverse(soln):
                        # print "%s same as %r" % (ds, soln)
                        break
                else:
                    print ds
                    unique_solutions.append(list(ds.current))
            if not args.all or ds.is_finished():
                break


class DiffState(SearchProgress, SearchSpace):
    def __init__(self, k, **kwargs):
        super(DiffState, self).__init__(**kwargs)
        self.k = k
        self.m = k * (k - 1) + 1
        self.diff_map = [True] + [False] * (self.m / 2)
        self.low = -1
        self.current = []

    def __str__(self):
        return str(self.current)

    def step(self):
        super(DiffState, self).step()
        min = self.low + 1
        if len(self.current) > 0:
            min += self.current[-1]
        candidate = self.choose(min=min,
                                limit=self.m - self.low - \
                                    (self.low + 1) * (self.k - len(self.current) - 1))
        if self.is_feasible(candidate):
            self.accept()
            if self.is_solved():
                return self.current

    def is_solved(self):
        return len(self.current) == self.k

    def is_feasible(self, a):
        for b in self.current:
            d = a - b
            if d > self.m / 2:
                d = self.m - d
            if not self.diff_map[d]:
                self.diff_map[d] = True
                continue
            # Unwind differences
            for c in self.current:
                if c == b:
                    return False
                d = a - c
                if d > self.m / 2:
                    d = self.m - d
                self.diff_map[d] = False

        self.current.append(a)

        # Update highest consecutive difference from zero
        while self.low <= self.m / 2 - 1 and self.diff_map[self.low + 1]:
            self.low += 1

        return True

    def backtrack(self, a):
        a = self.current.pop()
        for b in self.current:
            d = a - b
            if d > self.m / 2:
                d = self.m - d
            self.diff_map[d] = False

            # Update highest consecutive difference from zero
            if d <= self.low:
                self.low = d - 1

    def is_inverse(self, ds):
        for i in range(2, self.k):
            if ds[i] != self.m - self.current[self.k - i + 1] + 1:
                return False
        return True


def sieve(n, prime_power=False):
    """ Return all primes less than or equal to n. """
    sqrt = int(n ** 0.5)
    comp = set()
    primes = []

    for i in range(2, n + 1):
        if i in comp:
            continue
        primes.append(i);
        if i > sqrt:
            continue
        for j in range(i * i, n + 1, i):
            comp.add(j)

    if prime_power:
        for i in range(2, sqrt + 1):
            power = i * i
            while power <= n:
                primes.append(power)
                power *= i

        primes.sort()

    return primes


if __name__ == '__main__':
    main()

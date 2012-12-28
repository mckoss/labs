#!/usr/bin/env python
import math
import argparse
from itertools import combinations

from progress import Progress
from amb import Runner, Fail, MonteCarloRunner


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", default=2, type=int,
                        help="Starting point for size (k) of difference set search.")
    parser.add_argument("--end", default=103, type=int,
                        help="Ending point for size of difference set search.")
    parser.add_argument("--all",
                        help="Find all difference sets (does not stop a first solution.")
    parser.add_argument("prefix", default=[0, 1], type=int, nargs='*',
                        help="Search all solutions that have given prefix.")
    args = parser.parse_args()

    primes = sieve(args.end + 1, prime_power=True)

    p = Progress(name="Searching")
    for k in range(args.start, args.end + 1):
        print "\nDifference set (k = %d, m = %d)" % (k, k * (k -1) + 1)

        if k > 2 and k - 1 not in primes:
            print "Theorem: set k = %d does not exist (since %d is not a prime power)." % (k, k - 1)
            continue

        ds = DiffState(k, args.prefix)
        ds.search()
        print ds
        ds.progress.report(final=True)


class DiffState(object):
    def __init__(self, k, prefix=None):
        self.k = k
        self.m = k * (k - 1) + 1
        if prefix is None:
            prefix = [0, 1]
        self.current = []
        self.diff_map = [True] + [False] * (self.m / 2)
        self.low = 0

        self.candidate = None
        for a in prefix:
            if not self.push(a):
                print "Illegal prefix: %r" % prefix
                self.candidate = a
                print "Starting from: %r %d" % (self.current, self.candidate)
                break

        if self.candidate is None:
            self.candidate = self.current[-1] + self.low + 1

        self.min_length = len(self.current)

        self.progress = Progress()

    def __str__(self):
        return str(self.current)

    def search(self):
        while True:
            self.progress.report(self)

            size = len(self.current)
            if size == self.k or size < self.min_length:
                return

            if self.candidate + (self.low + 1) * (self.k - len(self.current) - 1) >= self.m - self.low:
                self.candidate = self.pop() + 1
                continue

            if self.push(self.candidate):
                if self.is_solved():
                    return
                self.candidate += self.low + 1
                continue

            self.candidate += 1

    def is_solved(self):
        return len(self.current) == self.k

    def push(self, a):
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

    def pop(self):
        a = self.current.pop()
        for b in self.current:
            d = a - b
            if d > self.m / 2:
                d = self.m - d
            self.diff_map[d] = False

            # Update highest consecutive difference from zero
            if d <= self.low:
                self.low = d - 1

        return a


def sieve(n, prime_power=False):
    """ Return all primes less than or equal to n. """
    sqrt = int(n ** 0.5)
    s = set()
    primes = []

    for i in [2] + range(3, n + 1):
        if i in s:
            continue
        primes.append(i);
        if i > sqrt:
            continue
        for j in range(i * i, n + 1, i):
            s.add(j)
        if prime_power:
            power = i * i
            while power <= n:
                s.remove(power)
                power *= i

    return primes


if __name__ == '__main__':
    main()

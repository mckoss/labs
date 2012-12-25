#!/usr/bin/env python
import math
from itertools import combinations

from progress import Progress

MAX_SET = 103

def main():
    primes = sieve(MAX_SET, prime_power=True)

    p = Progress(name="Searching")
    for k in range(2, MAX_SET):
        print "\nDifference set (v = %d, k = %d, 1)" % (k * (k -1) + 1, k)

        if k - 1 not in primes:
            print "Theorem: set k = %d does not exists (since %d is not a prime power)." % (k, k - 1)
            continue

        ds = DiffState(k)
        ds.search()
        print ds
        ds.progress.report(final=True)

def find_difference_set(k):
    m = k * (k - 1) + 1
    s = [0, 1] + [0] * (k - 2)
    stack = [set()]
    next = 1

    progress = Progress()

    def test_number(n):
        progress.report((k, s[:next + 1]))

        d = stack[-1].copy()
        for i in range(next):
            if (n - s[i]) % m in d or (s[i] - n) % m in d:
                return None
            d.add((n - s[i]) % m)
            d.add((s[i] - n) % m)
        return d

    while True:
        d = test_number(s[next])
        if d is not None:
            if next == k - 1:
                progress.report(final=True)
                return s
            stack.append(d)
            s[next + 1] = s[next] + 2
            next += 1
            continue
        s[next] += 1
        if s[next] + 2 * (k - next - 1) >= m:
            s[next - 1] += 1
            stack.pop()
            next -= 1
            if next == 1:
                progress.report(final=True)
                return ()


class DiffState(object):
    def __init__(self, k, start=None, end=None):
        self.k = k
        self.m = k * (k - 1) + 1
        if start is None:
            start = [0, 1]
        self.current = []
        self.diff_map = [True] + [False] * (self.m / 2)
        self.low = 0

        for a in start[:-1]:
            if not self.push(a):
                raise ValueError("Illegal start.")
        self.candidate = start[-1]
        self.min_length = len(self.current)

        self.progress = Progress()

    def __str__(self):
        return str(self.current)

    def search(self):
        while True:
            self.progress.report(self)

            soln = len(self.current)
            if soln == self.k or soln < self.min_length:
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


def slow_find_difference_set(k):
    """ This one is concise, and expressive - but SLOW """
    if k in (7,):
        return ()
    m = k * (k - 1) + 1
    for s in combinations(range(m), k):
        # WLG - there exists a set begining 0, 1, ...
        if s[0] != 0 or s[1] != 1:
            break
        d = set()
        for i, j in combinations(range(k), 2):
            (a, b) = (s[i], s[j])
            if (a - b) % m in d or (b - a) % m in d:
                break
            d.add((a - b) % m)
            d.add((b - a) % m)
        else:
            return s
    return ()


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

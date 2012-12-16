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
            print "Theorom: set k = %d does not exists (since %d is not a prime power)." % (k, k - 1)

        ds = find_difference_set(k)
        print ds

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
        for j in range(i * i, n + 1, 2 * i):
            s.add(j)
        if prime_power:
            power = i * i
            while power <= n:
                s.remove(power)
                power *= i

    return primes


if __name__ == '__main__':
    main()

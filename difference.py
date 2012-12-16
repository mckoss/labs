#!/usr/bin/env python
import math
from itertools import combinations

from progress import Progress

MAX_SET = 103

def main():
    primes = sieve(MAX_SET)

    p = Progress(name="Searching")
    for k in range(2, MAX_SET):
        print "Difference set (%d, %d, 1)" % (k * (k -1) + 1, k)

        if not is_power_of(k - 1, primes):
            print "Theorom: set k = %d does not exists (since %d is not a prime power)." % (k, k - 1)

        if k in (7, 11):
            print "These is no cyclic difference set with k = %d." % k
            continue

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


def sieve(n):
    """ Return all primes less than or equal to n. """
    sqrt = int(n ** 0.5)
    s = set()
    primes = [2]

    for i in range(3, n + 1, 2):
        if i in s:
            continue
        primes.append(i);
        if i > sqrt:
            continue
        for j in range(i * i, n + 1, 2 * i):
            s.add(j)

    return primes


def is_power_of(n, primes):
    """ Return true iff n is a prime power of one of the given primes. """
    log_n = math.log(n)
    for prime in primes:
        root = int(log_n / math.log(prime))
        if prime ** root == n or prime ** (root + 1) == n:
            return True
    return False


if __name__ == '__main__':
    main()

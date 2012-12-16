#!/usr/bin/env python
from itertools import combinations

from progress import Progress

def main():
    p = Progress(name="Searching")
    while True:
        p.report()
    for k in range(98, 103):
        print "Difference set (%d, %d, 1)" % (k * (k -1) + 1, k)

        ds = find_difference_set(k)
        print ds

def find_difference_set(k):
    m = k * (k - 1) + 1
    s = [0, 1] + [0] * (k - 2)
    stack = [set()]
    next = 1

    progress = Progress()

    def test_number(n):
        progress.report()

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
                return s
            stack.append(d)
            s[next + 1] = s[next] + 2
            next += 1
            continue
        s[next] += 1
        if s[next] >= m:
            s[next - 1] += 1
            stack.pop()
            next -= 1
            if next == 1:
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


if __name__ == '__main__':
    main()

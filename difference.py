#!/usr/bin/env python
from itertools import combinations

def main():
    for k in range(2, 20):
        print "Difference set (%d, %d, 1)" % (k * (k -1) + 1, k)

        ds = find_difference_set(k)
        print ds

def find_difference_set(k):
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

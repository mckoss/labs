#!/usr/bin/env python
"""
ctuple - Tuples that are ordered by count, with a given maximum from Zn.

Usage:

"""

def main():
    size = int(raw_input("Tuple size: "))
    max = int(raw_input("Max values: "))
    c = CTuple(size, max)
    i = 0
    for c in CTuple(size, max):
        i += 1
        print "%4d. %s" % (i, c)


class CTuple(object):
    """
    Implements a tuple (iterator) ordered by sum of digits order from Zn.

    >>> c = CTuple(4, 2)
    >>> c
    (0, 0, 0, 0)[2]
    >>> c.incr()
    >>> c
    (0, 0, 0, 1)[2]
    >>> c.incr()
    >>> c
    (0, 0, 1, 0)[2]
    """
    def __init__(self, size, max):
        self.size = size
        self.max = max
        self.tuple = [0] * size
        self.count = 0

    def __iter__(self):
        return self

    def __repr__(self):
        return '(' + ', '.join([str(x) for x in self.tuple]) + ')[%d]' % self.max

    def next(self):
        return self.incr()

    def incr(self):
        # Move lsd up to next allowed increment digit (< max)
        lsd = self.lsd()
        carry = self.carry(lsd - 1)
        if carry == -1:
            if self.count == (self.max - 1) * self.size:
                raise StopIteration
            self.count += 1
            self.tuple = [0] * self.size
            self.distribute(self.count)
            return self

        self.tuple[carry] += 1
        self.tuple[lsd] -= 1

        c = 0
        for i in range(carry + 1, self.size):
            c += self.tuple[i]
            self.tuple[i] = 0
        self.distribute(c)
        return self

    def distribute(self, c):
        i = self.size - 1
        while c > 0:
            d = min(c, self.max - 1)
            self.tuple[i] = d
            c -= d
            i -= 1

    def lsd(self):
        """ Return position of least significant digit (right most). """
        for i in range(self.size -1 , -1, -1):
            if self.tuple[i] != 0:
                return i
        return 0

    def carry(self, start):
        for i in range(start, -1, -1):
            if self.tuple[i] < self.max - 1:
                return i
        return -1


if __name__ == '__main__':
    main()

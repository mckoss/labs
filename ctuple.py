#!/usr/bin/env python
"""
ctuple - Tuples that are ordered by count, with a given maximum from Zn.

Usage:

"""

def main():
    size = int(raw_input("Tuple size: "))
    max = int(raw_input("Max values: "))
    c = CTuple(size, max)
    for c in CTuple(size, max):
        print c

class CTuple(object):
    def __init__(self, size, max):
        self.value = [0] * size

    def __iter__(self):
        return self

    def __repr__(self):
        return '(' + ', '.join([str(x) for x in self.value]) + ')'

    def next(self):
        return self


if __name__ == '__main__':
    main()

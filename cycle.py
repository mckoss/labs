#!/usr/bin/env python

from pprint import pprint

DEBUG = False

def cycle(a):
    """
    Return if the relative indexes of a form a cycle over the whole array.

    >>> cycle([])
    True
    >>> cycle([0])
    True
    >>> cycle([1])
    True
    >>> cycle([1, 1, 1])
    True
    >>> cycle([1, 2, 1])
    False
    >>> cycle([300, -20, 100])
    False
    >>> cycle([301, -302, 301])
    True
    """
    n = len(a)
    if n == 0:
        return True
    fast = 0
    slow = 0
    c = 0
    while True:
        slow = (slow + a[slow]) % n
        fast = (fast + a[fast]) % n
        fast = (fast + a[fast]) % n
        c += 1
        if slow == fast:
            return c == len(a)


def find_cycle(a):
    """
    Return the first element that is part of a cycle and it's length:

    Returns: (i, n)

    >>> find_cycle([])
    (None, 0)
    >>> find_cycle([0])
    (0, 1)
    >>> find_cycle([1])
    (0, 1)
    >>> find_cycle([1, 1, 1])
    (0, 3)
    >>> find_cycle([1, 2, 1])
    (0, 2)
    >>> find_cycle([1, 1, 1, 1, -2, 1])
    (2, 3)
    """
    if DEBUG:
        pprint(a)
    n = len(a)
    if n == 0:
        return (None, 0)
    slow_fast = [0, 0]

    def spin():
        # Python closure problem
        slow = slow_fast[0]
        fast = slow_fast[1]
        c = 0
        while True:
            slow = (slow + a[slow]) % n
            fast = (fast + a[fast]) % n
            fast = (fast + a[fast]) % n
            c += 1
            if slow == fast:
                slow_fast[0] = slow
                slow_fast[1] = fast
                return c

    def trace(n):
        print "slow = %d, fast = %d, spin = %d" % (slow_fast[0], slow_fast[1], n)

    """
    fast and slow meet x steps into cycle
    restarting fast as 0 - will meet slow at start of cycle
    """
    c = spin()
    if DEBUG:
        trace(c)
    d = spin()

    slow = slow_fast[0]
    fast = 0
    while slow != fast:
        slow = (slow + a[slow]) % n
        fast = (fast + a[fast]) % n
    return (slow, d)


if __name__ == "__main__":
    DEBUG = True
    find_cycle([1, 1, 1, 1, -2, 1])

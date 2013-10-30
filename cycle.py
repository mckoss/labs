#!/usr/bin/env python

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
    n = len(a)
    if n == 0:
        return (None, 0)
    slow_fast = [0, 0]

    def spin():
        # Hack for python assignment to closure problem
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

    """
    Number of steps (fast and slow only differ my multiple of cycle)

      fast_steps = slow_steps + k * d
      2 * c = c + k * d
      .: c = k * d

    where d is length of cycle.

    When looking for first element, start, of cycle:

    slow_steps = start_steps + extra_steps

      c = x + y

    because d | c

      .: x = -y (mod d)

    So the distance from 0 to start is congruent to distance from rendevous
    to start!
    """
    spin()
    # find length of cycle (leaves fast and slow same spot)
    d = spin()

    slow = slow_fast[0]
    fast = 0
    while slow != fast:
        slow = (slow + a[slow]) % n
        fast = (fast + a[fast]) % n
    return (slow, d)


if __name__ == "__main__":
    print find_cycle([1, 1, 1, 1, -2, 1])

def hanoi(s, a, b, c):
    """
    Move from a to b, using c as intermediary.

    >>> hanoi([1, 2], 'A', 'C', 'B')
    Move 1 from A to B.
    Move 2 from A to C.
    Move 1 from B to C.
    >>> hanoi([1, 2, 3], 'A', 'C', 'B')
    Move 1 from A to C.
    Move 2 from A to B.
    Move 1 from C to B.
    Move 3 from A to C.
    Move 1 from B to A.
    Move 2 from B to C.
    Move 1 from A to C.
    """
    if len(s) == 0:
        return
    hanoi(s[:-1], a, c, b)
    print "Move %s from %s to %s." % (s[-1], a, b)
    hanoi(s[:-1], c, b, a)

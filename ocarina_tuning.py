#!/usr/bin/env python
#
# Find the "best" tuning for 4-hole Ocarina
#
# Use least-squares of difference of log from ideal tuning for each
# chromatic note.  The Helmholtz equation shows that the relative
# pitch (resonant frequency) is proportional to the square-root of the
# total area of open holes.
#
from pprint import pprint
from math import log

STEP = pow(2.0, 1.0 / 12.0)
IDEAL = [pow(STEP, i) for i in range(0, 12 + 1)]


# Find best-fit solution to the ideal pitches from those given.
def score(pitches):
    """
    >>> score(IDEAL)
    0.0
    >>> score([1.0, 2.0])
    0.5672014747645435
    """
    pitches.sort()
    nearest = [closest(pitch, pitches) for pitch in IDEAL]
    scores = [pow(log(best / pitch), 2) for best, pitch in zip(nearest, IDEAL)]
    return sum(scores)


def closest(value, array):
    """
    >>> closest(0.1, [1, 2, 3])
    1
    >>> closest(1, [1, 2, 3])
    1
    >>> closest(1.7, [1, 2, 3])
    2
    >>> closest(2.7, [1, 2, 3])
    3
    >>> closest(3.1, [1, 2, 3])
    3
    """
    for i in range(len(array) - 1):
        if abs(value - array[i]) < abs(value - array[i + 1]):
            return array[i]
    return array[len(array) - 1]

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
from math import log, sqrt, ceil

STEP = pow(2.0, 1.0 / 12.0)
CHROMATIC = [pow(STEP, i) for i in range(0, 12 + 1)]
MAJOR_INDEX = [0, 2, 4, 5, 7, 9, 11, 12]
MAJOR = [CHROMATIC[MAJOR_INDEX[i]] for i in range(len(MAJOR_INDEX))]


# Find best-fit solution to the ideal pitches from those given.
def score(pitches, standard):
    """
    >>> score(CHROMATIC, MAJOR)
    0.0
    >>> score([1.0, 2.0], CHROMATIC)
    0.5672014747645435
    >>> score(MAJOR, CHROMATIC)
    0.016682396316604266
    """
    nearest = [closest(pitch, pitches) for pitch in standard]
    scores = [pow(log(best / pitch), 2) for best, pitch in zip(nearest, standard)]
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


def pitches_from_holes(holes):
    """
    Relative pitches based on hole area - stated in terms of ratio to fipple opening.

    Pitch proportional to sqrt(A) = sqrt(hole_area + 1)

    >>> pitches_from_holes((1,))
    [1.0, 1.4142135623730951]
    >>> pitches_from_holes((3,))
    [1.0, 2.0]
    >>> len(pitches_from_holes([1, 2, 3]))
    8
    """
    pitches = []
    index = 0
    for index in xrange(pow(2, len(holes))):
        s = 1
        for i in range(len(holes)):
            if index & (1 << i):
                s += holes[i]
        pitches.append(sqrt(s))
    pitches.sort()
    return pitches


def hole_sizes(num_holes, step_size, max_size):
    steps = int(ceil(float(max_size) / step_size))
    for index in xrange(pow(steps, num_holes - 1)):
        value = index
        min_value = 0.0
        holes = []
        for pos in xrange(num_holes - 1):
            part = (value % steps + 1) * step_size
            if part < min_value:
                break
            min_value = part
            holes.append(part)
            value = int(value / steps)
        else:
            holes.append(3.0 - sum(holes))
            yield holes


best_score = 999
for holes in hole_sizes(5, 0.01, 1.0):
    hole_score = score(pitches_from_holes(holes), MAJOR)
    if hole_score < best_score:
        best_score = hole_score
        best_holes = holes
        print holes, hole_score

print fingerings(best_holes, MAJOR)

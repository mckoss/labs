#!/usr/bin/env python
#
# Generate carved letter forms in OpenSCAD format.
#
# Todo:
# - Path Element class
# - Line and Arc implementations
# - All upper case and number definitions
# - Export as SVG for checking
# - Export as OpenSCAD polyhedra.
# - Write command for text conversion


class PathElement(object):
    pass


class Line(PathElement):
    def __init__(self, *points):
        self.points = points


# An Arc is define by a center followed by points along the arc.
class Arc(PathElement):
    def __init__(self, center=None, *points):
        pass


class P2(object):
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        return 'P(%g, %g)' % (self.x, self.y)

    @staticmethod
    def ensure(point):
        """ Return point from data.

        >>> P2.ensure((1.1, 2))
        P(1.1, 2)
        """
        if isinstance(point, P2):
            return point
        if isinstance(point, (list, tuple)):
            return P2(*point)
        raise Exception("Can't convert %r to P2.", type(point))

    @staticmethod
    def ensure_points(points):
        """ Return list of points from data.

        >>> P2.ensure_points([(1, 2), (3, 4), P2(5, 6)])
        [P(1, 2), P(3, 4), P(5, 6)]
        """
        return [P2.ensure(p) for p in points]


# Strokes for letter forms on 0-1 grid.
DL = P2(0, 0)
L = P2(0, 0.5)
TL = P2(0, 1)
T = P2(0.5, 1)
TR = P2(1, 1)
R = P2(1, 0.5)
DR = P2(1, 0)
D = P2(0.5, 0)
C = P2(0.5, 0.5)

paths = {
    'A': [Line(DL, T, DR), ],
    'B': [Line(DL, TL, T), Arc((0.5, 0.75), 0.5, 90, -90),
          Line(C, L), Arc((0.5, 0.25), 0.25, 90, -90),
          Line(D, DL)],
    'C': [Arc((0.5, 0.5), 0.5, 45, 315)],
    'D': [Line(DL, TL, T), Arc((0.5, 0.75), 0.25, 90, 0)],
}


def main():
    print "Hello, world."


if __name__ == '__main__':
    main()

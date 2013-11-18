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

from math import sin, cos, pi


class RenderContext(object):
    def __init__(self):
        self.init()

    def init(self):
        self.last_point = None

    def move_to(self, point):
        point = P2.ensure(point)
        print "Moving to %r." % point
        self.last_point = point

    def render_paths(self, paths):
        for path in paths:
            self.init()
            for elt in path:
                elt.render(self)


class PathElement(object):
    pass


class Line(PathElement):
    def __init__(self, *points):
        self.points = P2.ensure_points(points)

    def render(self, context):
        for point in self.points:
            context.move_to(point)


# An Arc is define by a center followed by points along the arc.
class Arc(PathElement):
    def __init__(self, center=None, *points):
        self.center = P2.ensure(center)
        self.points = self.ensure_points(points)

    def ensure(self, point):
        """
        >>> Arc((1, 1)).ensure((1, 2))
        P(1.0, 2.0)
        >>> Arc((1, 1)).ensure(R2(1, 90))
        P(1.0, 2.0)
        """
        if isinstance(point, R2):
            return self.center + point.point
        return P2.ensure(point)

    def ensure_points(self, points):
        return [self.ensure(p) for p in points]


class R2(object):
    def __init__(self, dist, angle):
        self.point = P2.from_vector(dist, angle)


class P2(object):
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):
        return P2(self.x + other.x, self.y + other.y)

    def __repr__(self):
        return 'P(%0.1f, %0.1f)' % (self.x, self.y)

    @staticmethod
    def from_vector(dist, angle):
        """
        >>> P2.from_vector(1, 0)
        P(1.0, 0.0)
        >>> P2.from_vector(1, 90)
        P(0.0, 1.0)
        >>> P2.from_vector(1, 270)
        P(-0.0, -1.0)
        """
        angle = pi * angle / 180
        return P2(dist * cos(angle), dist * sin(angle))

    @staticmethod
    def ensure(point):
        """ Return point from data.

        >>> P2.ensure((1.1, 2))
        P(1.1, 2.0)
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
        [P(1.0, 2.0), P(3.0, 4.0), P(5.0, 6.0)]
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

letter_paths = {
    'A': [[Line(DL, T, DR), ]],
    'B': [[Line(DL, TL, T), Arc((0.5, 0.75), T, (1, 0.75), C),
          Line(C, L)],
          [Arc((0.5, 0.25), C, (1, 0.25), D), Line(D, DL)]],
    'C': [[Arc(C, R2(0.5, 45), R2(0.4, 315))]],
    'D': [[Line(DL, TL, T), Arc(L, TL, R, DL)]],
}


def main():
    """
    >>> RenderContext().render_paths(letter_paths['A'])
    Moving to P(0.0, 0.0).
    Moving to P(0.5, 1.0).
    Moving to P(1.0, 0.0).
    """
    render = RenderContext()
    for letter, paths in letter_paths.items():
        print "Rendering %s." % letter
        render.render_paths(paths)


if __name__ == '__main__':
    main()

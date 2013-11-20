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

from math import sin, cos, pi, sqrt, atan2

SVG_HEADER = """<?xml version="1.0" encoding="utf-8"?>
<!-- Generator: bevel_letters.py -->
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     x="0px" y="0px"
     width="800px" height="1024px"
     viewBox="0 0 800 1024">
"""

SVG_FOOTER = """
</svg>
"""


class RenderContext(object):
    def __init__(self, resolution=0.01):
        self.resolution = resolution

    def next_letter(self):
        pass

    def open_path(self):
        self.last_point = None

    def close_path(self):
        pass

    def open_render(self):
        pass

    def close_render(self):
        pass

    def move_to(self, point):
        point = point.quantize(self.resolution)
        print "Moving to %r." % point
        self.last_point = point

    def render_paths(self, paths):
        for path in paths:
            self.open_path()
            for elt in path:
                elt.render(self)
            self.close_path()


class RenderSVGContext(RenderContext):
    def open_render(self):
        self.f = open("bevel_letters.svg", 'w')
        self.f.write(SVG_HEADER)
        self.scale = P2(50, -70)
        self.letter_index = -1
        self.next_letter()

    def next_letter(self):
        super(RenderSVGContext, self).open_path()
        self.letter_index += 1
        self.offset = P2(10 + (self.letter_index % 10) * 60,
                         480 + (self.letter_index / 10) * 80)

    def open_path(self):
        super(RenderSVGContext, self).open_path()
        self.f.write('<path stroke="black" stroke-width="1" fill="none" d="')

    def close_path(self):
        super(RenderSVGContext, self).close_path()
        self.f.write('"/>')

    def close_render(self):
        self.f.write(SVG_FOOTER)
        self.f.close()

    def move_to(self, point):
        scaled = P2(point.x, point.y)
        scaled.x *= self.scale.x
        scaled.y *= self.scale.y
        scaled = (scaled + self.offset).quantize(self.resolution)
        self.f.write("    %c %f %f \n" % ('L' if self.last_point else 'M',
                                          scaled.x, scaled.y))
        self.last_point = point


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
        self._ccw = False

    def ccw(self):
        self._ccw = True
        return self

    def render(self, context):
        context.move_to(self.points[0])
        v1 = (self.points[0] - self.center).vector()
        for point in self.points[1:]:
            v2 = (point - self.center).vector()
            if self.ccw and v2.angle < v1.angle:
                v2.angle += 360
            for i in xrange(1, 11):
                p = convex(float(i) / 10, v1, v2).point()
                context.move_to(self.center + p)
            v1 = v2

    def ensure(self, point):
        """
        >>> Arc((1, 1)).ensure((1, 2))
        P(1.00, 2.00)
        >>> Arc((1, 1)).ensure(R2(1, 90))
        P(1.00, 2.00)
        """
        if isinstance(point, R2):
            return self.center + point.point()
        return P2.ensure(point)

    def ensure_points(self, points):
        return [self.ensure(p) for p in points]


def convex(r, v1, v2):
    """
    >>> convex(0, 10, -1)
    10.0
    >>> convex(1, 10, -1)
    -1.0
    """
    r = float(r)
    return v1 * (1 - r) + v2 * r


class R2(object):
    def __init__(self, dist, angle):
        self.dist = dist
        self.angle = angle

    def __repr__(self):
        return 'R(%0.2f, %0.2f)' % (self.dist, self.angle)

    def __mul__(self, mult):
        return R2(self.dist * mult, self.angle * mult)

    def __add__(self, other):
        return R2(self.dist + other.dist, self.angle + other.angle)

    def point(self):
        """
        >>> R2(1, 0).point()
        P(1.00, 0.00)
        >>> R2(1, 90).point()
        P(0.00, 1.00)
        >>> R2(1, 270).point()
        P(-0.00, -1.00)
        """
        angle = pi * self.angle / 180
        return P2(self.dist * cos(angle), self.dist * sin(angle))


class P2(object):
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):
        return P2(self.x + other.x, self.y + other.y)

    def __sub__(self, other):
        return P2(self.x - other.x, self.y - other.y)

    def __repr__(self):
        return 'P(%0.2f, %0.2f)' % (self.x, self.y)

    def quantize(self, resolution):
        result = P2(int(self.x / resolution) * resolution, int(self.y / resolution) * resolution)
        return result

    def vector(self):
        """
        >>> P2(1, 0).vector()
        R(1.00, 0.00)
        >>> P2(0, 1).vector()
        R(1.00, 90.00)
        """
        d = sqrt(self.x * self.x + self.y * self.y)
        a = atan2(self.y, self.x) * 180 / pi
        return R2(d, a)

    @staticmethod
    def ensure(point):
        """ Return point from data.

        >>> P2.ensure((1.1, 2))
        P(1.10, 2.00)
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
        [P(1.00, 2.00), P(3.00, 4.00), P(5.00, 6.00)]
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
    'A': [[Line(DL, T, DR), ],
          [Line((0.25, 0.5), (0.75, 0.5))]],
    #'B': [[Line(DL, TL, T), Arc((0.5, 0.75), T, (1, 0.75), C),
    #       Line(C, L)],
    #      [Arc((0.5, 0.25), C, (1, 0.25), D), Line(D, DL)]],
    'C': [[Arc(C, R2(0.5, 45), R2(0.5, 315)).ccw()]],
    #'D': [[Line(DL, TL, T), Arc(L, TL, R, DL)]],
}


def main():
    """
    >>> RenderContext().render_paths(letter_paths['A'])
    Moving to P(0.00, 0.00).
    Moving to P(0.50, 1.00).
    Moving to P(1.00, 0.00).
    Moving to P(0.25, 0.50).
    Moving to P(0.75, 0.50).
    >>> RenderContext().render_paths(letter_paths['C'])
    Moving to P(0.85, 0.85).
    Moving to P(0.65, 0.97).
    Moving to P(0.42, 0.99).
    Moving to P(0.20, 0.90).
    Moving to P(0.05, 0.72).
    Moving to P(0.00, 0.50).
    Moving to P(0.05, 0.27).
    Moving to P(0.20, 0.09).
    Moving to P(0.42, 0.00).
    Moving to P(0.65, 0.02).
    Moving to P(0.85, 0.14).
    """
    render = RenderSVGContext()
    render.open_render()
    for letter, paths in letter_paths.items():
        print "Rendering %s." % letter
        render.render_paths(paths)
        render.next_letter()
    render.close_render()


if __name__ == '__main__':
    main()

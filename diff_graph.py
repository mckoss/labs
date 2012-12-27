#!/usr/bin/env python
import argparse
from math import sin, cos, pi

from graphics import GraphWin, Circle, Point, Line, color_rgb

from difference import DiffState

WIN_SIZE = 800
R = WIN_SIZE / 3
CENTER = (WIN_SIZE / 2, WIN_SIZE / 2)
set_color = color_rgb(255, 0, 0)
all_color = color_rgb(200, 200, 200)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", type=int, default=3, help="Size of k")
    args = parser.parse_args()

    win = GraphWin("My Circle", WIN_SIZE, WIN_SIZE)

    k = args.size
    m = k * (k - 1) + 1
    r = min(pi * R / m * 0.50, 20)

    ds = DiffState(k)
    ds.search()

    points = []
    for i in range(m):
        ang = 2 * pi * i / m
        center = (CENTER[0] + R * sin(ang), CENTER[1] - R * cos(ang))
        points.append(Point(center[0], center[1]))

    for i in range(m):
        for j in range(i, m):
            if not (i in ds.current and j in ds.current):
                l = Line(points[i], points[j])
                l.draw(win)
                l.setOutline(all_color)

    for i in range(m):
        for j in range(i, m):
            if i in ds.current and j in ds.current:
                l = Line(points[i], points[j])
                l.setWidth(3)
                l.draw(win)
                l.setOutline(set_color)

    for i in range(m):
        c = Circle(points[i], r)
        c.setFill('red')
        c.draw(win)

    win.getMouse()
    win.close()


if __name__ == '__main__':
    main()

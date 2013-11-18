#!/usr/bin/env python
#
# Generate carved letter forms in OpenSCAD format.
#

# Strokes for letter forms on 0-1 grid.
DL = (0, 0)
L = (0, 0.5)
TL = (0, 1)
T = (0.5, 1)
TR = (1, 1)
R = (1, 0.5)
DR = (1, 0)
D = (0.5, 0)
C = (0.5, 0.5)

strokes = {
    'A': [Line(DL, T, DR), ],
    'B': [Line(DL, TL, T), Arc((0.5, 0.75), 0.5, 90, -90),
          Line(C, L), Arc((0.5, 0.25), 0.25, 90, -90),
          Line(D, DL)],
    'C': [Arc((0.5, 0.5), 0.5, 45, 315)],
    'D': [Line(DL, TL, T), Arc((0.5, 0.75), 0.25, 90, 0)
}

def main():
    print "Hello, world."


if __name__ == '__main__':
    main()

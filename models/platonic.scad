// Platonic solids
// http://en.wikipedia.org/wiki/Platonic_solid
// by Mike Koss (c) 2014

PART = "dodecahedron"; // [tetrahedron, cube, octahedron, dodecahedron, icosahedron]]

S=100;
THICKNESS=4;
SCALE=25;
PHI=(1 + sqrt(5))/2;
E = 0.1;

$fa=3;
$fs=1;

if (PART == "tetrahedron")
  polyhedron([
      [1, 1, 1],
      [1, -1, -1],
      [-1, 1, -1],
      [-1, -1, 1]
    ],
    s=2.83);

if (PART == "octahedron")
  polyhedron([
      [1, 0, 0], [0, 1, 0], [-1, 0, 0],
      [0, -1, 0], [0, 0, 1], [0, 0, -1]
    ],
    s=1.42);

if (PART == "cube")
  polyhedron([
      [-1, -1, -1], [-1, -1, 1], [-1, 1, -1], [-1, 1, 1],
      [1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1]
    ],
    s=2.01);

if (PART == "dodecahedron")
  polyhedron([
      [-1, -1, -1], [-1, -1, 1], [-1, 1, -1], [-1, 1, 1],
      [1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1],
      [0, -1/PHI, -PHI], [0, -1/PHI, PHI], [0, 1/PHI, -PHI], [0, 1/PHI, PHI],
      [-1/PHI, -PHI, 0], [-1/PHI, PHI, 0], [1/PHI, -PHI, 0], [1/PHI, PHI, 0],
      [-PHI, 0, -1/PHI], [-PHI, 0, 1/PHI], [PHI, 0, -1/PHI], [PHI, 0, 1/PHI]
    ],
    s=1.3);

if (PART == "icosahedron")
  polyhedron([
      [0, -1, -PHI], [0, 1, -PHI], [0, -1, PHI], [0, 1, PHI],
      [-1, -PHI, 0], [-1, PHI, 0], [1, -PHI, 0], [1, PHI, 0],
      [-PHI, 0, -1], [-PHI, 0, 1], [PHI, 0, -1], [PHI, 0, 1],
    ],
    s=2);

module polyhedron(v, s, xform=SCALE, width=THICKNESS) {
  d = dist(v[0] - v[1]);
  for (i = [0: len(v) - 2]) {
    for (j = [i + 1: len(v) - 1]) {
      if (dist(v[i] - v[j]) <= s) {
        edge(xform * v[i], xform * v[j], width=width);
      }
    }
  }
}

module edge(from, to, width=1) {
  hull() {
    translate(from) cube([width, width, width], center=true);
    translate(to) cube([width, width, width], center=true);
  }
}

function rotxy(a) = [
    [cos(a), -sin(a), 0],
    [sin(a), cos(a),  0],
    [0,      0,       1]
  ];

function rotxz(a) = [
    [cos(a), 0, -sin(a)],
    [0,      1,       0],
    [sin(a), 0, cos(a)]
  ];

function rotyz(a) = [
    [1, 0,      0],
    [0, cos(a), -sin(a)],
    [0, sin(a), cos(a)]
  ];

function dist(pos) = sqrt(pos * pos);

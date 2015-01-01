// Xmas tree ornaments
// by Mike Koss (c) 2014

PART = "octahedron"; // [ALL]

S=100;
THICKNESS=2;
E = 0.1;

$fa=3;
$fs=1;

v4 = [
  [1, 1, 1],
  [1, -1, -1],
  [-1, 1, -1],
  [-1, -1, 1]
];

e4 = [
  [0, 1], [0, 2], [0, 3],
  [1, 2], [1, 3],
  [2, 3]
];

if (PART == "tetrahedron")
  polyhedron(v4, e4,
             xform=25 * rotyz($t * 36) * rotxz(45),
             width=4);

v6 = [
  [1, 0, 0], [-1, 0, 0],
  [0, 1, 0], [0, -1, 0],
  [0, 0, 1], [0, 0, -1]
];

e6 = [
  [0, 2], [0, 3], [0, 4], [0, 5],
  [1, 2], [1, 3], [1, 4], [1, 5],
  [2, 4], [2, 5], [3, 4], [3, 5]
];

if (PART == "octahedron")
  polyhedron(v6, e6,
             xform=25 * rotyz($t * 36) * rotxz(45),
             width=4);

v8 = [
  [-1, -1, -1], [-1, -1, 1], [-1, 1, -1], [-1, 1, 1],
  [1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1]
];

e8 = [
  [0, 1], [1, 3], [3, 2], [2, 0],
  [4, 5], [5, 7], [7, 6], [6, 4],
  [0, 4], [1, 5], [2, 6], [3, 7]
];

if (PART == "cube")
  polyhedron(v8, e8,
             xform=25 * rotyz($t * 36) * rotxz(45),
             width=4);





module polyhedron(v, e, xform=1, width=THICKNESS) {
  for (i= [0: len(e) - 1]) {
    edge(xform * v[e[i][0]], xform * v[e[i][1]], width=width);
  }
}

// A simple parallelepiped connected a width-square
// at point from[x, y, z] to point to[x, y, z].
module edge(from, to, width=1) {
  hull() {
    translate(from) cube([width, width, width], center=true);
    translate(to) cube([width, width, width], center=true);
  }
}

// Repeats a child element steps times, rotating
// 360/steps degrees about the z axis each time.
module multiRotate(steps=8) {
  for (i = [0: steps - 1]) {
    rotate(a=360 * i / steps, v=[0, 0, 1])
      child();
  }
}

// Ring with OD, r, around origin (at z=0)
module ring(r, thickness=THICKNESS, height=THICKNESS) {
  difference() {
    cylinder(h=height, r=r, center=true);
    cylinder(h=height + 2 * E, r=r - thickness, center=true);
  }
}

// Utility functions
function unit2(dir) = [cos(dir), sin(dir)];
function unit3(dir, elev) = [cos(elev) * cos(dir), cos(elev) * sin(dir), sin(elev)];
function combine(f, x0, x1) = x0 * (1 - f) + x1 * f;
function dist(pos) = sqrt(pos[0]*pos[0] + pos[1]*pos[1]);
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

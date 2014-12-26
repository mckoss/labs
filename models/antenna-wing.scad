// Antenna ornament
// by Mike Koss (c) 2014

use <naca.scad>;

TURNS=4;
HEIGHT=TURNS * (17.5 - 2.5);
RADIUS=(10.1 / 2);
THICKNESS=2.5;
E = 0.1;

$fa=3;
$fs=1;


module spiral(height, radius, turns=4, sides=32, width=THICKNESS) {
  for (i = [0: turns * sides - 1]) {
    assign(
      p1 = point(radius, i,     sides),
      p2 = point(radius, i + 1, sides),
      z1 = height * i / (turns * sides),
      z2 = height * (i + 1) / (turns * sides)
    ) {
        piped([p1[0], p1[1], z1], [p2[0], p2[1], z2], width=width);
     }
   }
}

function point(radius, i, sides) =
    radius * unit2(360 * i / sides);


// A simple parallelepiped connected a width-square
// at point from[x, y, z] to point to[x, y, z].
module piped(from, to, width=1) {
  translate(from)
  multmatrix(m=[
    [1, 0, to[0] - from[0], 0],
    [0, 1, to[1] - from[1], 0],
    [0, 0, to[2] - from[2], 0],
    [0, 0, 0, 1],
  ])
    translate([0, 0, 0.5])
      cube([width, width, 1], center=true);
}

// Utility functions
function unit2(dir) = [cos(dir), sin(dir)];
function combine(f, x0, x1) = x0 * (1 - f) + x1 * f;
function dist(pos) = sqrt(pos[0]*pos[0] + pos[1]*pos[1]);

module antenna() {
  union() {
    spiral(HEIGHT, RADIUS + THICKNESS / 2, turns=TURNS);
    cylinder(HEIGHT, r=RADIUS + 1);
  }
}

//render(convexity=2)
rotate(a=-90, v=[0, 1, 0])
difference() {
  union() {
    translate([10, 0, 0])
      wing(30, 70, taper=0.5, sweep_ang=45);
    translate([-5, 0, 0])
      body(120);
  }
  # translate([0, 0, -20])
    rotate(a=45, v=[0, 1, 0])
      antenna();
  # translate([-50, 0, 0])
    cube(100, center=true);
}

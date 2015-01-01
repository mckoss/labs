// Spring experiment.
// by Mike Koss (c) 2014

RADIUS = 10;
THICKNESS = 2;
HEIGHT = 20;
E = 0.1;

$fa=3;
$fs=1;

multiRotate()
  springCoil();
ring(RADIUS + THICKNESS / 2);
translate([0, 0, HEIGHT])
  ring(RADIUS + THICKNESS / 2);

module springCoil(radius=RADIUS, height=HEIGHT, turns=0.5, sides=32, width=THICKNESS) {
  begin = 0;
  end = turns * sides;
  for (i = [begin : end - 1]) {
    echo(springPoint(radius, height, i,     turns, sides));
    piped(springPoint(radius, height, i,     turns, sides),
          springPoint(radius, height, i + 1, turns, sides),
          width=width);
   }
}

function springPoint(radius, height, i, turns=1, sides=32) =
    radius * unit2(360 * i / sides, height * i / (turns * sides) / radius);

// Hook to hang ornament.
module hanger() {
  translate([0, 0, HEIGHT + 4])
    rotate(a=90, v=[1, 0, 0])
      ring(5);
}

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

// Both clockwise and counterclockwise  multiRotate.
module rotateRevert(steps=8) {
  multiRotate(steps)
    child();
  mirror([0, 1, 0])
    multiRotate(steps)
      child();
}

// Utility functions
function unit2(dir, z) = [cos(dir), sin(dir), z];
function unit3(dir, elev) = [cos(elev) * cos(dir), cos(elev) * sin(dir), sin(elev)];
function combine(f, x0, x1) = x0 * (1 - f) + x1 * f;
function dist(pos) = sqrt(pos[0]*pos[0] + pos[1]*pos[1]);

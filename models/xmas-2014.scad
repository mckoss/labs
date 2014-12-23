// Xmas tree ornament
// by Mike Koss (c) 2014

PART = "ball"; // [tree, ball]

HEIGHT=75;
RADIUS=30;
THICKNESS=2;
E = 0.1;

$fa=3;
$fs=1;


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

// Draw a spiral starting with max radius at z=0 and
// spirals around the z axis turns times, reaching the
// intersection with z-axis at height units.
module spiral(height, radius, turns=1, sides=32, width=THICKNESS) {
  for (i = [0 : turns * sides - 1]) {
    assign(
      x1 = radius * cos(i * 360 / sides) * (turns * sides - i) / (turns * sides),
      y1 = radius * sin(i * 360 / sides) * (turns * sides - i) / (turns * sides),
      z1 = height * i / (turns * sides),
      x2 = radius * cos((i + 1) * 360 / sides) * (turns * sides - i - 1) / (turns * sides),
      y2 = radius * sin((i + 1) * 360 / sides) * (turns * sides - i - 1) / (turns * sides),
      z2 = height * (i + 1) / (turns * sides)) {
        piped([x1, y1, z1], [x2, y2, z2], width=width);
     }
   }
}

// Draw a spiral along the surface of a sphere of radius.
// Spirals around the z axis turns times, reaching the
// intersection with z-axis at height units.
module spiralSphere(start=0, radius, turns=1, sides=32, width=THICKNESS) {
  begin = ceil(start * turns * sides);
  for (i = [begin : turns * sides - 1]) {
    assign(
      x1 = radius * cos(i * 360 / sides) * sin(180 * i / (turns * sides)),
      y1 = radius * sin(i * 360 / sides) * sin(180 * i / (turns * sides)),
      z1 = - radius * cos(180 * i / (turns * sides)),
      x2 = radius * cos((i + 1) * 360 / sides) * sin(180 * (i + 1) / (turns * sides)),
      y2 = radius * sin((i + 1) * 360 / sides) * sin(180 * (i + 1) / (turns * sides)),
      z2 = - radius * cos(180 * (i + 1) / (turns * sides))) {
        piped([x1, y1, z1], [x2, y2, z2], width=width);
     }
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

// Ring around origin (at z=0)
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

module hanger() {
  translate([0, 0, HEIGHT + 4])
    rotate(a=90, v=[1, 0, 0])
      ring(5);
}

module treeOrnament() {
  rotateRevert()
    spiral(HEIGHT, RADIUS, width=THICKNESS);

  translate([0, 0, THICKNESS/2])
    ring(RADIUS+THICKNESS/2);

  hanger();
}

module sphereOrnament() {
  portion = 0.8;
  start = 1 - portion;
  radius = HEIGHT / (1 + cos(180 * start));
  offset =  radius * cos(180 * start);

  translate([0, 0, offset])
    rotateRevert()
      spiralSphere(start, radius, width=THICKNESS);

  translate([0, 0, THICKNESS/2])
    ring(radius * sin(180 * start) + 1.5 * THICKNESS);

  translate([0, 0, HEIGHT + 4])
    rotate(a=90, v=[1, 0, 0])
      ring(5);
}

if (PART == "tree") treeOrnament();
if (PART == "ball") sphereOrnament(RADIUS, width=2);

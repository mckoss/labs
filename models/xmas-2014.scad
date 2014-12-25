// Xmas tree ornaments
// by Mike Koss (c) 2014

PART = "ALL"; // [tree, ball, onion, ALL]

HEIGHT=75;
RADIUS=30;
THICKNESS=2;
E = 0.1;

$fa=3;
$fs=1;


// Tree (conical) ornament.
//
//           |
//          / \
//         /   \
//        /     \
//       =========

module treeOrnament() {
  rotateRevert()
    spiralCone(HEIGHT, RADIUS, width=THICKNESS);

  // Bottom base.
  translate([0, 0, THICKNESS/2])
    ring(RADIUS+THICKNESS/2);

  hanger();
}

// Draw a spiral starting with max radius at z=0 and
// spirals around the z axis turns times, reaching the
// intersection with z-axis at height units.
module spiralCone(height, radius, turns=0.6, sides=32, width=THICKNESS) {
  for (i = [0 : turns * sides - 1]) {
    assign(
      p1 = conePoint(radius, i,     turns, sides),
      p2 = conePoint(radius, i + 1, turns, sides),
      z1 = height * i / (turns * sides),
      z2 = height * (i + 1) / (turns * sides)
    ) {
        piped([p1[0], p1[1], z1], [p2[0], p2[1], z2], width=width);
     }
   }
}

function conePoint(radius, i, turns=0.6, sides=32) =
    radius * (1 - i / (turns * sides)) * unit2(360 * i / sides);


// Ball (spherical) ornament.
//
//            |
//           / \
//          =====
//        /       \
//       |         |
//        \       /
//          =====

module sphereOrnament() {
  start = 0.2;
  finish = 0.8;
  turns = 1;
  sides = 32;
  radius = HEIGHT / 2;
  bottom = spherePoint(radius, ceil(start * turns * sides), turns, sides);
  top = spherePoint(radius, ceil(finish * turns * sides), turns, sides);

  // Central sphere portion.
  translate([0, 0, -bottom[2]])
    rotateRevert(12)
      spiralSphere(radius, start=start, finish=finish, turns=turns, sides=sides, width=THICKNESS);

  // Top cap (conical for printability).
  translate([0, 0, top[2] - bottom[2]])
    union () {
      ring(dist(top) + THICKNESS/2);
      rotateRevert(6)
        spiralCone(HEIGHT - (top[2] - bottom[2]), dist(top), turns=0.25, width=THICKNESS);
    }

  // Bottom base.
  translate([0, 0, THICKNESS/2])
    ring(dist(bottom) + THICKNESS/2);

  hanger();
}

// Draw a spiral along the surface of a sphere of radius.
// Spirals around the z axis turns times, reaching the
// intersection with z-axis at height units.
//
// Start and finish between [0..1] as percentage of whole sphere.
module spiralSphere(radius, start=0, finish=1, turns=1, sides=32, width=THICKNESS) {
  begin = ceil(start * turns * sides);
  end = ceil(finish * turns * sides);
  for (i = [begin : end - 1]) {
    piped(spherePoint(radius, i,     turns, sides),
          spherePoint(radius, i + 1, turns, sides),
          width=width);
   }
}

function spherePoint(radius, i, turns=1, sides=32) =
    radius * unit3(360 * i / sides, 180 * i / (turns * sides) - 90);


// Onion dome ornament.
//
//            |
//           / \
//          ,   .
//        /       \
//       |         |
//        \       /
//          =====
//
// Uses a sin^2 curve to approximate the onion dome shape
// reminiscent of Russian Orthodox curches.
//
// http://en.wikipedia.org/wiki/Onion_dome

module onionOrnament() {
  bottom = onionPoint(RADIUS, 0);

  rotateRevert()
    spiralOnion(HEIGHT, RADIUS, width=THICKNESS);

  // Bottom base.
  translate([0, 0, THICKNESS/2])
    ring(dist(bottom) + THICKNESS/2);

  hanger();
}

module spiralOnion(height, radius, turns=0.6, sides=32, width=THICKNESS) {
  for (i = [0: turns * sides - 1]) {
    assign(
      p1 = onionPoint(radius, i,     turns, sides),
      p2 = onionPoint(radius, i + 1, turns, sides),
      z1 = height * i / (turns * sides),
      z2 = height * (i + 1) / (turns * sides)
    ) {
        piped([p1[0], p1[1], z1], [p2[0], p2[1], z2], width=width);
     }
   }
}

function onionPoint(radius, i, turns=1, sides=32) =
    radius * pow(sin(135 * i / (turns * sides) + 45), 2) * unit2(360 * i / sides);


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
function unit2(dir) = [cos(dir), sin(dir)];
function unit3(dir, elev) = [cos(elev) * cos(dir), cos(elev) * sin(dir), sin(elev)];
function combine(f, x0, x1) = x0 * (1 - f) + x1 * f;
function dist(pos) = sqrt(pos[0]*pos[0] + pos[1]*pos[1]);


if (PART == "tree") treeOrnament();
if (PART == "ball") sphereOrnament();
if (PART == "onion") onionOrnament();

if (PART == "ALL") {
  treeOrnament();
  translate([3 * RADIUS, 0, 0])
    sphereOrnament();
  translate([-3 * RADIUS, 0, 0])
    onionOrnament();
}

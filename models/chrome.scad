// Google Chrome Logo

use <Thread_Library.scad>

OUTER = 100;
INNER = 23 * OUTER / 50;
CAP_RATIO = 0.60;
HEMISPHERE = true;
CAP_WALL = 3.0 * OUTER / 50;;
RING_WIDTH = 2.0 * OUTER / 50;
SQUASH = 1.0;
GAP = 0.5;
PITCH = 3 * OUTER / 50;

PART = "blue"; // [red, yellow, green, blue]

// Epsilon
E = 0.01;

module sphereoid(size, squash=SQUASH) {
  scale([1, 1, squash])
    difference() {
      sphere(r=size / 2);
      if (HEMISPHERE) {
        translate([0, 0, -size / 2])
          cube(size=size + E, center=true);
      }
    }
}

module wedge(size, inner, squash, part=0) {
  cap_height = size * squash * CAP_RATIO / (HEMISPHERE ? 2 : 1);
  difference() {
    sphereoid(size, squash);
    difference() {
      translate([0, 0, size * squash / 2 - cap_height - GAP + E])
        cylinder(r=inner / 2, h=cap_height + GAP + E);
      translate([0, 0, size * squash / 2 - cap_height - GAP - E])
        trapezoidThread(length=cap_height - CAP_WALL - 2 * GAP,
                        pitchRadius=inner / 2 - RING_WIDTH - CAP_WALL,
                        pitch=PITCH);
    }
    rotate(a=-120 * part, v=[0, 0, 1])
      cut_away(size, inner);
  }
}

module cut_away(size, inner) {
    translate([0, -size + inner / 2, -size / 2])
        cube(size + E);
    rotate(a=-60, v=[0, 0, 1])
      translate([0, -size + inner / 2, -size / 2])
        cube(size + E);
    rotate(a=-60, v=[0, 0, 1])
      translate([-size / 2 - E, -size - 2 * E - INNER / 2, -size / 2])
      cube(size + 2 * E);
}

module cap(size, inner, squash) {
  cap_height = size * squash * CAP_RATIO / (HEMISPHERE ? 2 : 1);
  difference() {
    intersection() {
      sphereoid(size, squash);
      translate([0, 0, size * squash / 2 - cap_height])
        cylinder(r=inner / 2 - RING_WIDTH, h=size);
    }
    translate([0, 0, size * squash / 2 - cap_height])
      // NOT trimmed to length!  Why???
      intersection() {
        translate([0, 0, -E])
          cylinder(r=inner, h=cap_height - CAP_WALL - 2 * GAP);
        trapezoidThreadNegativeSpace(length=cap_height - CAP_WALL - 2 * GAP,
                        pitchRadius=inner / 2 - RING_WIDTH - CAP_WALL,
                        countersunk=0,
                        pitch=PITCH);
      }
   }
}

// Ring around origin (at z=0)
module ring(r, thickness, height) {
  translate([0, 0, height / 2]) {
    difference() {
      cylinder(h=height, r=r, $fa=3, center=true);
      cylinder(h=height + 2 * E, r=r - thickness, $fa=3, center=true);
    }
  }
}

if (PART == "red") wedge(OUTER, INNER, SQUASH, part=0);
if (PART == "yellow") wedge(OUTER, INNER, SQUASH, part=1);
if (PART == "green") wedge(OUTER, INNER, SQUASH, part=2);
if (PART == "blue") {
  cap(OUTER, INNER, SQUASH);
}

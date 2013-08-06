// Google Chrome Logo

OUTER = 50;
INNER = OUTER * 23 / 50;
CAP_HEIGHT = 0.75;
HEMISPHERE = true;
CAP_WALL = 3.0;
SQUASH = 0.6;
GAP = 0.5;

PART = "wedge"; // [wedge, cap]

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

module wedge(size, inner, squash) {
  cap_height = size * squash * CAP_HEIGHT / (HEMISPHERE ? 2 : 1);
  difference () {
    sphereoid(size, squash);
    translate([0, 0, size * squash / 2 - cap_height + E])
      cap(inner, CAP_WALL, cap_height + E);
    translate([0, -size + inner / 2, -size / 2])
        cube(size + E);
    rotate(a=-60, v=[0, 0, 1])
      translate([0, -size + inner / 2, -size / 2])
        cube(size + E);
    rotate(a=-60, v=[0, 0, 1])
      translate([-size / 2 - E, -size - 2 * E - INNER / 2, -size / 2])
      cube(size + 2 * E);
  }
}

module cap(size, thickness, height) {
  ring(r=size/2, thickness=thickness, height=height);
  translate([0, 0, height - thickness])
    cylinder(r=size/2, h=thickness);
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

if (PART == "wedge") wedge(OUTER, INNER, SQUASH);
if (PART == "cap") {
  translate([0, 0, OUTER * SQUASH / 2 * CAP_HEIGHT])
    rotate(a=180, v=[0, 1, 0])
    cap(INNER - GAP, CAP_WALL - GAP, OUTER * SQUASH / 2 * CAP_HEIGHT - GAP);
}

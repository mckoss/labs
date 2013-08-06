// Google Chrome Logo

OUTER = 40;
INNER = OUTER / 3;
CAP_HEIGHT = 0.4;
HEMISPHERE = true;
CAP_WALL = 2.0;
SQUASH = 0.6;

// Epsilon
E = 0.01;

module sphereoid(size, squash=SQUASH) {
  scale([1, 1, 0.6])
    difference() {
      sphere(r=size / 2);
      if (HEMISPHERE) {
        translate([0, 0, -size / 2])
          cube(size=size + E, center=true);
      }
    }
}

module wedge(size, inner, squash) {
  cap_height = size * squash / 2 * CAP_HEIGHT;
  difference () {
    sphereoid(size, squash);
    translate([0, 0, size * squash / 2 - cap_height + E])
      cap(inner, cap_height + E);
    translate([0, 0, cap_height + E])
      rotate(a=180, v=[0, 1, 0])
      cap(inner, cap_height + E);
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

module cap(size, height) {
  ring(r=size/2, thickness=CAP_WALL, height=height);
  translate([0, 0, height - CAP_WALL])
    cylinder(r=size/2, h=CAP_WALL);
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

wedge(OUTER, INNER, SQUASH);

/*
translate([OUTER / 2 * 1.2, 0, OUTER * SQUASH / 2 * CAP_HEIGHT])
  rotate(a=180, v=[0, 1, 0])
  cap(INNER, OUTER * SQUASH / 2 * CAP_HEIGHT);
*/
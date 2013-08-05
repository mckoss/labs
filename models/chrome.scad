// Google Chrome Logo

OUTER = 40;
INNER = OUTER / 3;
HEMISPHERE = false;

// Epsilon
E = 0.01;

module sphereoid(size, squash) {
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
  difference () {
    sphereoid(size, squash);
    # translate([0, 0, -size / 2 - E])
      cylinder(r=inner / 2, h=size + 2 * E);
    # translate([0, -size + inner / 2, -size / 2])
        cube(size + E);
    # rotate(a=-60, v=[0, 0, 1])
      translate([0, -size + inner / 2, -size / 2])
        cube(size + E);
    # rotate(a=-60, v=[0, 0, 1])
      translate([-size / 2 - E, -size - 2 * E - INNER / 2, -size / 2])
      cube(size + 2 * E);
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

wedge(OUTER, INNER, 0.6);

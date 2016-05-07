// Setup and constants
$fa = 3;
$fs = 3;
E = 0.1;
INCH = 25.4;
BIG = 8 * INCH;

// Model dimensions
WALL_THICKNESS = 0.125 * INCH;
SLOT_GAP = 1;

BASE_THICKNESS = 0.25 * INCH;
BASE_WIDTH = 1 * INCH;
BASE_LENGTH = 7 * INCH;

RING_INNER_DIAMETER = 2.0 * INCH;
RING_OUTER_DIAMETER = RING_INNER_DIAMETER + WALL_THICKNESS * 2;
// Center of ring
RING_STATION = 2 * INCH;

RING_CENTER = RING_OUTER_DIAMETER / 2;

CUP_INNER_DIAMETER = 1.5 * INCH;
CUP_INNER_RADIUS = CUP_INNER_DIAMETER / 2;
CUP_OUTER_RADIUS = 1.5 * CUP_INNER_RADIUS;
// The outer cup body is offset such that it projects a WALL_THICKNESS beyond
// the inner cup.
CUP_OUTER_OFFSET = CUP_INNER_RADIUS + WALL_THICKNESS - CUP_OUTER_RADIUS;
// Top of cup opening
CUP_STATION = BASE_LENGTH - CUP_INNER_DIAMETER / 2;

STRAP_WIDTH = 26;
STRAP_THICKNESS = 2;
// Station centers
TOP_STRAP_STATION = 1 * INCH;
BOTTOM_STRAP_STATION = BASE_LENGTH - 1.5 * INCH;

module holster() {
  difference() {
    union() {
      base();
      ring();
      cup();
    }
    translate([TOP_STRAP_STATION, 0, BASE_THICKNESS / 2]) {
      slot(STRAP_WIDTH, STRAP_THICKNESS);
    }
    translate([BOTTOM_STRAP_STATION, 0, BASE_THICKNESS / 2]) {
      slot(STRAP_WIDTH, STRAP_THICKNESS);
    }
  }
}

module base() {
  translate([BASE_LENGTH / 2, 0, BASE_THICKNESS / 2]) {
    cube([BASE_LENGTH, BASE_WIDTH, BASE_THICKNESS], center=true);
  }
}

module ring() {
  translate([RING_STATION, 0, RING_CENTER]) {
    rotate([0, -90, 0]) {
      difference() {
        cylinder(r=RING_OUTER_DIAMETER / 2,
                 h=2 * WALL_THICKNESS, center=true);
        cylinder(r=RING_INNER_DIAMETER / 2,
                 h=2 * WALL_THICKNESS + E, center=true);
      }
    }
  }
}

module cup() {
  translate([CUP_STATION, 0, RING_CENTER]) {
    rotate([0, -90, 0]) {
      difference() {
        scale([1, 0.8, 0.9]) {
          translate([CUP_OUTER_OFFSET, 0, 0]) {
            sphere(r=CUP_OUTER_RADIUS, center=true);
          }
        }
        sphere(r=CUP_INNER_DIAMETER / 2, center=true);
        translate([0, 0, BIG / 2]) big_box();
        translate([-BIG/2 - RING_CENTER, 0, 0]) big_box();
      }
    }
  }
}

module big_box() {
  cube([BIG, BIG, BIG], center=true);
}

module slot(width, thickness) {
  cube([width + SLOT_GAP, BIG, thickness + SLOT_GAP], center=true);
}

holster();

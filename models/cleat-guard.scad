// Cleat-guard sole prototype
// All dimensions in millimeters.

HEEL_WIDTH = 55;
PAD_WIDTH = 85;
SOLE_THICKNESS = 5;
LENGTH = 235;
INSTEP_WIDTH = 70;
INSTEP_LENGTH = 150;
ANGLE = -10;

WALL = 5;

NUM_HOLES = 7;
STRAP_WIDTH = 15;
STRAP_THICKNESS = 2;

// Centers
HEEL_CENTER = 0;
INSTEP_CENTER = HEEL_CENTER + INSTEP_LENGTH - INSTEP_WIDTH / 2 - HEEL_WIDTH / 2;
PAD_CENTER = HEEL_CENTER + LENGTH - HEEL_WIDTH / 2 - PAD_WIDTH / 2;

// Epsilon
E = 0.05;

$fa=3;
$fs=1;

module sole(thickness, extra) {
  hull() {
    translate([HEEL_CENTER, 0, 0])
      cylinder(r=HEEL_WIDTH / 2 + extra, h=thickness);
    translate([INSTEP_CENTER, 0, 0])
      cylinder(r=INSTEP_WIDTH / 2 + extra, h=thickness);
  }
  translate([INSTEP_CENTER, 0, 0])
    rotate(a=ANGLE, v=[0, 0, 1])
    hull () {
      cylinder(r=INSTEP_WIDTH / 2 + extra, h=thickness);
      translate([PAD_CENTER - INSTEP_CENTER, 0, 0])
        cylinder(r=PAD_WIDTH / 2 + extra, h=thickness);
    }
}

difference() {
  sole(SOLE_THICKNESS * 2, WALL);
  translate([0, 0, SOLE_THICKNESS + E])
    sole(SOLE_THICKNESS, 0);
  translate([0, 0, 2 * SOLE_THICKNESS - 2 * STRAP_THICKNESS])
    for (i = [0 : NUM_HOLES - 1]) {
      translate([i * (LENGTH / NUM_HOLES), 0, 0])
        cube([STRAP_WIDTH, 2 * PAD_WIDTH, STRAP_THICKNESS], center=true);
    }
}

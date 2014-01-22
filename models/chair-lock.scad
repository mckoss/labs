// Adjustable wheelchair lock bracket.

use <Thread_Library.scad>

$fs=0.5;
$fa=3;

E = 0.01;
PI = 3.14159;
GAP = 0.5;
KNOB_GAP = 1.4;

SCREW_LENGTH = 35;
SCREW_PITCH = 3;

ATTACH_H = 60;
SCREW_HOLE_D = 6.6;
NUT_RADIUS = 12.6 / 2;
NUT_THICKNESS = 5.5;
SCREW_CENTERS = 33;

KNOB_R = 12;
MIN_R = KNOB_R / 2;
SCREW_R = 6;
KNOB_H = 5;
SHAFT_H = 5;

WALL = 1;

// Vertical checkpoints (stations)
S1 = KNOB_R - MIN_R - E;
S2 = S1 + KNOB_H - 2 * E;
S3 = S2 + KNOB_R - SCREW_R - 3 * E;
S4 = S3 + SHAFT_H - 4 * E;
S5 = S4 + SCREW_LENGTH - 5 * E;

RECEIVER_W = KNOB_R * 1.8;

module bolt() {
  knob();
  translate([0, 0, S4])
    trapezoidThread(length=SCREW_LENGTH,
                    pitchRadius=SCREW_R,
                    pitch=SCREW_PITCH);
}

module knob(gap=0) {
  cone(MIN_R + gap, KNOB_R + gap);
  translate([0, 0, S1])
    if (gap == 0) {
      knurled(KNOB_R + gap, KNOB_H);
    } else {
      cylinder(r=KNOB_R + gap, h=KNOB_H);
    }
  translate([0, 0, S2])
    cone(KNOB_R + gap, SCREW_R + gap);
  translate([0, 0, S3])
    cylinder(r=SCREW_R + gap, h=SHAFT_H);
}

module knurled(r, h, c=2.0) {
  count = floor(2 * PI * r / c);
  difference() {
    cylinder(r=r, h=h);
    for (i = [0: count - 1]) {
      rotate(a=i / count * 360, v=[0, 0, 1])
        translate([r, 0, h / 2])
          rotate(a=45, v=[0, 0, 1])
            cube([c/2, c/2, h + 2 * E], center=true);
    }
  }
}

module receiver() {
  s35 = S3 + (0.707 - 0.5) * RECEIVER_W;
  difference() {
    union() {
      pipe(RECEIVER_W, S5);
      translate([0, 0, S3])
        cone(RECEIVER_W * 0.5, RECEIVER_W * 0.707);
      translate([0, 0, s35])
        cylinder(r=RECEIVER_W * 0.707, h=S5 - s35);
    }
    translate([0, 0, -E])
      knob(KNOB_GAP);
    translate([0, 0, S4])
      pipe(RECEIVER_W - WALL * 2, SCREW_LENGTH + 2 * E);
  }
}

module piston() {
  difference() {
    pipe(RECEIVER_W - WALL * 2 - 2 * GAP, SCREW_LENGTH + ATTACH_H);
    trapezoidThreadNegativeSpace(length=SCREW_LENGTH,
                                 pitchRadius=SCREW_R,
                                 pitch=SCREW_PITCH);
    translate([0, 0, SCREW_LENGTH + ATTACH_H - 10])
      screw_hole();
    translate([0, 0, SCREW_LENGTH + ATTACH_H - 10 - SCREW_CENTERS])
      screw_hole();
  }
}

module screw_hole() {
  translate([-RECEIVER_W / 2 - E, 0, 0])
  rotate(a=90, v=[0, 1, 0]) {
    cylinder(r=SCREW_HOLE_D / 2, h=RECEIVER_W + 2 * E);
    cylinder(r=NUT_RADIUS, h=NUT_THICKNESS, $fn=6);
  }
}

module cone(from_r, to_r) {
  cylinder(r1=from_r, r2=to_r, h=abs(from_r - to_r));
}

module pipe(w, h) {
  translate([0, 0, h / 2])
    cube([w, w, h], center=true);
}


bolt();
receiver();
translate([30, 0, 0])
  piston();

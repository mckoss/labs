// Adjustable wheelchair lock bracket.

use <Thread_Library.scad>
$fs=1;
$fa=3;

E = 0.1;
PI = 3.14159;
GAP = 0.5;
KNOB_GAP = 1.5;

SCREW_LENGTH = 30;
SCREW_PITCH = 3;

ATTACH_H = 30;

KNOB_R = 8;
MIN_R = KNOB_R / 2;
SCREW_R = 4;
KNOB_H = 5;

WALL = 1;

// Vertical checkpoints (stations)
S1 = KNOB_R - MIN_R - E;
S2 = S1 + KNOB_H - 2 * E;
S3 = S2 + KNOB_R - SCREW_R - 3 * E;
S4 = S3 + SCREW_LENGTH - 4 * E;

RECEIVER_W = KNOB_R * 1.9;

module bolt() {
  knob();
  translate([0, 0, S3])
    trapezoidThread(length=SCREW_LENGTH,
                    pitchRadius=SCREW_R,
                    pitch=SCREW_PITCH);
}

module knob(gap=0) {
  cone(MIN_R + gap, KNOB_R + gap);
  translate([0, 0, S1])
    knurled(KNOB_R + gap, KNOB_H);
  translate([0, 0, S2])
    cone(KNOB_R + gap, SCREW_R + gap);
}

module knurled(r, h, c=1.0) {
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
  difference() {
    translate([0, 0, E])
      pipe(RECEIVER_W, S4);
    knob(KNOB_GAP);
    translate([0, 0, S3])
      pipe(RECEIVER_W - WALL * 2, SCREW_LENGTH + 2 * E);
  }
}

module piston() {
  difference() {
    pipe(RECEIVER_W - WALL * 2 - 2 * GAP, SCREW_LENGTH + ATTACH_H);
    trapezoidThreadNegativeSpace(length=SCREW_LENGTH,
                                 pitchRadius=SCREW_R,
                                 pitch=SCREW_PITCH);
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

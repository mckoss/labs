// Adjustable wheelchair lock bracket.

use <Thread_Library.scad>
$fs=1;
$fa=3;

E = 0.1;
SCREW_LENGTH = 30;
SCREW_PITCH = 3;
GAP = 0.5;

MIN_R = 1;
KNOB_R = 10;
SCREW_R = 4;
KNOB_H = 5;

WALL = 2;

// Vertical checkpoints (stations)
S1 = KNOB_R - MIN_R - E;
S2 = S1 + KNOB_H - 2 * E;
S3 = S2 + KNOB_R - SCREW_R - 3 * E;
S4 = S3 + SCREW_LENGTH - 4 * E;

RECEIVER_W = KNOB_R * 1.7;


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
    cylinder(r=KNOB_R + gap, h=KNOB_H);
  translate([0, 0, S2])
    cone(KNOB_R + gap, SCREW_R + gap);
}

module receiver() {
  difference() {
    pipe(RECEIVER_W, S4);
    knob(GAP);
    translate([0, 0, S3])
      pipe(RECEIVER_W - WALL * 2, SCREW_LENGTH + 2 * E);
  }
}

module cone(from_r, to_r) {
  cylinder(r1=from_r, r2=to_r, h=abs(from_r - to_r));
}

module pipe(w, h) {
  translate([0, 0, h / 2])
    cube([w, w, h], center=true);
}


/*
        trapezoidThreadNegativeSpace(length=cap_height - CAP_WALL - 2 * GAP,
                        pitchRadius=inner / 2 - RING_WIDTH - CAP_WALL,
                        countersunk=0,
                        pitch=PITCH,
                        clearance=THREAD_CLEARANCE);
*/

bolt();
receiver();
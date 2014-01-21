// Adjustable wheelchair lock bracket.

use <Thread_Library.scad>
$fs=1;
$fa=3;

E = 0.1;
SCREW_LENGTH = 50;
SCREW_PITCH = 3;
GAP = 1;

MIN_R = 1;
KNOB_R = 10;
BOLT_R = 5;
KNOB_H = 5;

WALL = 3;



module bolt() {
  cone(MIN_R, KNOB_R);
  s1 = KNOB_R - MIN_R;
  translate([0, 0, s1])
    cylinder(r=KNOB_R, h=KNOB_H);
  s2 = s1 + KNOB_H;
  translate([0, 0, s2])
    cone(KNOB_R, BOLT_R);
  s3 = s2 + KNOB_R - BOLT_R;
  translate([0, 0, s3])
    trapezoidThread(length=SCREW_LENGTH,
                    pitchRadius=BOLT_R,
                    pitch=SCREW_PITCH);
}

module cone(from_r, to_r) {
  cylinder(r1=from_r, r2=to_r, h=abs(from_r - to_r));
}

/*
        trapezoidThreadNegativeSpace(length=cap_height - CAP_WALL - 2 * GAP,
                        pitchRadius=inner / 2 - RING_WIDTH - CAP_WALL,
                        countersunk=0,
                        pitch=PITCH,
                        clearance=THREAD_CLEARANCE);
*/

bolt();
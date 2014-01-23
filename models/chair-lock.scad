// Adjustable wheelchair lock bracket.

use <Thread_Library.scad>

PART = "all"; // [all, receiver, piston, bracket]

$fs=0.5;
$fa=3;

E = 0.05;
PI = 3.14159;
INCH = 25.4;
GAP = 0.5;
KNOB_GAP = 1.4;

SCREW_LENGTH = 35;
SCREW_PITCH = 3;

ATTACH_H = 60;
SCREW_HOLE_D = 6.8;
NUT_W = 10.9;
NUT_H = 5.5;
SCREW_CENTERS = 33;

KNOB_R = 12;
MIN_R = KNOB_R / 2;
SCREW_R = 6;
KNOB_H = 5;
SHAFT_H = 5;

RECEIVER_W = KNOB_R * 1.8;
RECEIVER_BODY_W = RECEIVER_W * 1.414;

CHAIR_W = 1.26 * INCH;
BRACKET_WALL = 8;
BRACKET_SEP = 11;
BRACKET_GAP = 2;
BRACKET_SCREW_W = 6.2;

WALL = 1;

// Vertical checkpoints (stations)
S1 = KNOB_R - MIN_R - E;
S2 = S1 + KNOB_H - 2 * E;
S3 = S2 + KNOB_R - SCREW_R - 3 * E;
S4 = S3 + SHAFT_H - 4 * E;
S5 = S4 + SCREW_LENGTH - 5 * E;

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

module receiver() {
  s35 = S3 + 0.5 * (RECEIVER_BODY_W - RECEIVER_W);
  difference() {
    union() {
      pipe(RECEIVER_W, S5);
      translate([0, 0, S3])
        cone(RECEIVER_W / 2, RECEIVER_BODY_W / 2);
      translate([0, 0, s35])
        cylinder(r=RECEIVER_BODY_W / 2, h=S5 - s35);
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

module bracket() {
  height=SCREW_LENGTH;
  avg_width = (RECEIVER_BODY_W + CHAIR_W) / 2 + 2 * BRACKET_WALL;
  difference() {
    union() {
      translate([0, -RECEIVER_BODY_W / 2 - BRACKET_SEP / 2, 0])
        cylinder(r=RECEIVER_BODY_W / 2 + BRACKET_WALL, h=height);
      translate([0, CHAIR_W / 2 + BRACKET_SEP / 2, 0])
        cylinder(r=CHAIR_W / 2 + BRACKET_WALL, h=height);
      // BUG: hull not working with difference
      translate([0, 0, height / 2])
        cube([avg_width, (RECEIVER_BODY_W + CHAIR_W) / 2 + BRACKET_SEP, height], center=true);
    }
    translate([0, -RECEIVER_BODY_W / 2 - BRACKET_SEP / 2, -E]) {
      cylinder(r=RECEIVER_BODY_W / 2, h=height + 2 * E);
      wedge(a=20, r=RECEIVER_BODY_W, h=height + 2 * E, rot=-90);
    }
    translate([0, CHAIR_W / 2 + BRACKET_SEP / 2, -E]) {
      cylinder(r=CHAIR_W / 2, h=height + 2 * E);
      wedge(a=75, r=CHAIR_W, h=height + 2 * E, rot=110);
    }
    translate([0, 0, 9])
      screw_hole(hole_diam=BRACKET_SCREW_W, length=avg_width);
    translate([0, 0, height - 9])
      screw_hole(hole_diam=BRACKET_SCREW_W, length=avg_width);
    translate([0, 0, height / 2])
      cube([BRACKET_GAP, 2 * WALL + BRACKET_SEP, height + 2 * E], center=true);
  }
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

module screw_hole(hole_diam=SCREW_HOLE_D, length=RECEIVER_W, nut_w=NUT_W, nut_h=NUT_H) {
  translate([-length / 2 - E, 0, 0])
  rotate(a=90, v=[0, 1, 0]) {
    cylinder(r=hole_diam / 2 + GAP / 2, h=length + 2 * E);
    cylinder(r=hex_radius(nut_w + GAP), h=nut_h, $fn=6);
  }
}

function hex_radius(w) = w * (1 + 2 * cos(60)) / (2 * sin(60)) / 2;

module cone(from_r, to_r) {
  cylinder(r1=from_r, r2=to_r, h=abs(from_r - to_r));
}

module pipe(w, h) {
  translate([0, 0, h / 2])
    cube([w, w, h], center=true);
}

module wedge(a, r, h, rot=0) {
  rotate(a=rot, v=[0, 0, 1])
    linear_extrude(height=h)
      polygon(points=[[0, 0], [r * cos(a / 2), -r * sin(a / 2)], [r * cos(a / 2), r * sin(a / 2)]]);
}

if (PART == "receiver" || PART == "all") {
  bolt();
  receiver();
}

if (PART == "piston" || PART == "all") {
  translate([50, 0, 0])
    piston();
}

if (PART == "bracket" || PART == "all") {
  translate([-50, 0, 0])
  bracket();
}

// Flame badge
// Copyright (c) 2106

$fs = 0.5;
E = 0.01;

INCH = 25.4;
GAP = 0.5;

// Flame control points
X_MAX = 1 * INCH;
X_MIN = -X_MAX;

Y_MIN = -0.6 * INCH;

FLARE_IN = 0.4 * INCH;

X_MAJOR = X_MIN + FLARE_IN;
Y_MAJOR = 2.0 * INCH;
Z_MAJOR = INCH / 8;

X_MINOR = X_MAX - FLARE_IN;
Y_MINOR = 1.6 * INCH;
Z_MINOR = INCH / 3;

// Magnetic clasp dimenisions
BACK_R = INCH / 8 + GAP;
BACK_H = INCH / 16 + GAP;
echo("Back diameter", BACK_R * 2);

difference() {
  scale(0.8)
    flame();
  # translate([0, 15, BACK_H / 2 - E])
    cylinder(r=BACK_R, h=BACK_H, center=true, $fn=16);
}

module flame() {
  union() {
    round_it()
      major_flame();
    round_it()
      minor_flame();
  }
}

// Clockwise 5 basic control points
//     1-5  2-6
//    /\  /\
//   |  \/ |
// 0 -_   _-3
//     -_-
//      4
P0 = [X_MIN, 0, 0];
P1_BASE = [X_MAJOR, Y_MAJOR - Z_MAJOR, 0];
P1_PEAK = [X_MAJOR, Y_MAJOR, Z_MAJOR];
P2_BASE = [X_MINOR, Y_MINOR - Z_MINOR, 0];
P2_PEAK = [X_MINOR, Y_MINOR, Z_MINOR];
P3 = [X_MAX, 0, 0];
P4 = [0, Y_MIN, 0];

module major_flame() {
  polyhedron(
    points = [P0, P1_BASE, P2_BASE, P3, P4,
              P1_PEAK, P2_PEAK],
    faces = [
      [0, 4, 3], [0, 3, 1],  // Bottom
      [0, 1, 5], [3, 5, 1],  // Sides
      [0, 5, 4], [4, 5, 3]   // Top
    ]
  );
}

module minor_flame() {
  polyhedron(
    points = [P0, P1_BASE, P2_BASE, P3, P4,
              P1_PEAK, P2_PEAK],
    faces = [
      [0, 4, 3], [0, 3, 2],  // Bottom
      [0, 2, 6], [3, 6, 2],  // Sides
      [0, 6, 4], [4, 6, 3]   // Top
    ]
  );
}

module round_it() {
  minkowski() {
    cylinder(r1=1, r2=0, h=1.5, $fn=16);
    children();
  }
}

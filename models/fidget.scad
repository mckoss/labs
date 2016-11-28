// Fidget Spinner
// by Mike Koss (c) 2016

PART = "spinner"; // [spinner, caps]

// Setup and constants
E = 0.1;

// 608 Bearing - weight = 10g;
BEARING_INNER = 8;
BEARING_OUTER = 22;
BEARING_HEIGHT = 7;

// US Nickel - weight = 5g
COIN_SLOP = 0.3;
COIN_OUTER = 21.3 + COIN_SLOP;
COIN_HEIGHT = 1.9;
COIN_STACK = 3;

STACK_HEIGHT = 1.9 * COIN_STACK;
COIN_FLOOR_HEIGHT = 1;
COIN_WINDOW = COIN_OUTER / 2;

ARM_OFFSET = 1.5 * BEARING_OUTER;

WALL_THICKNESS = 5;

if (PART == "spinner") {
  difference() {
    spinner(true);
    spinner(false);
  }
}

if (PART == "caps") {
  for (i = [0:1]) {
    translate([-15 + i * 30, 0, 0]) {
      rotate(v=[1, 0, 0], a=180) {
        cap();
      }
    }
  }
}

module cap() {
  CAP_OUTER = BEARING_OUTER;
  CAP_HEIGHT = BEARING_HEIGHT / 2;

  RING_HEIGHT = 1;
  RING_OUTER = BEARING_INNER + 4;
  RING_OFFSET = -CAP_HEIGHT / 2;

  AXEL_HEIGHT = BEARING_HEIGHT / 2 - 0.2;
  AXEL_OUTER = BEARING_INNER;
  AXEL_OFFSET = RING_OFFSET - RING_HEIGHT / 2;

  union() {
    filledTorus(CAP_HEIGHT, CAP_OUTER / 2);
    translate([0, 0, RING_OFFSET - RING_HEIGHT / 2 + E]) {
      cylinder(h=RING_HEIGHT + E, r=RING_OUTER / 2, center=true, $fn=32);
    }
    translate([0, 0, AXEL_OFFSET - AXEL_HEIGHT / 2 + E]) {
      cylinder(h=AXEL_HEIGHT + E, r=AXEL_OUTER / 2, center=true, $fn=32);
    }
  }
}

// When pos == true - emit the positive parts of the model.
// When pos == false - emit the negative (subtracted) parts.
module spinner(pos) {
  center(pos);

  for (i = [0:3]) {
    rotate(v=[0, 0, 1], a=120*i) {
      arm(pos);
    }
  }
}

module center(pos) {
  enclosure(pos, BEARING_HEIGHT, BEARING_OUTER / 2 + WALL_THICKNESS, BEARING_OUTER / 2);
}

module end(pos) {
  if (pos) {
    enclosure(pos,
              STACK_HEIGHT + 2 * COIN_FLOOR_HEIGHT,
              COIN_OUTER / 2 + WALL_THICKNESS,
              COIN_OUTER / 2);
    cylinder(h=STACK_HEIGHT + COIN_FLOOR_HEIGHT, r=COIN_OUTER / 2, center=true);
  } else {
    translate([0, 0, COIN_FLOOR_HEIGHT]) {
      cylinder(h=STACK_HEIGHT + E, r=COIN_OUTER / 2, center=true);
    }
  }
}

module arm(pos) {
  armConnector(pos);
  translate([0, ARM_OFFSET, 0]) {
    end(pos);
  }
}

module armConnector(pos) {
  if (pos) {
    armConnectorHalf();
    mirror([1, 0, 0]) {
      armConnectorHalf();
    }
  }
}

module armConnectorHalf() {
  rBearing = BEARING_OUTER / 2 + WALL_THICKNESS;
  rArm = BEARING_OUTER * 0.7;
  rotate(v=[0, 0, 1], a=-47) {
    translate([0, rBearing + rArm - BEARING_HEIGHT, 0]) {
      rotate(v=[0, 0, 1], a=180) {
        intersection() {
          torus(BEARING_HEIGHT, rArm);
          translate([50, 50, 0]) {
            cube([100, 100, 100], center=true);
          }
        }
      }
    }
  }
}

module enclosure(pos, height, outer, inner) {
  if (pos) {
    torus(height, outer);
  } else {
    cylinder(h=height + 2 * E, r=inner, center=true);
  }
}

module filledTorus(h, r) {
  torus(h, r);
  cylinder(h=h, r=r - h/2, center=true);
}

module torus(h, r) {
  rotate_extrude(convexity=10 , $fn=60) {
    translate([r - h / 2, 0, 0]) {
      circle(r=h / 2, $fn=30);
    }
  }
}

// Fidget Spinner
// by Mike Koss (c) 2016

// Setup and constants
E = 0.1;

// 608 Bearing - weight = 10g;
BEARING_INNER = 8;
BEARING_OUTER = 22;
BEARING_HEIGHT = 7;

// US Nickel - weight = 5g
COIN_OUTER = 21.2;
COIN_HEIGHT = 1.9;
COIN_STACK = 3;
COIN_COVER_HEIGHT = 2;
COIN_WINDOW = COIN_OUTER - 2;

STACK_HEIGHT = 1.9 * COIN_STACK;

ARM_OFFSET = 2 * BEARING_OUTER;

WALL_THICKNESS = 5;

difference() {
  spinner(true);
  spinner(false);
}

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
  enclosure(pos,
            2 * COIN_COVER_HEIGHT + STACK_HEIGHT,
            COIN_OUTER / 2 + WALL_THICKNESS,
            COIN_OUTER / 2);
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
  rArm = BEARING_OUTER;
  rotate(v=[0, 0, 1], a=-44) {
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

module torus(h, r) {
  rotate_extrude(convexity=10 , $fn=60) {
    translate([r - h / 2, 0, 0]) {
      circle(r=h / 2, $fn=30);
    }
  }
}

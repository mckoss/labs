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
STACK_COUNT = 3;
STACK_HEIGHT = 1.9 * STACK_COUNT;

COIN_FLOOR_HEIGHT = BEARING_HEIGHT - STACK_HEIGHT;
COIN_WINDOW = COIN_OUTER / 2;

WALL_THICKNESS = 5;

ARM_OFFSET = BEARING_OUTER + WALL_THICKNESS / 2;

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

if (PART == "torus120") {
  torus120(BEARING_HEIGHT, BEARING_OUTER / 2 + WALL_THICKNESS);
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

  for (i = [0:3]) {
    rotate(v=[0, 0, 1], a=120*i + 60) {
      connector(pos);
    }
  }
}

module center(pos) {
  enclosure(pos, BEARING_HEIGHT, BEARING_OUTER / 2 + WALL_THICKNESS, BEARING_OUTER / 2);
}

module arm(pos) {
  translate([0, ARM_OFFSET, 0]) {
    end(pos);
  }
}

module end(pos) {
  enclosure(pos,
            BEARING_HEIGHT,
            BEARING_OUTER / 2 + WALL_THICKNESS,
            COIN_OUTER / 2,
            COIN_FLOOR_HEIGHT);
}

module connector(pos) {
  translate([0, ARM_OFFSET, ]) {
    if (pos) {
      torus120(BEARING_HEIGHT, BEARING_OUTER / 2 + WALL_THICKNESS);
    }
  }
}

module enclosure(pos, height, outer, inner, offset=0) {
  if (pos) {
    filledTorus(height, outer);
  } else {
    translate([0, 0, offset == 0 ? 0 : offset + E]) {
      cylinder(h=height + 2 * E, r=inner, center=true);
    }
  }
}

module filledTorus(h, r) {
  torus(h, r);
  cylinder(h=h, r=r - h/2, center=true);
}

module torus120(h, r) {
  difference() {
    torus(h, r);
    for (i=[0:6]) {
      rotate(v=[0, 0 ,1], a=30 * i - 90) {
        translate([0, r, 0]) {
          rotate(v=[0, 0, 1], a=30) {
            cylinder(h=h, r=r, $fn=3, center=true);
          }
        }
      }
    }
  }
}

module torus(h, r) {
  rotate_extrude(convexity=10 , $fn=60) {
    translate([r - h / 2, 0, 0]) {
      circle(r=h / 2, $fn=30);
    }
  }
}

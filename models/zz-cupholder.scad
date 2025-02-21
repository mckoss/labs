// ZZ's Cupholder

INCH = 25.4;

ARM_WIDTH = 40;
ARM_CENTER = 20;

WING_WIDTH = (ARM_WIDTH - ARM_CENTER)/2;

// Cup Holder dimensions
CUP_R1 = 93/2;
CUP_R2 = 72/2;
CUP_H = 80;

// Phone pocket dimensions
PHONE_THICKNESS = 16;
PHONE_WIDTH = 90;
PHONE_HEIGHT = 180;

// Tray dimensions
TRAY_LENGTH = 8 * INCH;
TRAY_WIDTH = 4 * INCH + 1.7 * ARM_WIDTH;

// Wall thickness
THICKNESS = 3;

TRAY_LIP = 0;

$fn = 180;

E = 0.1;

module tray_and_cupholder() {
  PHONE_OFFSET = [-CUP_R1 - PHONE_THICKNESS, 0, 0];
  difference() {
    union() {
      translate([18, 31, 0]) {
        tray();
      }
      cup_holder(true);
      translate(PHONE_OFFSET)
        phone_holder(true);
    }
    union() {
      cup_holder(false);
      translate(PHONE_OFFSET)
        phone_holder(false);
    }
  }
}

// Cup top is at z == 0
// Use difference of cup_holder(true) and cup_holder(false)
// to embed in another part.
module cup_holder(positive) {
    translate([0, 0, -CUP_H/2])
    rotate([180, 0, 0])
    if (positive) {
        cylinder(CUP_H, r1=CUP_R1, r2=CUP_R2, center=true);
    } else {
        translate([0, 0, -THICKNESS])
            cylinder(CUP_H, r1=CUP_R1-THICKNESS, r2=CUP_R2-THICKNESS, center=true);
        // Drain hole
        cylinder(CUP_H*2, r=20, center=true);
    }
}

module phone_holder(positive) {
  D = 2 * THICKNESS;
  H = PHONE_HEIGHT/2 + D/2;
  translate([0, 0, -H/2])
  if (positive) {
      cube([PHONE_THICKNESS + D, PHONE_WIDTH + D, H], center=true);
  } else {
      translate([0, 0, THICKNESS])
        cube([PHONE_THICKNESS, PHONE_WIDTH, H], center=true);
            // Drain hole
      cylinder(2*H, r=PHONE_THICKNESS/2 - E, center=true);
  }
}

module tray() {
  W = THICKNESS + TRAY_LIP;
  difference() {
    translate([0, 0, W/2 - THICKNESS])
      cube([TRAY_LENGTH, TRAY_WIDTH, W], center=true);
    translate([0, 0, W/2])
      cube([TRAY_LENGTH - W, TRAY_WIDTH - W, W], center=true);
  }
  translate([0, TRAY_WIDTH/2, -THICKNESS+E])
    arm_hook(TRAY_LENGTH/2);
}

// Connection at outer edge of origin
module arm_hook(w) {
  T = 2 * THICKNESS;
  rotate([90, 0, 0])
  rotate([0, 90, 0])
  linear_extrude(w, center=true) {
    polygon([[0, E], [-T, E], [-T, -10], [-T-ARM_WIDTH/2, -15],
      [-T-ARM_WIDTH/2, -15-T], [0, -10-T]]);
    polygon([[-T-ARM_WIDTH, E], [-2*T-ARM_WIDTH, E],
      [-2*T-ARM_WIDTH, -3*THICKNESS],
      [-T-ARM_WIDTH, -3*THICKNESS]]);
  }
}

rotate([180, 0, 0])
tray_and_cupholder();


// M-94 Cipher Device
//
// Version 0.1
// All dimensions in mm.
// by Mike Koss, 2013
// License: CC-Attribution.

// Disk dimensions
OD = 36.5;
ID = OD - 2.0;
H = 3.53;
T = 1.0;

// Axle dimensions
A = 6.15;
ID_A = A + 0.1;
OD_A = 12.67;

// Sprocket dimensions
R_S = OD / 2 - 1.0;
R_S2 = R_S - 2.8;
R_S3 = R_S - 5.2;
H_S = 1.0;
// Sprocket and peg width
W_S = 2.46;
W_P = 1.00;
L_P = 2.00;
H_P = H - 0.5;

module sprockets() {
  union() {
    // Ring
    difference() {
      cylinder(h=H_S, r=R_S2, $fa=1, $fs=1);
      translate([0, 0, -H_S/2])
        cylinder(h=H_S * 2, r1=R_S3 - 1.0, r2=R_S3, $fa=1, $fs=1);
    }

    // Sprockets
    for (i = [0 : 25]) {
      rotate(a=360 * i / 26, v=[0, 0, 1])
        translate([R_S3, -W_S / 2, 0])
        cube([R_S - R_S3, W_S, H_S]);
    }

    // Peg
    rotate(a=360/26/2, v=[0, 0, 1])
      translate([ID / 2 - L_P, -W_P / 2, -H_P])
      cube([L_P, W_P, H_P]);
  }
}

module disk(letters) {
  union() {
    difference() {
      cylinder(h=H, r=OD / 2, $fa=1, $fs=1);
      translate([0,0,-T]) difference () {
        cylinder(h=H, r=ID / 2, $fa=1, $fs=1);
        cylinder(h=H, r=OD_A / 2, $fa=1, $fs=1);
      }
      // Axle hole
      translate([0, 0, -H/2]) scale([1, 1, 2])
        cylinder(h=H, r=ID_A / 2, $fa=1, $fs=1);
    }
    translate([0, 0, H])
      sprockets();
  }
}

disk("ABCDEFGHIJKLMNOPQRSTUVWXYZ");

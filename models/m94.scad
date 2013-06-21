// M-94 Cipher Device Model
//
// Version 0.2
// All dimensions in mm.
// by Mike Koss, 2013
// License: CC-Attribution.

use <write.scad>

// When true - copies details from the authentic M-94
REPLICA = true;
WHEEL = 17;

wheels = ["ABCEIGDJFVUYMHTQKZOLRXSPWN",
          "ACDEHFIJKTLMOUVYGZNPQXRWSB",
          "ADKOMJUBGEPHSCZINXFYQRTVWL",
          "AEDCBIFGJHLKMRUOQVPTNWYXZS",
          "AFNQUKDOPITJBRHCYSLWEMZVXG",
          "AGPOCIXLURNDYZHWBJSQFKVMET",
          "AHXJEZBNIKPVROGSYDULCFMQTW",
          "AIHPJOBWKCVFZLQERYNSUMGTDX",
          "AJDSKQOIVTZEFHGYUNLPMBXWCR",
          "AKELBDFJGHONMTPRQSVZUXYWIC",
          "ALTMSXVQPNOHUWDIZYCGKRFBEJ",
          "AMNFLHQGCUJTBYPZKXISRDVEWO",
          "ANCJILDHBMKGXUZTSWQYVORPFE",
          "AODWPKJVIUQHZCTXBLEGNYRSMF",
          "APBVHIYKSGUENTCXOWFQDRLJZM",
          "AQJNUBTGIMWZRVLXCSHDEOKFPY",
          "ARMYOFTHEUSZJXDPCWGQIBKLNV",
          "ASDMCNEQBOZPLGVJRKYTFUIWXH",
          "ATOJYLFXNGWHVCMIRBSEKUPDZQ",
          "AUTRZXQLYIOVBPESNHJWMDGFCK",
          "AVNKHRGOXEYBFSJMUDQCLZWTIP",
          "AWVSFDLIEBHKNRJQZGMXPUCOTY",
          "AXKWREVDTUFOYHMLSIQNJCPGBZ",
          "AYJPXMVKBQWUGLOSTECHNZFRID",
          "AZDNBUHYFWJLVGRCQMPSOEXTKI"
         ];

// Disk dimensions
OD = 36.5;
WALL_WIDTH = REPLICA ? 1.0 : 3.0;
R_O = OD / 2;
R_I = R_O - WALL_WIDTH;
H = 3.53;
T = 1.0;

LETTER_SIZE = 3.5;

// Axle dimensions
A = 6.15;
ID_A = A + 0.1;
OD_A = 12.67;
R_A = OD_A / 2;

// Sprocket dimensions
R_S = R_O - 1.0;
R_S2 = R_S - 2.8;
R_S3 = R_S - 5.2;
H_S = 1.0;

// Sprocket and peg width
W_S = 2.46;
W_P = 1.00;
L_P = 2.00;
H_P = H - 0.5;

// Alignment bar dimensions
B_W = 6.5;
B_H = 4.4;
B_H2 = 2.3;

// M-94 has a set of interlocking sprockets that engage a peg on the
// underside of the wheel to the left.
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
      translate([R_I - L_P, -W_P / 2, -H_P])
      cube([L_P, W_P, H_P]);
  }
}

module spokes(n) {
  for (i = [0 : n -1]) {
    rotate(a=360 * i / n, v=[0, 0, 1])
      translate([R_A - 1, -1, 0])
      cube([R_I - R_A + 2, 2, H]);
  }
}

module basicDisk() {
  difference() {
    cylinder(h=H, r=R_O, $fa=1, $fs=1);

    if (REPLICA) {
      translate([0, 0, -T]) difference () {
        cylinder(h=H, r=R_I, $fa=1, $fs=1);
        cylinder(h=H, r=R_A, $fa=1, $fs=1);
      }
    } else {
      translate([0, 0, -H/2]) scale([1, 1, 2]) difference () {
        cylinder(h=H, r=R_I, $fa=1, $fs=1);
        cylinder(h=H, r=R_A, $fa=1, $fs=1);
      }
    }
  }
  if (!REPLICA) {
    spokes(3);
  }
}

module disk(letters) {
  union() {
    difference() {
      basicDisk();

      // Axle hole
      translate([0, 0, -H/2]) scale([1, 1, 2])
        cylinder(h=H, r=ID_A / 2, $fa=1, $fs=1);

      // Etched letters
      alpha(letters);
    }

    translate([0, 0, H])
      if (REPLICA) {
        sprockets();
      }
  }
}

module alpha(letters) {
  for (i = [0 : len(letters) - 1]) {
    rotate(a=360 * (1 - i / 26), v=[0, 0, 1])
      translate([R_I + WALL_WIDTH, 0, H / 2])
      rotate(a=90, v=[0, 1, 0])
      write(letters[i], h=LETTER_SIZE, t=WALL_WIDTH, center=true);
  }
}

// Wheel 1 through 25
module wheel(i) {
  if (i == 0) {
    bar();
  } else {
    disk(wheels[i - 1]);
  }
}

// Alignment bar
module bar() {
  disk("");
  translate([R_O - .25, 0, H])
    rotate(a=90, v=[0, 1, 0])
    difference() {
      polyhedron(
        points=[ [0, -B_W / 2, 0], [0, 0, B_H], [0, B_W / 2, 0],
                 [26 * H, -B_W / 2, 0], [26 * H, 0, B_H2], [26 * H, B_W / 2, 0]
               ],
        triangles=[ [0, 2, 1],
                    [0, 1, 4], [4, 3, 0],
                    [3, 4, 5],
                    [5, 4, 1], [1, 2, 5],
                    [0, 3, 5], [5, 2, 0] ]
      );
      union() {
        for (i = [1 : 4]) {
          translate([(5 * i + 1) * H, B_W / 2 - 1, -B_H])
            cube([0.5, 2, 2 * B_H]);
        }
      }
    }
}

// Render the "special" wheel as a sample.
wheel(WHEEL);

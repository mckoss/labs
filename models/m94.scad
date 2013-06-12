// M-94 Cipher Device Model
//
// Version 0.1
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

      if (REPLICA) {
        translate([0,0,-T]) difference () {
          cylinder(h=H, r=ID / 2, $fa=1, $fs=1);
          cylinder(h=H, r=OD_A / 2, $fa=1, $fs=1);
        }
      }

      // Axle hole
      translate([0, 0, -H/2]) scale([1, 1, 2])
        cylinder(h=H, r=ID_A / 2, $fa=1, $fs=1);

      // Etched letters
      alpha(letters);
    }

    if (REPLICA) {
      translate([0, 0, H])
        sprockets();
    }
  }
}

module alpha(letters) {
  for (i = [0 : len(letters) - 1]) {
    rotate(a=360 * (1 - i / 26), v=[0, 0, 1])
      translate([OD / 2 - 0.5, 0, H / 2])
      rotate(a=90, v=[0, 1, 0])
      write(letters[i], h=3.0, t=1.0, center=true);
  }
}

// Wheel 1 through 25
module wheel(i) {
  disk(wheels[i - 1]);
}

module exploded_wheels() {
  for (i = [1:25]) {
    translate([0, 0, -2 * H * i])
      wheel(i);
  }
}

// Render the "special" wheel as a sample.
wheel(WHEEL);

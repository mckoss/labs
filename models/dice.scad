// Parametric Dice Maker
// by Mike Koss (c) 2015

// This font not working for embossing?
//use <spiff.scad>
//CHAR_WIDTH = 6.6;
//CHAR_HEIGHT = 10;

PARTS = 12; // [4, 6, 8, 12, 20]

use <write/Write.scad>
CHAR_WIDTH = 3;
CHAR_HEIGHT = 4.1;
//write("12345", center=true);
//% cube(CHAR_WIDTH, center=true);

R = 50;
EMBOSS = 4;

$fa=3;
$fs=1;
E = 0.1;

if (PARTS == 4)
  difference() {
    die(FACES_4);
    labels(FACES_4);
  }

if (PARTS == 6)
  difference() {
    die(FACES_6, 0.25);
    labels(FACES_6, 0.25, symbols=vowels);
  }

if (PARTS == 8)
  difference() {
    die(FACES_8, 0.25);
    labels(FACES_8, 0.25);
  }

if (PARTS == 12)
  reorient(FACES_12[0], sgn=-1)
  difference() {
    die(FACES_12, 0.15);
    labels(FACES_12, 0.15);
  }

if (PARTS == 20)
  difference() {
    die(FACES_20, 0.12);
    labels(FACES_20, 0.12, symbols=consonants);
  }

module die(faces, shave=0.2, r=R) {
  fontSize = 1.0 * r * sin(acos(1-shave));
  difference() {
    sphere(r=r);
    for (i = [0 : len(faces) - 1]) {
      reorient(faces[i])
        translate([0, 0, 2*r + E  - shave*r])
          cube(2*r + E, center=true);
    }
  }
}

module labels(faces, shave=0.2, r=R, symbols=digits) {
  fontSize = 1.0 * r * sin(acos(1-shave));
  for (i = [0 : len(faces) - 1]) {
    reorient(faces[i])
      translate([0, 0, r - shave*r - EMBOSS + E])
        scale([fontSize/CHAR_HEIGHT, fontSize/CHAR_HEIGHT, EMBOSS])
          translate([-CHAR_WIDTH/2*len(symbols[i]), -CHAR_HEIGHT/2, 0])
            write(symbols[i]);
  }
}

// Re-orient child from z (up) vector to first argument.
// Reverse the orientation if sgn == -1.
module reorient(v, sgn=1) {
  d = dist(v);
  ang = acos([0, 0, 1]*v/d);
  v = (ang > 179.9) ? [0, 1, 0] : cross([0, 0, 1], v/d);
  rotate(a=ang*sgn, v=v)
    child();
}

function dist(pos) = sqrt(pos * pos);

digits = [
  "1", "2", "3", "4", "5", "6", "7", "8", "9",
  "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
  "20"
];

PHI = (1 + sqrt(5))/2;

FACES_4 = [
  [1, 1, 1],
  [1, -1, -1],
  [-1, 1, -1],
  [-1, -1, 1]
];

FACES_6 = [
  [1, 0, 0], [0, 1, 0], [-1, 0, 0],
  [0, -1, 0], [0, 0, 1], [0, 0, -1]
];

FACES_8 = [
  [-1, -1, -1], [-1, -1, 1], [-1, 1, -1], [-1, 1, 1],
  [1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1]
];

FACES_12 = [
  [0, -1, -PHI], [0, 1, -PHI], [0, -1, PHI], [0, 1, PHI],
  [-1, -PHI, 0], [-1, PHI, 0], [1, -PHI, 0], [1, PHI, 0],
  [-PHI, 0, -1], [-PHI, 0, 1], [PHI, 0, -1], [PHI, 0, 1],
];

FACES_20 = [
  [-1, -1, -1], [-1, -1, 1], [-1, 1, -1], [-1, 1, 1],
  [1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1],
  [0, -1/PHI, -PHI], [0, -1/PHI, PHI], [0, 1/PHI, -PHI], [0, 1/PHI, PHI],
  [-1/PHI, -PHI, 0], [-1/PHI, PHI, 0], [1/PHI, -PHI, 0], [1/PHI, PHI, 0],
  [-PHI, 0, -1/PHI], [-PHI, 0, 1/PHI], [PHI, 0, -1/PHI], [PHI, 0, 1/PHI]
];

vowels = "AEIOUY";
consonants = "BCDFGHJKLMNPQRSTVWXZ";

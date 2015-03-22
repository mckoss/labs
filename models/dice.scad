// Parametric Dice Maker
// by Mike Koss (c) 2015

// This font not working for embossing?
//use <spiff.scad>
//CHAR_WIDTH = 6.6;
//CHAR_HEIGHT = 10;

PART = "ALL"; // ["4", "6", "6a", "8", "12", "20", "20a", "ALL"]

use <write/Write.scad>
CHAR_WIDTH = 3;
CHAR_HEIGHT = 4.1;
//write("12345", center=true);
//% cube(CHAR_WIDTH, center=true);

R = 50;
EMBOSS = 4;
PART_SPACING = 2.2 * R;

$fa=3;
$fs=1;
E = 0.1;

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

digits = [
  "1", "2", "3", "4", "5", "6", "7", "8", "9",
  "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
  "20"
];

vowels = "AEIOUY";
consonants = "BCDFGHJKLMNPQRSTVWXZ";

manifest = [
  ["4", FACES_4, 0.2, digits],
  ["6", FACES_6, 0.25, digits],
  ["6a", FACES_6, 0.25, vowels],
  ["8", FACES_8, 0.25, digits],
  ["12", FACES_12, 0.15, digits],
  ["20", FACES_20, 0.12, digits],
  ["20a", FACES_20, 0.12, consonants],
];

build();

//
// Build one (or all) parts (according to PART global).
//
module build() {
  for (i = [0 : len(manifest) - 1]) {
    if (PART == "ALL" || PART == manifest[i][0]) {
      if (PART == "ALL") {
        grid(i, len(manifest), PART_SPACING)
        buildPart(manifest[i][0], manifest[i][1], manifest[i][2], manifest[i][3]);
      } else {
        buildPart(manifest[i][0], manifest[i][1], manifest[i][2], manifest[i][3]);
      }
    }
  }
}

module buildPart(name, faces, shave, symbols) {
  echo(str("Printing PART=", name));
  reorient(faces[0], sgn=-1)
  difference() {
    die(faces, shave);
    labels(faces, shave, symbols=symbols);
  }
}

//
// Layout n parts in a grid.
//
module grid(i, n, spacing) {
  d = ceil(sqrt(n));
  translate([-spacing * (d - 1) / 2, -spacing * (d - 1) / 2, 0])
    translate([(i % d) * spacing, floor(i / d) * spacing, 0])
      children();
}

//
// Make a die given the face normals.
//
// shave is % of radius to truncate the basic sphere of a die.
//
module die(faces, shave=0.2, r=R) {
  difference() {
    sphere(r=r);
    for (i = [0 : len(faces) - 1]) {
      reorient(faces[i])
        translate([0, 0, 2*r + E  - shave*r])
          cube(2*r + E, center=true);
    }
  }
}

//
// Make a platonic solid circumscribing a sphere of radius r.
//
module solid(faces, r=R) {
  difference() {
    sphere(r=3*r);
    for (i = [0 : len(faces) - 1]) {
      reorient(faces[i])
        translate([0, 0, 5*r + r])
          cube(10*r + E, center=true);
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
    children();
}

function dist(pos) = sqrt(pos * pos);

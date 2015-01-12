// Dice
// http://en.wikipedia.org/wiki/Platonic_solid
// by Mike Koss (c) 2014

use <spiff.scad>
CHAR_WIDTH = 6.6;
CHAR_HEIGHT = 10;


SIDES = 20; // [4, 6, 8, 12, 20]

R = 50;
EMBOSS = 4;
PHI = (1 + sqrt(5))/2;
E = 0.1;

$fa=3;
$fs=1;

if (SIDES == 4)
  die([
      [1, 1, 1],
      [1, -1, -1],
      [-1, 1, -1],
      [-1, -1, 1]
    ]);

if (SIDES == 6)
  die([
      [1, 0, 0], [0, 1, 0], [-1, 0, 0],
      [0, -1, 0], [0, 0, 1], [0, 0, -1]
    ],
    .3,
    symbols=vowels);

if (SIDES == 8)
  die([
      [-1, -1, -1], [-1, -1, 1], [-1, 1, -1], [-1, 1, 1],
      [1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1]
    ],
    0.25);

if (SIDES == 12)
  die([
      [0, -1, -PHI], [0, 1, -PHI], [0, -1, PHI], [0, 1, PHI],
      [-1, -PHI, 0], [-1, PHI, 0], [1, -PHI, 0], [1, PHI, 0],
      [-PHI, 0, -1], [-PHI, 0, 1], [PHI, 0, -1], [PHI, 0, 1],
    ],
    0.15);

if (SIDES == 20)
  die([
      [-1, -1, -1], [-1, -1, 1], [-1, 1, -1], [-1, 1, 1],
      [1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1],
      [0, -1/PHI, -PHI], [0, -1/PHI, PHI], [0, 1/PHI, -PHI], [0, 1/PHI, PHI],
      [-1/PHI, -PHI, 0], [-1/PHI, PHI, 0], [1/PHI, -PHI, 0], [1/PHI, PHI, 0],
      [-PHI, 0, -1/PHI], [-PHI, 0, 1/PHI], [PHI, 0, -1/PHI], [PHI, 0, 1/PHI]
    ],
    0.12,
    symbols=consonants);

module die(faces, shave=0.2, r=R, symbols=digits) {
  d = dist(faces[0]);
  fontSize = 1.0 * r * sin(acos(1-shave));
  difference() {
    sphere(r=r);
    for (i = [0 : len(faces) - 1]) {
      assign(ang = acos([0, 0, 1]*faces[i]/d)) {
        assign(v = (ang > 179.9) ? [0, 1, 0] : cross([0, 0, 1], faces[i]/d)) {
          rotate(a=ang, v=v)
            union() {
              translate([0, 0, r - shave*r - EMBOSS + E])
                scale([fontSize/CHAR_HEIGHT, fontSize/CHAR_HEIGHT, EMBOSS])
                translate([-CHAR_WIDTH/2*len(symbols[i]), -CHAR_HEIGHT/2, 0])
                  write(symbols[i]);
              translate([0, 0, 2*r + E  - shave*r])
                cube(2*r + E, center=true);
            }
        }
      }
    }
  }
}

function dist(pos) = sqrt(pos * pos);

digits = [
  "1", "2", "3", "4", "5", "6", "7", "8", "9",
  "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
  "20"
];

vowels = "aeiouy";
consonants = "bcdfghjklmnpqrstvwxz";

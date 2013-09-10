$fa = 3;
$fs = 1;

E = 0.1;
OUTER = 100;
INNER = 50;
WIDTH = 5;
INSET = 0.8;

WATER_HEIGHT = 30;
PLAQUE_HEIGHT = 10;
ETCH_DEPTH = 2;


module ring(height) {
  difference() {
   cylinder(r=OUTER/2, h=height);
   translate([0, 0, -E])
     cylinder(r=OUTER/2 - WIDTH, h=height + 2 * E);
  }
}

module fountain_part(height=1, side=0, line=false, curve=false) {
  long = 2 * sqrt(pow(OUTER / 2, 2) - pow(INNER / 2, 2));

  rotate(a=-90 * side, v=[0, 0, 1])
  difference() {
    union () {
      if (curve) {
        ring(height);
      }
      if (line) {
        translate([0, INNER / 2 - WIDTH / 2, height / 2])
          cube([long - 2 * E, WIDTH, height], center=true);
      }
      if (!line && !curve) cube(1);
     }
    translate([0, -OUTER / 2 + INNER / 2 - WIDTH, height / 2])
      cube([OUTER + 2 * E, OUTER + 2 * E, height + 2 * E], center=true);
  }
}

module base() {
  translate([0, 0, ETCH_DEPTH + E])
  difference() {
     translate([0, 0, -PLAQUE_HEIGHT / 2])
       cube([OUTER * 1.3, OUTER * 1.3, PLAQUE_HEIGHT], center=true);
     translate([0, 0, -ETCH_DEPTH])
       for (side=[0:3]) {
         fountain_part(height=ETCH_DEPTH+E, side=side, line=true, curve=true);
       }
  }
}

module plaque() {
  patterns=[
    [],
    [[0, true, true], [2, true, true]],
    [[1, true, true], [3, true, true]],
    [[0, true, false], [1, true, false], [2, true, false], [3, true, false]],
    [[0, true, true], [1, true, true], [2, true, true], [3, true, true]],
    [[1, true, false], [3, true, false]],
    [[0, true, false], [1, true, false], [2, true, false], [3, true, false]]
  ];
  interval = OUTER * 1.3 - E;
  for (p=[0:len(patterns) - 1]) {
    translate([p % 4 * interval, -floor(p / 4) * interval, 0])
      for (s=[0:len(patterns[p]) - 1]) {
        fountain_part(WATER_HEIGHT, side=patterns[p][s][0], line=patterns[p][s][1], curve=patterns[p][s][2]);
      }
  }
}

plaque();

$fa = 3;
$fs = 1;

E = 0.01;
OUTER = 100;
INNER = 50;
WIDTH = 5;
INSET = 0.8;

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
      ring(height);
      translate([0, INNER / 2 - WIDTH / 2, height / 2])
        cube([long - 2 * E, WIDTH, height], center=true);
    }
    translate([0, -OUTER / 2 + INNER / 2 - WIDTH, height / 2])
      cube([OUTER + 2 * E, OUTER + 2 * E, height + 2 * E], center=true);
  }
}

module plaque() {  translate([0, 0, ETCH_DEPTH + E])
  difference() {
     translate([0, 0, -PLAQUE_HEIGHT / 2])
      cube([OUTER * 1.3, OUTER * 1.3, PLAQUE_HEIGHT], center=true);
     translate([0, 0, -ETCH_DEPTH])
       for (side=[0:3]) {
         fountain_part(height=ETCH_DEPTH+E, side=side, line=true, curve=true);
       }
  }
}

plaque();

fountain_part(30, side=3);

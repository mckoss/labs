$fa = 3;
$fs = 1;

E = 0.01;
OUTER = 100;
INNER = 50;
WIDTH = 5;
INSET = 0.8;


module fountain(height=1) {
  difference() {
   cylinder(r=OUTER/2, h=height);
   translate([0, 0, -E])
     cylinder(r=OUTER/2 - WIDTH, h=height + 2 * E);
  }

  long = 2 * sqrt(pow(OUTER / 2, 2) - pow(INNER / 2, 2));

  for (i=[0:3])
  rotate(a=90 * i, v=[0, 0, 1])
    translate([0, INNER / 2 - WIDTH / 2, height / 2])
      cube([long - 2 * E, WIDTH, height], center=true);
}

fountain(10);
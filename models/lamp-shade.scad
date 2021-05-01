BASE = 10;
TOP = 5;
HEIGHT = 8;
THICKNESS = 0.5;
EPSILON = 0.1;

$fn = 100;

module shade () {
  difference() {
    cylinder(h=HEIGHT, r1=BASE/2, r2=TOP/2);
    # translate([0, 0, -EPSILON])
        cylinder(h=HEIGHT + THICKNESS, r1=BASE/2-THICKNESS, r2=TOP/2 - THICKNESS);
  }
}

shade();




GAP = 0.5;
MAJOR = 45.8 + 2*GAP;
MINOR = 37.5 + 2*GAP;
BASE_THICKNESS = 6.5;
HOLE_SIZE = 7.8;
SHAFT_SIZE = 10;


$fn = 32;


module base() {
  difference() {
    union() {
      scale([1, MINOR/MAJOR, BASE_THICKNESS/MAJOR])
        sphere(MAJOR/2);
      scale([1, MINOR/MAJOR, 1])
        translate([0, 0, -BASE_THICKNESS*2])
        cylinder(h=BASE_THICKNESS*2, r=MAJOR/2);
    }
    rotate([0, 0, 45]) {
      translate([MAJOR/4, 0, 0])
        cylinder(h=BASE_THICKNESS*2, r=HOLE_SIZE/2 - GAP, center=true);
      translate([-MAJOR/4, 0, 0])
        cylinder(h=BASE_THICKNESS*2, r=HOLE_SIZE/2 - GAP, center=true);
    }
  }
  cylinder(h=BASE_THICKNESS+11, r=SHAFT_SIZE/2 + GAP, center=true);
}

MAJOR_GRIP = MAJOR + 15;
MINOR_GRIP = MINOR + 5;
GRIP_THICKNESS = 20;

module grip() {
  difference() {
    scale([1, MINOR_GRIP/MAJOR_GRIP, GRIP_THICKNESS/MAJOR_GRIP])
      sphere(MAJOR_GRIP/2);
    translate([0, 0, -MAJOR_GRIP/2 - GRIP_THICKNESS/4])
      cube(MAJOR_GRIP, center=true);
  }
}

difference() {
  grip();
  base();
}

THICKNESS = 7.5;
LENGTH = 191;
BASE = 17;
HEIGHT = 20;
E = 0.1;

SLANT = -20;

module pos() {
    translate([0, 0, HEIGHT/2])
    rotate([45, 0, 0])
    difference() {
        rotate([45, 0, 0])
            cube([LENGTH, HEIGHT,  HEIGHT], center=true);

        translate([0, 0, HEIGHT])
            cube([LENGTH + 2 * E, 2*HEIGHT, 2*HEIGHT], center=true);
    };
}

module sub() {
    translate([0, 4, HEIGHT/2 + 3])
    rotate([SLANT, 0, 0])
    cube([LENGTH+2*E, THICKNESS, HEIGHT], center=true);
}

difference() {
    pos();
    sub();
}

TROUGH = 11;
LENGTH = 191;
HEIGHT = 30;
SLANT = -20;
LIP = 4;
E = 0.1;
E2 = 2 * E;

module slug() {
    difference() {
        rotate([0, 90, 0])
            cylinder(h=LENGTH, r=HEIGHT, center=true, $fa = 1);
        translate([0, HEIGHT, 0])
            cube([LENGTH + E2, 2 * HEIGHT, 2 * HEIGHT], center=true);
        translate([0, 0, -HEIGHT])
            cube([LENGTH + E2, 2 * HEIGHT, 2 * HEIGHT], center=true);
    }
}

module slot() {
    rotate([SLANT, 0, 0]) {
        translate([0, 0, HEIGHT])
            cube([LENGTH + E2, TROUGH, HEIGHT * 2], center=true);
        translate([0, - TROUGH + E, HEIGHT + LIP])
            cube([LENGTH + E2, TROUGH, HEIGHT * 2], center=true);
    }
}

difference() {
    slug();
    translate([0, -20, 4])
        slot();
}
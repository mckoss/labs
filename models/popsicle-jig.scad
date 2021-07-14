E = 0.2;
WALL = 1;
GAP = 0.7;

STICK_W = 17.8;
STICK_L = 150;
STICK_TH = 1.7;
STICK_L_C = STICK_L - STICK_W;

module stick(orient, extra) {
    length = STICK_L + extra;
    width = STICK_W + extra;
    height = STICK_TH + extra;
    rotate([0, 0, orient == "h" ? 90 : 0]) {
        cube([width, length, height], center=true);
        translate([0, -length/2, 0])
            cylinder(h=height, r=width/2, center=true);
        translate([0, length/2, 0])
            cylinder(h=height, r=width/2, center=true);
    }
}

module course(extra, offset) {
    translate([0, -STICK_L_C/6, 0])
        stick("v", extra);
    translate([STICK_L_C/6, -STICK_L_C/3, offset])
        stick("h", extra);
}

module initial(extra, offset, rot) {
    rotate([0, 0, rot]) {
        translate([-STICK_L_C/6, 0, -offset])
            stick("h", extra);
        course(extra, offset);
    }
}

module sample() {
    rotate([0, 0, 45]) {
        % for (i=[1:5]) {
            translate([i * STICK_L_C/3, -i * STICK_L_C/3, 0])
                course(2 * E, STICK_TH + E);
        }
    }
}

module holder() {
    rotate([0, 0, 45])
    difference() {
        initial(5, 0, 0);
        translate([50 + STICK_W/2 + 2.5, -20, 0])
           cube([100, 100, 10], center=true);
        translate([0, -50 - STICK_L/3 - STICK_W/3 + 0.4, 0])
           cube([100, 100, 10], center=true);
    }
}

difference() {
    holder();
    initial(GAP, STICK_TH + E, 45);
}

% initial(GAP, STICK_TH + E, 45);
sample();

E = 0.2;
WALL = 1;
GAP = 0.7;

STICK_W = 17.8;
STICK_L = 150;
STICK_TH = 1.7;
STICK_L_C = STICK_L - STICK_W;

MODEL = "block"; // ["block", "synth"]
SHOW_SAMPLE = true;

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

module stick_i(i, extra, offset) {
    orient = i % 2 == 0 ? "v"  : "h";
    xlate = floor(i / 2);
    OFF_X = orient == "h" ? STICK_L_C/6 : 0;
    OFF_Y = orient == "v" ? -STICK_L_C/6 : -STICK_L_C/3;
    OFF_Z = orient == "h" ? offset : 0;
    translate([xlate * STICK_L_C/3 + OFF_X,
               -xlate * STICK_L_C/3 + OFF_Y,
               OFF_Z])
        stick(orient, extra);
}

module initial(extra, offset, rot) {
    rotate([0, 0, rot]) {
        for (i = [-1:1])
            stick_i(i, extra, offset * i);
    }
}

module sample() {
    rotate([0, 0, 45]) {
        % for (i=[0:10]) {
            stick_i(i, 2 * E, STICK_TH + E);
        }
    }
}

module holder_base() {
    rotate([0, 0, 45])
    difference() {
        initial(5, 0, 0);
        translate([50 + STICK_W/2 + 2.5, -20, 0])
           cube([100, 100, 10], center=true);
        translate([0, -50 - STICK_L/3 - STICK_W/3 + 0.4, 0])
           cube([100, 100, 10], center=true);
    }
}

module block_holder() {
    difference() {
        holder_base();
        initial(GAP, STICK_TH + E, 45);
    }
}

module synth_holder() {
    initial(5, 0, 45);
}

if (MODEL == "block")
    block_holder();

if (MODEL == "synth")
    synth_holder();

if (SHOW_SAMPLE) {
    % initial(GAP, STICK_TH + E, 45);
    sample();
}

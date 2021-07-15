E = 0.2;
WALL = 1;
GAP = 0.7;

STICK_W = 17.8;
STICK_L = 150;
STICK_TH = 1.7;
STICK_L_C = STICK_L - STICK_W;

MODEL = "block"; // ["block", "synth", "clip"]
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
    translate([xlate * STICK_L_C/3 + OFF_X,
               -xlate * STICK_L_C/3 + OFF_Y,
               offset])
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
            stick_i(i, 2 * E, i % 2 == 1 ? STICK_TH + E : 0);
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
    rotate([0, 0, 45])
    difference() {
        union() {
            initial(5, 0, 0);
            difference() {
                stick_i(2, 5, 0);
                translate([STICK_W, -STICK_L/2 - STICK_W/2, 0])
                    cube([100, STICK_L + STICK_W, 10], center=true);
            }
            difference() {
                stick_i(3, 5, 0);
                translate([STICK_L/2 + STICK_W + 2.5, -STICK_W - 5, 0])
                    cube([STICK_L + STICK_W, STICK_L + STICK_W, 10], center=true);
            }
            difference() {
                stick_i(4, 5, 0);
                translate([STICK_L/2 + STICK_W + 2.5, -STICK_L + STICK_W - 5, 0])
                    cube([STICK_L + STICK_W, STICK_L + STICK_W, 10], center=true);
            }
        }
        translate([-50 - STICK_W/2 - 2.5, -20, 0])
            cube([100, 100, 10], center=true);
        translate([-STICK_W - 2 * E, STICK_L/3 + STICK_W/2 + 2.5, 0])
            cube([100, 100, 10], center=true);
        
        difference() {
            stick_i(2, GAP, -GAP);
            translate([STICK_W, -STICK_L/2, 0])
                cube([100, 100, 10], center=true);
        }
        difference() {
            stick_i(2, 5, 1.5 * STICK_TH);
            translate([STICK_W, 50 - STICK_W, 0])
                cube([100, 100, 10], center=true);
        }
        stick_i(3, GAP, -GAP);
        stick_i(4, GAP, -GAP);
    }
}

module clip() {
    difference() {
        stick(0, 5, 0);
        translate([0, -STICK_L * .6, 0])
            cube([100, STICK_L, 10], center=true);
        translate([0, -STICK_L/3, -4])
            cube([100, STICK_L, 10], center=true);
        stick(0, GAP, 0);
    }
}

if (MODEL == "block")
    block_holder();

if (MODEL == "synth")
    synth_holder();

if (MODEL == "clip")
    clip();

if (SHOW_SAMPLE) {
    % initial(GAP, STICK_TH + E, 45);
    sample();
}

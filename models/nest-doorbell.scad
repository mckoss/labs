// Door-bell housing to admit a Google Nest door bell behind
// a mounting plate (adapted from Ring doorbell faceplate).
//
// All dimensions are mm.
//
// (c) 2026 Mike Koss <mike@mckoss.com>

// Mounting plate
PLATE_X = 110;
PLATE_Y = 190;
PLATE_Z = 6;

// Screw holes - for centered (0,0) plate.
HOLES_X = 0;
HOLE1_Y = PLATE_Y/2 - 15;
HOLE2_Y = -PLATE_Y/2 + 15;

SCREW_HOLE_D = 4;
SCREW_HEAD_D = 6;
SCREW_HEAD_Z = 1;

// Nest doorbell dimension
BASE_WIDTH = 36;
// Add 2mm for slop for sliding the doorbell over the base plate.
BASE_HEIGHT = 124 + 2;
// The base was too far away from V1 prototype - change from 11 to 9.
BASE_DEPTH = 9;
BASE_FLOOR = 12;
SCREW_SPACING = 58;
WIRE_SLOT_WIDTH = 17;
WIRE_SLOT_HEIGHT = 43;

EPSILON = 0.3;
WALL = 3;

$fn = 120;

module raw_plate() {
    linear_extrude(height=PLATE_Z, scale=0.97)
        square([PLATE_X, PLATE_Y], center=true);
}

module pilot() {
    cylinder(h=PLATE_Z, r=SCREW_HEAD_D/2, $fs=0.5);
}

module plate() {
    for (y = [HOLE1_Y, HOLE2_Y]) {
        translate([HOLES_X, y, 0]) {
            pilot();
        }
    }
    difference() {
        raw_plate();
        translate([0,0,-WALL])
            raw_plate();
    }
}

module screw_holes() {
    translate([0,0,-EPSILON]) {
        for (y = [HOLE1_Y, HOLE2_Y]) {
            translate([HOLES_X, y, 0]) {
                cylinder(h=PLATE_Z+2*EPSILON, r=SCREW_HOLE_D/2, $fs=0.5);
                translate([0, 0, PLATE_Z - SCREW_HEAD_Z])
                    cylinder(h=SCREW_HEAD_Z + 2 * EPSILON, r1=SCREW_HOLE_D/2, r2=SCREW_HEAD_D/2, $fs=0.5);
            }
        }
    }
}

module assembly() {
    difference() {
        union() {
              plate();
            base_box(true);
        }
          screw_holes();
        base_box(false);
    }
}

assembly();


module oval_block(width, height, depth) {
    off_center = height/2 - width/2;
    translate([0, off_center, 0])
        cylinder(h=depth, r=width/2);
    translate([0, -off_center, 0])
        cylinder(h=depth, r=width/2);
    translate([0, 0, depth/2])
        cube([width, height-width, depth], center=true);
}

module base_box(vis) {
    if (vis)  {
        oval_block(BASE_WIDTH + 2 * WALL, BASE_HEIGHT + 2 * WALL, BASE_DEPTH + BASE_FLOOR);
    } else {
        translate([0, 0, BASE_FLOOR + EPSILON])
            oval_block(BASE_WIDTH, BASE_HEIGHT, BASE_DEPTH);
        translate([0, SCREW_SPACING/2, BASE_FLOOR + 2 * EPSILON])
            screw_hole(14, 3, 3, BASE_FLOOR);
        translate([0, -SCREW_SPACING/2, BASE_FLOOR + 2 * EPSILON])
            screw_hole(14, 3, 3, BASE_FLOOR);
        translate([0, 0, BASE_FLOOR/2])
            cube([WIRE_SLOT_WIDTH, WIRE_SLOT_HEIGHT, BASE_FLOOR + 3 * EPSILON], center=true);
        translate([0, BASE_HEIGHT/2, BASE_DEPTH + BASE_FLOOR])
            rotate(a=[90, 0, 0])
                cylinder(h=WALL*2, r=6, center=true);
    }
}

module screw_hole(head, hole, transition, depth) {
    rotate(a=[180, 0, 0])
    union() {
        cylinder(h=transition, r1=head/2, r2=hole/2);
        translate([0, 0, transition-EPSILON])
            cylinder(h=depth, r=hole/2);
    }
}

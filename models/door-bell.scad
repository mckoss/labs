// Door-bell housing to admit a Ring door bell behind
// a mounting plate.
//
// All dimensions are mm.
//
// The orientation of the plate is facing up with back side
// of plate at Z=0.  The Ring box is mounting in the negative
// Z direction.  The front face of the plate is at PLATE_Z
// units above Z=0.
//
// Note that in final assembly, the box is flipped over
// so that it rests front-side down on the build plate.

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

// Ring doorbell dimensions
RING_X = 62.5;
RING_INSET = 2.25;
RING_Y = 129;
RING_Z = 28.5;

RING_BUTTON_Y = 41;
RING_BUTTON_D = 34;

// Center of window
RING_WINDOW_Y = RING_Y - 34;
RING_WINDOW_HEIGHT = 25;

RING_BOX_ANGLE = atan2(RING_Z, RING_Y);

EPSILON = 0.3;
WALL_THICKNESS = 2;

// Retention clips
CLIP_WIDTH = WALL_THICKNESS * 2;
CLIP_HEIGHT = CLIP_WIDTH;
CLIP_LENGTH = 2 * CLIP_WIDTH;

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
        translate([0,0,-WALL_THICKNESS])
            raw_plate();
        cube([RING_X, RING_Y, RING_Z], center=true);
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

module ring_doorbell() {
    x0 = 0;
    x1 = RING_INSET;
    x2 = RING_X - RING_INSET;
    x3 = RING_X;
    
    y0 = 0;
    y1 = RING_Y;
    
    z0 = 0;
    z1 = RING_Z;
    
    polyhedron(points=[[x0, y0, z0], [x3, y0, z0], [x3, y1, z0], [x0, y1, z0],
                       [x1, y0, z1], [x2, y0, z1], [x2, y1, z1], [x1, y1, z1]],
               faces=[[0, 1, 2, 3], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3],
                      [3, 7, 4, 0], [4, 7, 6, 5]]);
}

module ring_doorbell_box() {
    translate([-RING_X/2, -RING_Y/2, -RING_Z + PLATE_Z - WALL_THICKNESS]) {
        difference() {
            translate([-WALL_THICKNESS, -WALL_THICKNESS, 0])
                resize([RING_X + 2 * WALL_THICKNESS,
                        RING_Y + 2 * WALL_THICKNESS,
                        RING_Z + WALL_THICKNESS]) {
                    ring_doorbell();
            }

        }
        for (y = [RING_Y/2, CLIP_LENGTH]) {
        translate([-WALL_THICKNESS, y, 0])
            rotate(a=[180, 0, 0])
                clip();
        translate([RING_X + WALL_THICKNESS, y, 0])
            rotate(a=[180, 0, 180])
                clip();
        }
}
}

module ring_doorbell_box_cutouts() {
   translate([-RING_X/2, -RING_Y/2, -RING_Z + PLATE_Z - WALL_THICKNESS]) {
        translate([RING_X/2, RING_BUTTON_Y, 0])
            cylinder(h=RING_Z + 2 * WALL_THICKNESS, r=RING_BUTTON_D/2);
        translate([RING_X/2, RING_WINDOW_Y, RING_Z/2 + WALL_THICKNESS])
            cube([RING_X - 3 * WALL_THICKNESS, RING_WINDOW_HEIGHT, RING_Z + 2 * WALL_THICKNESS], center=true);
        translate([0, 0, -EPSILON])
            ring_doorbell();
    }
}

module clip() {
    x = CLIP_WIDTH;
    y = CLIP_LENGTH;
    z = CLIP_HEIGHT;
    translate([0, -CLIP_LENGTH/2, 0])
        polyhedron(points=[[0, 0, 0], [CLIP_WIDTH, 0, 0], [x, y, 0], [0, y, 0],
                        [0, 0, z], [0, y, z]],
                faces=[[0,1, 2, 3], [0, 4, 1], [2, 5, 3], [1, 4, 5, 2], [3, 5, 4, 0]]);
}

module rotate_box(dz) {
    translate([0, RING_Y/2, dz])
    rotate([RING_BOX_ANGLE, 0, 0])
    translate([0, -RING_Y/2, dz])
        children();
}

module shroud() {
    translate([0, 0, - RING_Z / 2 + PLATE_Z - WALL_THICKNESS/2]) {
        difference() {
            cube([RING_X, RING_Y, RING_Z + WALL_THICKNESS], center=true);
            cube([RING_X - 2 * WALL_THICKNESS, RING_Y - 2 * WALL_THICKNESS, 2 * RING_Z], center=true);
            translate([0, 0, -RING_Z - 2 * WALL_THICKNESS])
                rotate_box(RING_Z / 2 + WALL_THICKNESS / 2)
                    cube([RING_X + EPSILON, RING_Y * 1.2, RING_Z + WALL_THICKNESS], center=true);
        }
    }
}

module assembly() {
    dz = -EPSILON;
    translate([0, 0, PLATE_Z])
    rotate(a=[180, 0, 0])
    difference() {
        union() {
            plate();
            shroud();
            rotate_box(dz)
                ring_doorbell_box();
        }
        screw_holes();
        rotate_box(dz)
            ring_doorbell_box_cutouts();
    }
}

assembly();

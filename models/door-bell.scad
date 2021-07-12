// Door-bell housing to admit a Ring door bell behind
// a mounting plate.
//
// All dimensions are mm.

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

// Ring doorbell dimensions
RING_X = 62.5;
RING_INSET = 2.25;
RING_Y = 129;
RING_Z = 28;

RING_BUTTON_Y = 41;
RING_BUTTON_D = 34;

RING_WINDOW_Y = RING_Y - 35;
RING_WINDOW_D = 28;

EPSILON = 0.3;
WALL_THICKNESS = 2;

// Retention clips
CLIP_WIDTH = WALL_THICKNESS * 1.75;
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
    translate([HOLES_X, HOLE1_Y, 0]) {
        pilot();
    }
    translate([HOLES_X, HOLE2_Y, 0]) {
        pilot();
    }
    difference() {
        raw_plate();
        translate([0,0,-WALL_THICKNESS])
            raw_plate();
    }
}

module screw_holes() {
    translate([0,0,-EPSILON]) {
        translate([HOLES_X, HOLE1_Y, 0])
            cylinder(h=PLATE_Z+2*EPSILON, r=SCREW_HOLE_D/2, $fs=0.5);
        translate([HOLES_X, HOLE2_Y, 0])
            cylinder(h=PLATE_Z+2*EPSILON, r=SCREW_HOLE_D/2, $fs=0.5);
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
                resize([RING_X + 2 * WALL_THICKNESS, RING_Y + 2 * WALL_THICKNESS, RINGZ]) {
                    ring_doorbell();
            }
            translate([0, 0, -EPSILON])
                ring_doorbell();
        }
        translate([-WALL_THICKNESS, RING_Y/2, 0])
            rotate(a=[180, 0, 0])
                clip();
        translate([RING_X + WALL_THICKNESS, RING_Y/2, 0])
            rotate(a=[180, 0, 180])
                clip();
}
}

module ring_doorbell_box_cutouts() {
    translate([-RING_X/2, -RING_Y/2, -RING_Z + PLATE_Z - WALL_THICKNESS]) {
        translate([RING_X/2, RING_BUTTON_Y, 0])
            cylinder(h=RING_Z + 2 * WALL_THICKNESS, r=RING_BUTTON_D/2);
        translate([RING_X/2, RING_WINDOW_Y, 0])
            cylinder(h=RING_Z + 2 * WALL_THICKNESS, r=RING_WINDOW_D/2);
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

module assembly() {
    difference() {
        union() {
            plate();
            ring_doorbell_box();
        }
        screw_holes();
        ring_doorbell_box_cutouts();
    }
}

translate([0, 0, PLATE_Z])
    rotate(a=[180, 0, 0])
        assembly();
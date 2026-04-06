// Create a switch plate the same dimensions as the Phast wall-mounted
// controls - to adapt the opening to placing to accomodate the Minoston
// S2 Remote Control Switch (800S) Model - MR40Z (ZW924).
// (the included switch plate is both too narrow and does not have the mounting
// holes in the same position).

use <chamfered-box.scad>

inch = 25.4;

PLATE_WIDTH = 85;
PLATE_HEIGHT = 115;
PLATE_DEPTH = 6;
PLATE_THICKNESS = 3.7;

OPENING_WIDTH = 33.3;
OPENING_HEIGHT = 67;

SCREW_HOLE_CENTERS = 3.25 * inch;
SCREW_HOLE_DIAMETER = 4;
SCREW_HEAD_DIAMETER = 6;

EPSILON = 0.1;

module plate() {
    difference() {
        chamfered_box(PLATE_WIDTH, PLATE_HEIGHT, PLATE_DEPTH, radius=PLATE_DEPTH, steps=10);
        translate([0, 0, -PLATE_THICKNESS])
            chamfered_box(PLATE_WIDTH - 2 * PLATE_THICKNESS, PLATE_HEIGHT - 2 * PLATE_THICKNESS, PLATE_DEPTH, radius=PLATE_DEPTH, steps=10);
        
        // Screw holes with countersink
        for (y = [-SCREW_HOLE_CENTERS/2, SCREW_HOLE_CENTERS/2]) {
            translate([0, y, -EPSILON])
                cylinder(d1=SCREW_HOLE_DIAMETER, d2=SCREW_HEAD_DIAMETER, h=PLATE_DEPTH + 2*EPSILON, $fn=32);
        }
        
        // Center opening
        translate([0, 0, PLATE_DEPTH/2])
            cube([OPENING_WIDTH, OPENING_HEIGHT, PLATE_DEPTH + 2*EPSILON], center=true);
    }
}

plate();
// "Can't stop" scoring board (single player)
MARBLE = 14;
HEIGHT = MARBLE/4 + 1;
WALL = 1;

SPACING = MARBLE + WALL;

// Make solid track with pockets for marble every
// SPACING units.  Oriented along y-axis centered
// on x-axis.
module track(n, i) {
    distance = (n - 1) / 2 * SPACING;
    width = MARBLE + 2 * WALL;
    translate([0, distance, 0]) {
        linear_extrude(HEIGHT)
            circle(width/2, $fs=1);
    }
    translate([0, -distance, 0]) {
        linear_extrude(HEIGHT)
            circle(width/2, $fs=1);
    }
    translate([0, 0, HEIGHT / 2])
        cube([width, distance * 2, HEIGHT], center=true);
    
    translate([0, distance + width/2 + WALL, HEIGHT + 2 * WALL]) {
        rotate([45, 0, 0])
        union() {
            linear_extrude(WALL * 2)
                text(str(i), halign="center", valign="bottom", size=MARBLE/2);
            cube([width, width + WALL, WALL], center=true);
        }
    }
}

module pockets(n) {
    for (i = [-(n-1)/2 : (n - 1)/2]) {
        translate([0, i * SPACING, HEIGHT + MARBLE/4])
            sphere(MARBLE / 2);
    }
}

module column(n, i) {
    difference() {
        track(n, i);
        pockets(n);
    }
}

module board() {
    for (i = [2 : 12]) {
        shift = i - 7;
        size = 13 - 2 * abs(shift);
        translate([shift * SPACING, 0, 0])
            column(size, i);
    }
}

board();
text("2");
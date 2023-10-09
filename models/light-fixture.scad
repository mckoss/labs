WIDTH = 60;
THICKNESS = 3;
//HEIGHT = 220;
HEIGHT = 40;
SLOP = 2;
HOLE_POS = HEIGHT - 15;
HOLE_WIDTH = 4.5;

difference() {
    cylinder(h=HEIGHT, r=WIDTH/2, $fn=60);
    translate([0, 0, -SLOP])
        cylinder(h=HEIGHT + 2*SLOP, r=WIDTH/2 - THICKNESS, $fn=60);
    pin();
    rotate([0, 0, 120]) pin();
    rotate([0, 0, -120]) pin();
}

module pin() {
    translate([WIDTH / 2, 0, HOLE_POS])
    rotate([0, 90, 0])
        cylinder(h=10, r=HOLE_WIDTH/2, center=true, $fn=15);
}

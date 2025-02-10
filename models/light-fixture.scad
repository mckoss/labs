WIDTH = 60;
THICKNESS = 3;
HEIGHT = 220;
SLOP = 2;
HOLE_POS = HEIGHT - 15;
HOLE_WIDTH = 4.5;

RES = .1;

difference() {
    cylinder(h=HEIGHT, r=WIDTH/2, $fs=RES);
    translate([0, 0, -SLOP])
        cylinder(h=HEIGHT + 2*SLOP, r=WIDTH/2 - THICKNESS, $fs=RES);
    pin();
    rotate([0, 0, 120]) pin();
    rotate([0, 0, -120]) pin();
}

module pin() {
    translate([WIDTH / 2, 0, HOLE_POS])
    rotate([0, 90, 0])
        cylinder(h=10, r=HOLE_WIDTH/2, center=true, $fs=RES/2);
}

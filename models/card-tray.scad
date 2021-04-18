//
// 2-deck Playing Card tray
//

INCH = 25.4;

SLOP = 1;
EPSILON = 0.1;

WIDTH = 2.5 * INCH + SLOP;
HEIGHT = 3.5 * INCH + SLOP;

THICKNESS = 2;

X_SCALE = (WIDTH + 2 * THICKNESS) / WIDTH;
Y_SCALE = (HEIGHT + 2 * THICKNESS) / HEIGHT;

$fs = 1;


module deck(h) {
    translate([WIDTH / 2, 0, 0])
    linear_extrude(height=h, scale=1.05)
      translate([-WIDTH / 2, 0, 0])
        square([WIDTH, HEIGHT], center=true);
}


module tray(h) {
    difference() {
        scale([X_SCALE, Y_SCALE, 1])
            deck(h);
        translate([0, 0, THICKNESS])
            deck(h);
        cylinder(h=3 * h, r=0.5 * INCH, center=true);
        translate([-WIDTH/2, 0, h + THICKNESS / 2])
            sphere(r=h);
        translate([0, HEIGHT / 2, h + THICKNESS / 2])
            sphere(r=h);
        translate([0, -HEIGHT / 2, h + THICKNESS / 2])
            sphere(r=h);
    }
}

tray(INCH);

translate([WIDTH + THICKNESS + EPSILON, 0, 0])
    rotate([0, 0, 180])
        tray(INCH);

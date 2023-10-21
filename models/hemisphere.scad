E = 0.1;
E2 = 2 * E;
D = 25.4 * 2;
THICKNESS = 2;

difference() {
    sphere(d = D);
    sphere(d = D - THICKNESS * 2);
    translate([0, 0, -D/2])
        cube([D + E, D + E, D + E], center = true);
}

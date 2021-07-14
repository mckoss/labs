E = .02;

module slat(offset) {
    translate([offset * 5, 0, 0])
        cube([1, 30 + E, 2 + E], center=true);
}

module dowel(offset) {
    translate([0, offset * 8, 0])
        rotate([0, 90, 0])
            cylinder(h=21, r=0.5, center=true, $fn=15);
}

module table() {
    difference() {
        cylinder(h=2, r=15, center=true);
        for (i=[-2:2]) slat(i);
    }
    for (i=[-1:1]) dowel(i);
}

T = 15.8;
R = 1.4;
O = 4.0;
P_D = 7.3;
TAKEOFF = 22 / (T + R);
T_HEIGHT = TAKEOFF * T;
R_HEIGHT = TAKEOFF * R;
O_WIDTH = TAKEOFF * O;
P_RADIUS = TAKEOFF * P_D / 2;

PEAK_POINTS = [
    [-35, 0], [-35 + O_WIDTH, 0], [-35 + O_WIDTH, -R_HEIGHT],
    [35 - O_WIDTH, -R_HEIGHT], [35 - O_WIDTH, 0], [35, 0],
    [0, T_HEIGHT]
];

module peak() {
    difference() {
        linear_extrude(height=2) {
            polygon(points=PEAK_POINTS);
        }
        translate([0, T_HEIGHT / 2, -E])
            cylinder(h=2+2*E, r=P_RADIUS, $fn=20);
    }
}

echo([0:10]);

translate([0, -30, 1])
    table();

peak();

translate([0, 30, 0])
    peak();
E = 0.01;
$fa = 3;
$fs = 1;

WIND_LENGTH = 41;
WIND_WIDTH = 10;
WIND_HEIGHT = 2;
GAP_LENGTH = 3;

EXIT_ANGLE = 15;
EXIT_FLARE = 8;

module whistle(length=WIND_LENGTH,
              width=WIND_WIDTH,
              height=WIND_HEIGHT,
              gap=GAP_LENGTH,
              a=EXIT_ANGLE,
              b=EXIT_FLARE) {
        difference() {
            pipe(length, width);
            fipple(length, width, height, gap, a, b);
    }
}

module pipe(length, width) {
    translate([0, 0, -width / 2])
        rotate(a=90, v=[0, 1, 0])
            difference() {
                cylinder(r=width, h=(length - E) * 2, center=true);
                translate([0, 0, length / 2])
                    cylinder(r=width / 2, h=length + E, center=true);
                translate([width * 1.7, 0, -length])
                    rotate(a=90, v=[1, 0, 0])
                        cylinder(r=width * 2, h = width * 3, center=true);
            }
}

module fipple(length, width, height, gap, a, b) {
    translate([-length / 2, 0 , 0])
        cube([length, width, height], center=true);
    translate([length / 4, 0, -height])
        cube([length / 2, width, 2 * height], center=true);
    translate([-E, 0, -tan(EXIT_ANGLE) * GAP_LENGTH])
        cut(width, length, height * 10, a, b);
}

module cut(width, length, height, a, b) {
    x1 = length;
    z1 = length * tan(a);
    y1 = width / 2;
    y2 = width / 2 + length * tan(b);
    polyhedron(
        points=[
            [0, -y1, 0], [x1, -y2, z1], [0, -y1, z1],
            [0, y1, 0],  [x1, y2, z1],  [0, y1, z1]
        ],
        triangles=[
            [0, 2, 1], [3, 4, 5],
            [0, 5, 2], [0, 3, 5],
            [2, 4, 1], [2, 5, 4],
            [0, 4, 3], [0, 1, 4]
        ]);
}

whistle();

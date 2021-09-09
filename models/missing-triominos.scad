PIECE = 0; // [0:19]

module __Customizer_Limit__ () {}

SIZE = 39;
THICKNESS = 7;
ROUNDING = 2;
EMBOSS = 1;

EPSILON = 0.1;

module digit(n, pos) {
    rotate([0, 0, - pos * 120])
    rotate([0, 0, -90])
    translate([0, 10, THICKNESS - EMBOSS + EPSILON])
    linear_extrude(EMBOSS)
    rotate([0, 0, 180])
    text(str(n), size=6, font="Arial:style=Bold", halign="center", valign="center");
}

module tri(a, b, c) {
    difference() {
        triangle();
        union() {
            digit(a, 0);
            digit(b, 1);
            digit(c, 2);
        }
    }
    translate([0, 0, THICKNESS - 0.7])
        sphere(r=2, $fn=16);
}

module triangle() {
    translate([0, 0, ROUNDING])
    minkowski() {
        cylinder(h=THICKNESS - ROUNDING * 2, r=(SIZE/1.73 - ROUNDING), $fn=3);
        sphere(r=ROUNDING, $fn=20);
    };
}

missing = [
    [0, 2, 1],
    [0, 3, 1], [0, 3, 2],
    [0, 4, 1], [0, 4, 2], [0, 4, 3],
    [0, 5, 1], [0, 5, 2], [0, 5, 3], [0, 5, 4],

    [1, 3, 2],
    [1, 4, 2], [1, 4, 3],
    [1, 5, 2], [1, 5, 3], [1, 5, 4],
  
    [2, 4, 3],
    [2, 5, 3], [2, 5, 4],

    [3, 5, 4]
];
    

tri(missing[PIECE][0], missing[PIECE][1], missing[PIECE][2]);



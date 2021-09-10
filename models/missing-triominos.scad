PIECE = 0; // [0:19]
SIZE = 20; // [39, 20]
THICKNESS = 2; // [7, 2]

module __Customizer_Limit__ () {}

ROUNDING = 2;
EMBOSS = 1;

BED_SIZE = 200;

EPSILON = 0.1;

I = [SIZE, 0];
J = [SIZE * cos(60), SIZE * sin(60)];

GAP = 2;
I_SPACING = I + [2 * GAP, 0];
J_SPACING = J + [GAP, GAP];

// Digit positions
P0 = (I + J) / 6;
R0 = -60;

P1 = J + (I - 2 * J) / 6;
R1 = 180;

P2 = I + (J - 2 * I) /6;
R2 = 60;


// These are including in the Triominos box.  All non-decreasing
// clockwise (56 of them).
included = [for (i = [0:5]) for (j = [i: 5]) for (k = [j: 5]) [i, j, k]];

// These non-clockwise Triominos are missing (20 of them).
missing = [for (i = [0:5]) for (j = [i: 5]) for (k = [i: 5]) if (j > i + 1 && k > i && j > k) [i, j, k]];

module arrangeTriominos(tiles) {
    rows = floor(1.6 * sqrt(len(tiles)));
    cols = ceil(len(tiles)/rows);
    
    // Even rows are oriented baseline on x axis.
    // Odd rows are rotated 60 degrees CCW (apex along axis).
    for (rw = [0: rows - 1]) {
        for (col = [0: cols - 1]) {
            i = rw * cols + col;
            odd = rw % 2;
            isOffset = (rw % 4) > 1 ? 1 : 0;
            if (i < len(tiles)) {
                translate((col + odd) * I_SPACING + floor(rw / 2) * J_SPACING - floor((rw + 1) / 4) * I_SPACING)
                translate([-GAP * odd, 0, 0])
                rotate([0, 0, odd * 60])
                union() {
                    // translate((I + J) / 3)
                    // translate([0, 0, THICKNESS * 3])
                    // text(str(i), size=5, halign="center", valign="center");
                    trionimo(tiles[i]);
                }
            }
        }
    }
}

arrangeTriominos(concat(included, missing));

module trionimo(nums) {
    difference() {
        linear_extrude(THICKNESS)
        polygon([[0, 0], I, J]);
        union() {
            place_digit(nums[0], P0, R0);
            place_digit(nums[1], P1, R1);
            place_digit(nums[2], P2, R2);
        }
    }
}

module place_digit(d, pos, rot) {
    translate(pos)
    rotate(rot)
    translate([0, 0, THICKNESS - EMBOSS + EPSILON])
    linear_extrude(EMBOSS)
    text(str(d), size=4, font="Arial:style=Bold", halign="center", valign="center");
}

// ORIGINAL TRIOMINOS

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

// tri(missing[PIECE][0], missing[PIECE][1], missing[PIECE][2]);



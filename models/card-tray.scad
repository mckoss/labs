//
// 2-deck Playing Card tray
//

// Left tray height in decks
LEFT = 2; // [1, 2, 3, 4]

// Right trag height in decks
RIGHT = 3; // [1, 2, 3, 4]

module __endCustomizer__() {}

INCH = 25.4;

SLOP = 1;
EPSILON = 0.1;
THICKNESS = 2;

// Playing card dimensions
WIDTH = 2.5 * INCH + THICKNESS;
HEIGHT = 3.5 * INCH + THICKNESS;
DECK = 52 * .3;



X_SCALE = (WIDTH + THICKNESS) / WIDTH;
Y_SCALE = (HEIGHT + THICKNESS) / HEIGHT;

$fs = 1;

module minkCorner() {
    difference() {
        sphere(r=THICKNESS/2, $fn=16);
        translate([0, 0, -THICKNESS/2])
          cube([THICKNESS, THICKNESS, THICKNESS], center=true);
    }
}

module deck(h) {
    translate([WIDTH / 2, 0, 0])
    linear_extrude(height=h, scale=1.05)
      translate([-WIDTH / 2, 0, 0])
        square([WIDTH, HEIGHT], center=true);
}

module cutOut(x, y) {
    translate([x, y, 0.9 * INCH + THICKNESS / 2])
        union() {
        sphere(r=0.9 * INCH);
        cylinder(h=3 * INCH, r=0.9 * INCH, center=false);
        }
}

module tray(h) {
    difference() {
        minkowski() {
            difference() {
                scale([X_SCALE, Y_SCALE, 1])
                    deck(h + THICKNESS);
                translate([0, 0, THICKNESS])
                    deck(h + THICKNESS);
                cutOut(0, HEIGHT / 2);
                cutOut(0, -HEIGHT / 2);
            }
            minkCorner();
        }
        cylinder(h=3 * h, r=0.5 * INCH, center=true);
        // cutOut(-WIDTH / 2, 0);

    }
}

tray(LEFT * DECK);

translate([WIDTH + THICKNESS + EPSILON, 0, 0])
    rotate([0, 0, 180])
        tray(RIGHT * DECK);



$fa = 3;
$fs = 3;

E = 0.1;

SPACING = 25;

// Standard sizes: 9, 13, 19
SIZE = 5;
THICKNESS = 10;
LINE_WIDTH = 2;


// Width of lines
WHOLE = (SIZE - 1);

// Center to edge line
HALF = WHOLE / 2;

BOARD_SIZE = (SIZE + 0.5) * SPACING;

LINE_SIZE = WHOLE * SPACING + LINE_WIDTH;
OUTER_OFFSET = HALF  * SPACING;

PIP_SIZE = LINE_WIDTH * 2;
DIMPLE_SIZE = 8;

module base() {
  translate([0, 0, THICKNESS/2])
    cube([BOARD_SIZE, BOARD_SIZE, THICKNESS], center=true);
}

module board() {
  difference() {
    base();
    for (x = [-HALF:HALF]) {
      // Vertical
      translate([x * SPACING, 0, THICKNESS]) {
        cube([LINE_WIDTH, LINE_SIZE, THICKNESS], center=true);
      }
      // Horizontal
      translate([0, x * SPACING, THICKNESS]) {
        cube([LINE_SIZE, LINE_WIDTH, THICKNESS], center=true);
      }
    }

    // Registration points
    inset = SIZE <= 9 ? 2 : 3;
    offset = OUTER_OFFSET - inset * SPACING;
    for (x = [-1: 1]) {
      translate([x * offset, 0, 0])
      for (y = [-1: 1]) {
        translate([0, y * offset, THICKNESS]) {
          cylinder(r=PIP_SIZE, h=THICKNESS, center=true);
        }
      }
    }

    // Dimples
    for (x = [-HALF:HALF]) {
      translate([x * SPACING, 0, 0]) {
        for (y = [-HALF:HALF]) {
          translate([0, y * SPACING, THICKNESS * 1.2]) {
            scale([1, 1, 0.3]) {
              sphere(DIMPLE_SIZE, center=true);
            }
          }
        }
      }
    }
  }
}

board();

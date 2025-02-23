// 49 puzzle

THICKNESS = 3.2;

// Base square dimensions
SQ = 80;

UNIT = SQ / 7;;
GAP = 3;

BOARDER = 2;
SLOP = 0.4;
GRID = 0.6;

HANDLES = true;

// Triangles don't print the pointy end
// well - as it challenges the resolution of the printer.
// So, an alternate version uses a "stuby" triangle.
// In which case the board is 8 units high instead of 7.
STUBY = true;

P1 = STUBY ? [[0,8], [7,8], [7, 7], [0, 5]]
             : [[0,7], [7,7], [0, 5]];
P2 = [[0,3], [1,3], [1,1], [4,1], [4, (6 + 1/7)], [0, 5]];
P3 = [[4,1], [7,1], [7,7], [4, (6 + 1/7)]];
P4 = [[0,0], [4,0], [4,1], [1,1], [1,3], [0,3]];
P5 = [[4,0], [7,0], [7, 1], [4, 1]];


module tile(poly, handle, position=[0, 0]) {
  pos = position * GAP;
  p = poly * UNIT;
  translate([each pos, 0]) {
    linear_extrude(THICKNESS)
      polygon(p);
    
    // Add a handle to the tile
    if (HANDLES) {
      translate([each (handle * UNIT) , 1.5 * THICKNESS])
        sphere(r=THICKNESS, $fn=20);
    }
  }
}

module board() {
  inner = [SQ, SQ + (STUBY ? UNIT : 0) + UNIT/7] + [SLOP, SLOP];
  outer = inner + 2 * [BOARDER, BOARDER];
  translate([-(outer[0] + GAP), 0, 0])
    difference() {
      cube([each outer, 1.5 * THICKNESS]);
      translate([BOARDER, BOARDER, THICKNESS]) {
        dx = inner[0]/7;
        dy = inner[1]/(STUBY ? 8 : 7);
        cube([each inner, THICKNESS]);

        // Board orientation revealed by smiley face!
        font = "Liberation Sans:style=Bold";
        translate([3.5*dx-GRID/2, 3.5*dy-GRID/2, -GRID])
          linear_extrude(THICKNESS)
            text("☺", size = UNIT, halign="center", valign="center", font=font, $fn=40);

        // Gridlines
        for (i=[1:6]) {
          translate([i * dx - GRID/2, 0, -GRID])
            cube([GRID, inner[1], THICKNESS]);
        }
        
        for (i=[1:(STUBY ? 7 : 6)]) {
          translate([0, i*dy - GRID/2, -GRID])
            cube([inner[0], GRID, THICKNESS]);
        }
      }
    }
}

function cumsum(v) = [for (i=0, b=v[0]; i < len(v); i=i+1, b=(i<len(v)?b+v[i]:b)) b];
function center(v) = cumsum(v)[len(v)-1] / len(v);

tile(P1, STUBY ? [2.5, 6.8] : [1.5, 6.1], [1, 2]);
tile(P2, [2.5, 3.5], [1, 1]);
tile(P3, center(P3), [2, 1]);
tile(P4, [2, 0.5]);
tile(P5, center(P5), [2, 0]);
board();




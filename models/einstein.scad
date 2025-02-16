// Einstein Tiles

// Which colors to print.
COLOR_FILTER = "all"; // ["all", "blue", "red"]

UNIT = 10;
THICKNESS = 3;

/* [Hidden] */

// Construction of "Hat" (or "T-Shirt") from union of kites
module union_tile() {
  TGRID = 20;
  P0 = [0, 0];
  P1 = [TGRID, 0];
  P2 = P1 * rot(60);
  P3 = (P0 + P1 + P2) / 3;

  kite_v = [P0, P1/2, P3, P2/2];
  ks = [for (i=[0:5]) kite_v*rot(60*i)];
      
  parts = [ks[0], ks[1], ks[4], ks[5],
           add(ks[1], P1), add(ks[2], P1),
           add(ks[3], P2), add(ks[4], P2)
          ];

  color_part("blue")
      linear_extrude(THICKNESS/2) {
          for (p=parts) polygon(p);
      }
  color_part("red")
      translate([0, 0, THICKNESS/2])
      linear_extrude(THICKNESS/2) {
          for (p=parts) polygon(p);   
      }    
}

// Construction as a path of vectors.  This is more
// amenable to generating the whole family of Tile(a,b)
// tiles, where:
// Tile(1, sqrt(3)) = "Hat"
// Tile(sqrt(3), 1) = "Turtle"
// Tile(1,1) = basis of Spectre 
// Tile(0, 1) = "Chevron"
// Tile(1, 0) = "Comet"
function tile_v(a, b) = cumvec([
    [0, b], [90, a], [30, a], [120, b], [60, b], [150, a],
    [210, 2 * a], [270, a], [180, b], [240, b], [330, a], [30, a]
    ]);
    
module tile_half(a, b) {
  vecs = UNIT * tile_v(a, b);
  linear_extrude(THICKNESS/2)
    polygon(vecs, convexity=2);
}

module tile(a=1, b=sqrt(3)) {
  color_part("blue") tile_half(a, b);
  translate([0, 0, THICKNESS/2])
    color_part("red") tile_half(a, b);
}

tile(1, sqrt(3));
translate([6 * UNIT, 0, 0])
  tile(1, 1);
translate([12 * UNIT, 0, 0])
  tile(sqrt(3), 1);
translate([0, 6 * UNIT, 0])
  tile(0, 1);
translate([7 * UNIT, 6 * UNIT, 0])
  tile(1, 0);

function rot(a) = [[cos(a), sin(a)], [-sin(a), cos(a)]];
function add(poly, o) = [for (p=poly) p + o];
function cumsum(v) = [for (i=0, b=v[0]; i < len(v); i=i+1, b=(i<len(v)?b+v[i]:b)) b];
function cumvec(v) = cumsum([[0, 0], each [for (s=v) s[1]*[cos(s[0]), sin(s[0])]]]);

// Need to be able to conditionally render parts based on color (for
// export to Bambu Studio for slicing.
module color_part(c) {
    if (COLOR_FILTER == "all" || c == COLOR_FILTER) {
        color(c) children();
    }
}


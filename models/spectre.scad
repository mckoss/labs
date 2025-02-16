// Build the aperidic Spectre Tile
SIZE = 20;

/* [Hidden] */
// Include BOSL2 first so I can use the rot function in einstein (not overridden)
include<BOSL2/std.scad> 

no_side_effects = true;
include<einstein.scad>

// Close the polygon to get the basis of the Spectre
// the Tile(1, 1) tile.
points = SIZE * [each tile_v(1, 1), [0, 0]];

function offset_mid(p1, p2, right) = (p1 + p2) / 2 + (p2 - p1) / 8 * rot(right?-90:90);

function curvify(v) = [for (i=[0:len(v)-2]) each
    arc(20, points=[v[i], offset_mid(v[i], v[i+1], i % 2 != 0), v[i+1]], endpoint=false)];

linear_extrude(height=4)
  polygon(curvify(points), convexity=2);

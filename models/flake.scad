// Snowflake generator
// by Mike Koss (c) 2013

use <write.scad>

MAX_HEIGHT = 5;
MIN_HEIGHT = 2;
RADIUS = 50;
LEVEL = 3;
E = 0.1;

module hex(level, radius, pos, dir, children=3) {
  if (level >=1) {
    if (radius * 0.3 > 2) {
      translate([pos[0], pos[1], 0])
        linear_extrude(height=combine(dist(pos) / RADIUS, MAX_HEIGHT, MIN_HEIGHT) * 0.8, scale=0.9)
          circle(r=radius * 0.4, $fn=6);
    }
    for (i = [-1 : children - 2]) {
      assign(child1 = pos + radius * unit(dir + 60 * i) * 0.4,
             child2 = pos + radius * unit(dir + 60 * i) * 0.8) {
          if (radius > 5) {
            line(pos, dir + 60 * i, radius);
          }
          hex(level - 1, radius * 0.3, child1, (dir + 60 * i) % 360);
          hex(level - 1, radius * 0.4, child2, (dir + 60 * i) % 360);
      }
    }
  }
}

// Draw a wedge-shaped line scaled to gradient from center.
module line(pos, dir, len) {
  // Unit triangle extended 1 unit along x axis.
  //           5
  //          / \
  //     2   4-- 3
  //    / \
  //   1---0
  h1 = combine(dist(pos) / RADIUS, MAX_HEIGHT, MIN_HEIGHT);
  s1 = h1 / sin(60);
  pos2 = pos + len * unit(dir);
  h2 = combine(dist(pos2) / RADIUS, MAX_HEIGHT, MIN_HEIGHT);
  s2 = h2 / sin(60);
  if (h2 > 0) {
    translate([pos[0], pos[1], 0])
      rotate(dir, v=[0, 0, 1])
        polyhedron(
          points=[
            [0, -s1 / 2, 0], [0, s1 / 2, 0], [0, 0, h1],
            [len, -s2 / 2, 0], [len, s2 / 2, 0], [len, 0, h2]
          ],
          triangles=[
            [0, 1, 2],
            [0, 2, 5], [0, 5, 3],
            [0, 3, 4], [0, 4, 1],
            [1, 4, 5], [1, 5, 2],
            [3, 5, 4]
          ]
        );
  }
}

function unit(dir) = [cos(dir), sin(dir)];
function dist(pos) = sqrt(pos[0]*pos[0] + pos[1]*pos[1]);
function combine(f, x0, x1) = x0 * (1 - f) + x1 * f;

// Ring around origin (at z=0)
module ring(r, thickness, height) {
  translate([0, 0, height / 2]) {
    difference() {
      cylinder(h=height, r=r, $fa=3, center=true);
      cylinder(h=height + 2 * E, r=r - thickness, $fa=3, center=true);
    }
  }
}

difference() {
  hex(LEVEL, 40, [0, 0], 0, 6);
  rotate(a=-90, v=[0, 0, 1])
    rotate(a=180, v=[0, 1, 0]) {
      write("2013", h=8, t=MAX_HEIGHT / 2, center=true, font="Letters.dxf");
        translate([0, -7, 0])
          write("MCK", h=4, t=MAX_HEIGHT / 4, center=true, font="Letters.dxf");
    }
}
translate([54, 0, 0])
  ring(5, 1, MIN_HEIGHT);
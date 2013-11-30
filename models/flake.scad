// Snowflake generator

MAX_HEIGHT = 7;
MIN_HEIGHT = 1;
RADIUS = 50;

module flake(radius, base) {
  for (i = [0 : 5]) {
    hex3([0, 0], 60 * i, radius, base);
  }
}

module hex3(pos, dir, len, side) {
  line(pos, dir, len * 0.7);
  assign(child = pos + len * 0.3 * unit(dir)) {
    line(child, dir + 60, len * 0.3);
    line(child, dir - 60, len * 0.3);
  }
  assign(child = pos + len * 0.7 * unit(dir)) {
    line(child, dir + 60, len * 0.2);
    line(child, dir - 60, len * 0.2);
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

function unit(dir) = [cos(dir), sin(dir)];
function dist(pos) = sqrt(pos[0]*pos[0] + pos[1]*pos[1]);
function combine(f, x0, x1) = x0 * (1 - f) + x1 * f;

//line([0, 0], 0, 50);
//line([0, 0], 60, 25);
//hex3([0, 0], 60, 50, 10);
flake(50, 10);

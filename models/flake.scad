// Snowflake generator

module flake(radius, base) {
  for (i = [0 : 5]) {
    spike3([0, 0], 60 * i, radius, base);
  }
}

module spike3(pos, dir, len, side) {
  echo("Arm:", pos, len, side);
  spike(pos, dir, len, side);
  assign(child = pos + len * 0.3 * unit(dir)) {
    spike(child, dir + 60, len * 0.2, side * 0.7);
    spike(child, dir - 60, len * 0.2, side * 0.7);
  }
  assign(child = pos + len * 0.6 * unit(dir)) {
    spike2(child, dir + 60, len * 0.3, side * 0.4);
    spike2(child, dir - 60, len * 0.3, side * 0.4);
  }
}

// Recursion not working????
module spike2(pos, dir, len, side) {
  echo("Arm2:", pos, len, side);
  spike(pos, dir, len, side);
  assign(child = pos + len * 0.5 * unit(dir)) {
    spike(child, dir + 60, len * 0.3, side * 0.5);
    spike(child, dir - 60, len * 0.3, side * 0.5);
  }
}

module spike(pos, dir, len, side) {
  // Unit triangle extended 1 unit along x axis.
  //
  //     2---3   x
  //    / \ /   /
  //   1---0   -->-y

  translate([pos[0], pos[1], 0])
    rotate(dir, v=[0, 0, 1])
      scale([len, side, side])
  polyhedron(
    points=[
      [0, -0.5, 0], [0, 0.5, 0], [0, 0, sin(60)], [1, 0, 0]
    ],
    triangles=[
      [0, 1, 2], [0, 2, 3], [0, 3, 1], [1, 3, 2]
    ]
  );
}

MAX_HEIGHT = 10;
MIN_HEIGHT = 1;
RADIUS = 50;

module flake2(radius, base) {
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
  h1 = weighted(dist(pos) / RADIUS, MAX_HEIGHT, MIN_HEIGHT);
  s1 = h1 / sin(60);
  pos2 = pos + len * unit(dir);
  h2 = weighted(dist(pos2) / RADIUS, MAX_HEIGHT, MIN_HEIGHT);
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
function weighted(f, x0, x1) = x0 * (1 - f) + x1 * f;

//spike([0, 0], 0, 50, 10);
//spike([0, 0], 60, 50, 10);
//spike2([0, 0], 60, 50, 10);
//spike3([0, 0], 60, 50, 10);
//flake(50, 10);
//line([0, 0], 0, 50);
//line([0, 0], 60, 25);
//hex3([0, 0], 60, 50, 10);
flake2(50, 10);

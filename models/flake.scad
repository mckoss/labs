// Snowflake generator

module flake(radius, base) {
  for (i = [0 : 5]) {
    arm([0, 0], 60 * i, radius, base);
  }
}

function unit(dir) = [cos(dir), sin(dir)];

module arm(pos, dir, len, side) {
  echo("Arm:", pos, len);
  spike(pos, dir, len, side);
  if (len > 10) {
    assign(child = pos + len * 0.5 * unit(dir)) {
      arm(child, dir + 60, len * 0.3, side * 0.5);
      arm(child, dir - 60, len * 0.3, side * 0.5);
    }
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

//spike([0, 0], 0, 50, 10);
flake(50, 10);
//arm([0, 0], 60, 50, 10);
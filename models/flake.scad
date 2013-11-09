// Snowflake generator

module flake(radius, base) {
  for (i = [0 : 5]) {
    spike3([0, 0], 60 * i, radius, base);
  }
}

function unit(dir) = [cos(dir), sin(dir)];

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

//spike([0, 0], 0, 50, 10);
flake(50, 10);
//arm([0, 0], 60, 50, 10);
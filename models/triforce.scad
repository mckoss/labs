SIDE = 80;
OVERLAP = 3;

module tetra_fractal(side, depth=1) {
  h2 = side * sin(60);
  h3 = h2 * sin(60);
  if (depth == 1) {
    translate([-side/2, -h2/3, 0])
    polyhedron(
      points=[[0, 0, 0], [side, 0, 0], [side/2, h2, 0],
            [side/2, h2/3, h3]],
      triangles=[[0, 1, 2], [0, 3, 1], [1, 3, 2], [2, 3, 0]]
    );
  } else {
    translate([-side/4, -h2/6, 0])
      tetra_fractal(side/2 + OVERLAP, depth - 1);
    translate([side/4, -h2/6, 0])
      tetra_fractal(side/2 + OVERLAP, depth - 1);
    translate([0, h2/3, 0])
      tetra_fractal(side/2 + OVERLAP, depth - 1);
    translate([0, 0, h3/2])
      tetra_fractal(side/2 + OVERLAP, depth - 1);
  }
}

rotate(180, v=[0, 1, 0])
  difference() {
    tetra_fractal(SIDE, 3);
    # translate([0, 0, SIDE * (sin(60)*sin(60) + 0.5)])
      cube([SIDE, SIDE, SIDE], center=true);
}

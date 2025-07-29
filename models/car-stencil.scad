H=2;
E=0.2;

CHAMFER = 1; // [0:.1:2]

module stencil() {
  difference() {
    translate([49, 26, 0])
      chamfered_box(100, 57, H);
    car();
  }
}
  
module car() {
    translate([0, 0, -E])
    if (CHAMFER > 0) {
      minkowski() {
        linear_extrude(height=E)
          import("car-stencil.svg");
        cylinder(h=H+2*E, r1=0, r2=CHAMFER, $fn=4);
      }
    } else {
      linear_extrude(H + 2*E)
        import("car-stencil.svg");
    }
}


module chamfered_box(width, height, depth, radius=1, steps=5) {
    x0 = width / 2;
    y0 = height / 2;
    d = depth;
    r = radius;
    z0 = d - r;

    tile_points = concat(
        [[-x0, -y0, 0], [x0, -y0, 0], [x0, y0, 0], [-x0, y0, 0]],
        flatten([for (i = [0 : steps])
            let (theta = i * 90 / steps,
                 dx = r * (1 - cos(theta)),
                 dz = r * sin(theta),
                 x = x0 - dx,
                 y = y0 - dx,
                 z = z0 + dz)
            [[-x, -y, z], [x, -y, z], [x, y, z], [-x, y, z]]
        ]));
    last = len(tile_points) - 1;
    tile_faces = concat(
        // Bottom and top faces
        [[0, 1, 2, 3], [last, last - 1, last - 2, last - 3]],
        flatten([for (i = [0 : steps])
            let (base = i * 4)
            [[base, base + 4, base + 5, base + 1],
             [base + 1, base + 5, base + 6, base + 2],
             [base + 2, base + 6, base + 7, base + 3],
             [base + 3, base + 7, base + 4, base]]
        ]));
    polyhedron(points=tile_points, faces=tile_faces);
}

function flatten(l) = [ for (a = l) for (b = a) b ];
  
stencil();


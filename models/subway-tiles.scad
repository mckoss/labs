// Subway tile signs

TILE_WIDTH = 20;
TILE_DEPTH = 3;
TILE_SPACING = 1;
CHAMFER_RADIUS = 1;
CHAMFER_STEPS = 3;

module T() {
    x0 = TILE_WIDTH / 2;
    d = TILE_DEPTH;
    r = CHAMFER_RADIUS;
    z0 = d - r;
    
    tile_points = concat(
        [[-x0, -x0, 0], [x0, -x0, 0], [x0, x0, 0], [-x0, x0, 0]],
        flatten([for (i = [0 : CHAMFER_STEPS])
            let (theta = i * 90 / CHAMFER_STEPS,
                 dx = r * (1 - cos(theta)),
                 dz = r * sin(theta),
                 x = x0 - dx,
                 z = z0 + dz)
            [[-x, -x, z], [x, -x, z], [x, x, z], [-x, x, z]]
        ]));
    last = len(tile_points) - 1;
    tile_faces = concat(
        // Bottom and top faces
        [[0, 1, 2, 3], [last, last - 1, last - 2, last - 3]],
        flatten([for (i = [0 : CHAMFER_STEPS])
            let (base = i * 4)
            [[base, base + 4, base + 5, base + 1],
             [base + 1, base + 5, base + 6, base + 2],
             [base + 2, base + 6, base + 7, base + 3],
             [base + 3, base + 7, base + 4, base]]
        ]));
    polyhedron(points=tile_points, faces=tile_faces);
}

module tiles(list, rows=5, cols=3) {
    DX = TILE_WIDTH + TILE_SPACING;
    for (i = [0:len(list)-1]) {
        row = floor(list[i] / cols) - (rows - 1)/2;
        col = list[i] % cols - (cols - 1)/2;
        translate([col * DX, -row * DX, 0])
            T();
    }
}

function flatten(l) = [ for (a = l) for (b = a) b ];

tiles([0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
   

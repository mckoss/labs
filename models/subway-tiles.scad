// Subway tile signs

TILE_WIDTH = 15;
TILE_DEPTH = 1.5;
TILE_SPACING = 1;
CHAMFER_RADIUS = 0.75;
CHAMFER_STEPS = 3;

module T() {
    X = TILE_WIDTH / 2;
    D = TILE_DEPTH;
    X1 = X - CHAMFER_RADIUS;
    polyhedron(
        points=[
            [-X, -X, 0], [X, -X, 0], [X, X, 0], [-X, X, 0],
            [-X1, -X1, D], [X1, -X1, D], [X1, X1, D], [-X1, X1, D]],
        faces=[[0, 1, 2, 3], [7, 6, 5, 4],
               [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0] ]
    );
}

module tiles(list, rows=5, cols=3) {
    DX = TILE_WIDTH + TILE_SPACING;
    for (i = [0:len(list)-1]) {
        row = floor(list[i] / cols) - (rows - 1)/2;
        col = list[i] % cols - (cols - 1)/2;
        translate([col * DX, row * DX, 0])
            T();
    }
}

tiles([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);

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

// Mostly 3x5 but a couple of 4x5
// First number is columns used
// Remaining are indicies starting with 0 at top left.
ALPHA5_CAPS = [
    [3, 1, 3, 5, 6, 7, 8, 9, 11, 12, 14], // A
    [3, 0, 1, 2, 3, 5, 6, 7, 8, 9, 11, 12, 13, 14], // B
    [3, 0, 1, 2, 3, 6, 9, 12, 13, 14], // C
    [3, 0, 1, 3, 5, 6, 8, 9, 11, 12, 13], // D
    [3, 0, 1, 2, 3, 6, 7, 8, 9, 12, 13, 14], // E
    [3, 0, 1, 2, 3, 6, 7, 8, 9, 12], // F
    [3, 0, 1, 2, 3, 6, 8, 9, 11, 12, 13, 14], // G
    [3, 0, 2, 3, 5, 6, 7, 8, 9, 11, 12, 14], // H
    [1, 0, 1, 2, 3, 4], // I
    [3, 2, 5, 8, 9, 11, 12, 13, 14], // J
    [3, 0, 2, 3, 4, 6, 9, 10, 12, 14], // K
    [3, 0, 3, 6, 9, 12, 13, 14], // L
    [4, 0, 3, 4, 5, 7, 8, 10, 11, 12, 15, 16, 19], // M
    [3, 0, 2, 3, 4, 5, 6, 8, 9, 11, 12, 14], // N
    [3, 0, 1, 2, 3, 5, 6, 8, 9, 11, 12, 13, 14], // O
    [3, 0, 1, 2, 3, 5, 6, 7, 8, 9, 12], // P
    [3, 0, 1, 2, 3, 5, 6, 8, 9, 10, 11, 12, 13, 14], // Q
    [3, 0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 12, 14], // R
    [3, 0, 1, 2, 3, 6, 7, 8, 11, 12, 13, 14], // S
    [3, 0, 1, 2, 4, 7, 10, 13], // T
    [3, 0, 2, 3, 5, 6, 8, 9, 11, 12, 13, 14], // U
    [3, 0, 2, 3, 5, 6, 8, 10, 13], // V
    [4, 0, 3, 4, 7, 8, 10, 11, 12, 13, 15, 16, 19], // W
    [3, 0, 2, 4, 7, 10, 12, 14], // X
    [3, 0, 2, 4, 7, 10, 13], // Y
    [3, 0, 1, 2, 5, 7, 9, 12, 13, 14] // Z
];

module message(s, letter_forms=ALPHA5_CAPS) {
    DX = TILE_WIDTH + TILE_SPACING;
    offsets = message_offsets(s, letter_forms);
    for (i = [0:len(s)-1]) {
        translate([offsets[i] * DX, 0, 0])
            letter5(s[i]);
    }
}

function message_offsets(s, letter_forms=ALPHA5_CAPS) =
    cumsum([0, for (i = [0:len(s)-2])
        let (index = ord(s[i]) - ord("A"),
             is_letter = index >= 0 && index < len(letter_forms))
        is_letter ? letter_forms[index][0] + 1 : 0]);
    

module letter5(ch) {
    i = ord(ch) - ord("A");
    if (i >= 0 && i < len(ALPHA5_CAPS)) {
        color("blue") tiles(cols=ALPHA5_CAPS[i][0], tail(ALPHA5_CAPS[i]));
    } else {
        echo("Unrecognized letter", ch);
    }
}

function flatten(l) = [ for (a = l) for (b = a) b ];
function tail(v) = len(v) > 1 ? [for (i = [1:len(v)-1]) v[i]] : [];

TEST_MESSAGE = "HELLO WORLD";
echo(message_offsets(TEST_MESSAGE));
message(TEST_MESSAGE);
    
function cumsum(v) = [for (a=0, b=v[0]; a < len(v); a= a+1, b=b+(v[a]==undef?0:v[a])) b];


// NY Subway tiled sign generator.

// This module uses colors as:
//
// blue - Letter tiles
// white - Background tiles
// black - Base layer (and border tiles).
COLOR_FILTER = "all";

TILE_WIDTH = 10;
TILE_DEPTH = 3;
TILE_SPACING = 0.5;
CHAMFER_RADIUS = 0.5;
CHAMFER_STEPS = 3;
BASE_THICKNESS = 1;

BORDER_TILES = 1;
SURROUND_TILES = 1;

DX = TILE_WIDTH + TILE_SPACING;

include <fonts-3x5.scad>;

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

// Top align rows and left align columns
module tiles(list, rows=5, cols=3) {
    for (i = [0:len(list)-1]) {
        row = floor(list[i] / cols);
        col = list[i] % cols;
        tile_at(row, col);
    }
}

module tile_at(row, col) {
    translate([col * DX, -row * DX, BASE_THICKNESS])
        T();
}

module tile_line(cols) {
    for (i = [0: cols - 1]) {
        translate([i * DX, 0, BASE_THICKNESS])
            T();
    }
}

// rect = [left, top, right, bottom]
module tile_box(rect) {
    // Horizontal parts
    for (col = [rect[0]:rect[2]]) {
        tile_at(rect[1], col);
        tile_at(rect[3], col);
    }
    for (row = [rect[1]:rect[3]]) {
        tile_at(row, rect[0]);
        tile_at(row, rect[2]);
    }
}

// Generate a sign with a order and background surround.
module sign(lines, letter_forms=ALPHA5_CAPS) {
    line_widths = [for (m = lines) measure_message(m, letter_forms)];
    rows = rows_of(letter_forms);
    max_width = maxvalue(line_widths);
    
    // Text lines (centered)
    for (i = [0:len(lines)-1]) {
        width = line_widths[i];
        extra = max_width - width;
        left = floor(extra/2);
        right = extra - left;
        translate([0, -(rows + 1) * i * DX, 0]) {
            translate([left * DX, 0, 0])
                message(lines[i], letter_forms);
        
            // Left padding
            if (left > 0) {
                for (j = [0:left - 1]) {
                    translate([DX * j, 0, 0])
                        color_part("white") tiles([for (row = [0: rows - 1]) row], rows, 1);
                }
            }
            
            // Right padding
            if (right > 0) {
                for (j = [0:right - 1]) {
                    translate([DX * (left + width + j), 0, 0])
                        color_part("white") tiles([for (row = [0: rows - 1]) row], rows, 1);
                }
            }
        }
    }
    
    // Horizontal inter-line background
    for (i = [0:len(lines)-2]) {
        translate([0, -DX * ((rows + 1) * (i + 1) - 1), 0])
            color_part("white") tile_line(max_width);
    }
    
    text_rows = (rows + 1) * len(lines) - 1;
    border = SURROUND_TILES + BORDER_TILES;
    translate([-DX * border, DX * border, 0])
        base_layer(text_rows + 2 * border, max_width + 2 * border);
    
    for (i = [0: SURROUND_TILES - 1]) {
        color_part("white") tile_box([-i-1, -i-1, max_width+i, text_rows+i]);
    }
    
    for (i = [SURROUND_TILES: SURROUND_TILES + BORDER_TILES -1]) {
        color_part("black") tile_box([-i-1, -i-1, max_width+i, text_rows+i]);
    }
}

module message(s, letter_forms=ALPHA5_CAPS) {
    DX = TILE_WIDTH + TILE_SPACING;
    offsets = message_offsets(s, letter_forms);
    rows = rows_of(letter_forms);

    for (i = [0:len(s)-1]) {
        translate([offsets[i] * DX, 0, 0])
            letter(s[i], letter_forms);
        // Draw white tile column between letters
        if (i != len(s)-1) {
            translate([(offsets[i+1] - 1) * DX, 0, 0]) {
                    color_part("white") tiles([for (row = [0: rows - 1]) row], rows, 1);
            }
        }
    }
}

function message_offsets(s, letter_forms) =
    cumsum([0, for (i = [0:len(s)-1])
        is_member(s[i], letter_forms) ? tile_list(s[i], letter_forms)[0] + 1 : 2]);
    
function measure_message(s, letter_forms) =
    let (offsets = message_offsets(s, letter_forms)) offsets[len(offsets) - 1] - 1;

module letter(ch, letter_forms) {
    rows = rows_of(letter_forms);
    if (is_member(ch, letter_forms)) {
        raw_tiles = tile_list(ch, letter_forms);
        cols = raw_tiles[0];
        blue_tiles = tail(raw_tiles);
        white_tiles = missing_tiles(blue_tiles, rows, cols);
        color_part("blue") tiles(blue_tiles, rows, cols);
        if (len(white_tiles) > 0) {
            color_part("white") tiles(white_tiles, rows, cols);
        }
    } else {
        // Treat unknown character as a space - a single blank column.
        color_part("white") tiles([for (row = [0: rows - 1]) row], rows, 1);
    }
}

module base_layer(rows, cols) {
    height = rows * DX - TILE_SPACING;
    color_part("black")
        translate([-TILE_WIDTH/2, TILE_WIDTH/2 - height, 0])
            cube([cols * DX - TILE_SPACING, height, BASE_THICKNESS]);
}

// Letter-form data structure utilities.
function rows_of(letter_forms) = letter_forms[0];
function index_of(ch, letter_forms) = ord(ch) - letter_forms[1];
function is_member(ch, letter_forms) =
    let (index = index_of(ch, letter_forms))
    index >= 0 && index < len(letter_forms[2]);
function tile_list(ch, letter_forms) = letter_forms[2][index_of(ch, letter_forms)];

module font_sampler(letter_forms=ALPHA5_CAPS) {
    num_symbols = len(letter_forms[2]);
    start_code = letter_forms[1];
    end_code = start_code + num_symbols - 1;
    
    // Favor more width - since letters are generally taller.
    cols = floor(sqrt(num_symbols) * 1.5);
    rows = ceil(num_symbols / cols);
    
    echo(rows, cols, num_symbols);
    
    lines = [for (row = [0: rows - 1])
        let (start = start_code + cols * row,
             end = min(end_code, start_code + cols * (row + 1) - 1))
            [for (c = [start: end]) chr(c)]
        ];
    sign(lines);
}

// Compute the negative space of a letter matrix.
function missing_tiles(tiles, rows, cols) =
    [for (i = [0: rows * cols - 1]) if (indexof(i, tiles) == -1) i];

// List/vector helper functions
function flatten(l) = [ for (a = l) for (b = a) b ];
function tail(v) = len(v) > 1 ? [for (i = [1:len(v)-1]) v[i]] : [];
function cumsum(v) = [for (a=0, b=v[0]; a < len(v); a= a+1, b=b+(v[a]==undef?0:v[a])) b];
function indexof(v, l) = let (s = search(v, l)) len(s) == 0 ? -1 : s[0];
function maxvalue(v) = let (a = [for (i=0, m=v[0]; i < len(v); i= i+1, m=max(m,v[i]==undef?m:v[i])) m]) a[len(a)-1];

// Need to be able to conditionally render parts based on color (for
// export to Bambu Studio for slicing.
module color_part(c) {
    if (COLOR_FILTER == "all" || c == COLOR_FILTER) {
        color(c) children();
    }
}

font_sampler(ALPHA5_CAPS);

//sign(["CAROL", "KOSS"]);

// NY Subway tiled sign generator.

// This module uses colors as:
//
// blue - Letter tiles (default color)
// white - Background tiles
// black - Base layer (and border tiles).
// red - Alternate letter color
// green - Alternate letter color
// all - Display all colors.
// [Customizer values listed for dropdown]

/* [Layout and Printing Options] */

// Number of rows of black tiles forming a border.
BORDER_TILES = 1;
// Number of rows of black tiles around lettering.
SURROUND_TILES = 1;

// Which colors to print.
COLOR_FILTER = "all"; // ["all", "black", "white", "blue", "red", "green"]

// Tiny 3x5 is blockier and Tiny 3x5 Bias is smoothed with half-tile triangles
FONT_CHOICE = "Tiny 3x5 Bias"; // ["Tiny 3x5", "Tiny 3x5 Bias"]

// Change to print a range of (tile) columns of a sign (inclusive of the border and surround tiles).
FIRST_COLUMN = 0;
// Negative values count back from the right edge of the sign.
LAST_COLUMN = -1;

// Display a font sampler instead of a sign.
SHOW_FONT = false;

/* [Text] */

// Display a sign with up to 4 lines of text.  Use ~r to switch to red letters.
FIRST_LINE = "I~r♡~bNY";

// Leave lines blank to omit them.
SECOND_LINE = "";
THIRD_LINE = "";
FOURTH_LINE = "";

/* [Dimensions] */

// Size of tile (mm)
TILE_WIDTH = 10;
// Thickness of tiles (mm)
TILE_DEPTH = 3;
// The "grout" thickness between tiles (mm)
TILE_SPACING = 0.5;
// Radius of chamfer (rounded corners) (mm)
CHAMFER_RADIUS = 0.5;
// Resolution of curve (number of steps from top to side)
CHAMFER_STEPS = 3;
// Thickness of flat sheet connecting all tiles (mm)
BASE_THICKNESS = 1.0; // [0:0.1:5]

DX = TILE_WIDTH + TILE_SPACING;

/* [Hidden] */

// Control character for color change
// Followed by "r", "g", "b", "k", or "w" for red, green, blue, black, or white.
COLOR_CHANGE = "~";

include <fonts-3x5.scad>;

FONT_SET = [FONT_CHOICE == "Tiny 3x5" ? TINY_3x5 : TINY_3x5_BIAS,
            TINY_3x5_SUITS];

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
module tiles(list, rows=5, cols=3, col_offset=0, total_columns) {
    for (i = [0:len(list)-1]) {
        if (is_num(list[i])) {
            row = floor(list[i] / cols);
            col = list[i] % cols;
            tile_at(row, col + col_offset, total_columns);
        } else {
            row = floor(list[i][0] / cols);
            col = list[i][0] % cols;
            half_tile_at(row, col + col_offset, list[i][1], total_columns);
        }
    }
}

// All tiles rendering goes through these two functions - so we can use
// it to filter which columns are displayed.  Note that the text
// columns start at 0 and so FIRST_COLUMN is relative to -border-surround.
module tile_at(row, col, total_columns) {
    extent = tile_column_extent(total_columns);
    if (col >= extent[0] && col <= extent[1]) {
        translate([col * DX, -row * DX, BASE_THICKNESS])
            T();
    }
}

// Triangular halves (clockwise) at rot 1, 3, 5, and 7.
module half_tile_at(row, col, rot, total_columns) {
    extent = tile_column_extent(total_columns);
    if (col >= extent[0] && col <= extent[1]) {
        translate([col * DX, -row * DX, BASE_THICKNESS])
            // Force a render here - because openscad will otherwise bleed the
            // color in the subtracted region to unrelated parts!
            render()
            difference() {
                T();
                rotate(180 - 45 * rot)
                    translate([0, TILE_WIDTH - TILE_SPACING / 2, TILE_DEPTH / 2])
                        cube([2 * TILE_WIDTH, 2 * TILE_WIDTH, 2 * TILE_DEPTH], center=true);
            }
    }
}

function tile_column_extent(total_columns) =
    let (first_column = FIRST_COLUMN - BORDER_TILES - SURROUND_TILES,
         last_column = (LAST_COLUMN - BORDER_TILES - SURROUND_TILES + total_columns) % total_columns)
    [first_column, last_column];

module tile_line(cols, total_columns) {
    for (i = [0: cols - 1]) {
        tile_at(0, i, total_columns);
    }
}

// Draw a rectangular (1 tile wide) rectangle
// at the given coordinates.
//
// rect = [left, top, right, bottom]
module tile_box(rect, total_columns) {
    // Horizontal parts
    for (col = [rect[0]:rect[2]]) {
        tile_at(rect[1], col, total_columns);
        tile_at(rect[3], col, total_columns);
    }
    for (row = [rect[1]:rect[3]]) {
        tile_at(row, rect[0], total_columns);
        tile_at(row, rect[2], total_columns);
    }
}

// Generate a sign with a border and background surround.
module sign(lines, letter_forms_list=FONT_SET) {
    line_widths = [for (m = lines) measure_message(m, font_indices(m, visible_letters(m), letter_forms_list), letter_forms_list)];
    rows = rows_of(letter_forms_list[0]);
    max_width = maxvalue(line_widths);
    border = SURROUND_TILES + BORDER_TILES;
    total_columns = max_width + 2 * border;

    // Text lines (centered)
    for (i = [0:len(lines)-1]) {
        width = line_widths[i];
        extra = max_width - width;
        left = floor(extra/2);
        right = extra - left;
        translate([0, -(rows + 1) * i * DX, 0]) {
            message(lines[i], letter_forms_list, left, total_columns);

            // Left padding
            if (left > 0) {
                for (j = [0:left - 1]) {
                    color_part("white") tiles([for (row = [0: rows - 1]) row], rows, 1, j, total_columns);
                }
            }

            // Right padding
            if (right > 0) {
                for (j = [0:right - 1]) {
                    color_part("white") tiles([for (row = [0: rows - 1]) row], rows, 1, left + width + j, total_columns);
                }
            }
        }
    }

    // Horizontal inter-line background
    if (len(lines) > 1) {
        for (i = [0:len(lines)-2]) {
            translate([0, -DX * ((rows + 1) * (i + 1) - 1), 0])
                color_part("white") tile_line(max_width, total_columns);
        }
    }

    text_rows = (rows + 1) * len(lines) - 1;
    extent = tile_column_extent(total_columns);
    echo(extent, max_width + border);
    translate([DX * (FIRST_COLUMN - border), DX * border, 0])
        base_layer(text_rows + 2 * border, extent[1] - extent[0] + 1, extent[1] == max_width + border - 1);

    if (SURROUND_TILES > 0) {
        for (i = [0: SURROUND_TILES - 1]) {
            color_part("white") tile_box([-i-1, -i-1, max_width+i, text_rows+i], total_columns);
        }
    }

    if (BORDER_TILES > 0) {
        for (i = [SURROUND_TILES: SURROUND_TILES + BORDER_TILES - 1]) {
            color_part("black") tile_box([-i-1, -i-1, max_width+i, text_rows+i], total_columns);
        }
    }
}

// Function to map color codes to actual colors
// The letter "i" is reserved for "invisible" color (letter skipped
// because it is part of a color change command).
function get_color_from_code(code) =
    code == "r" ? "red" :
    code == "g" ? "green" :
    code == "b" ? "blue" :
    code == "k" ? "black" :
    code == "w" ? "white" :
    "blue"; // Default color

module message(s, letter_forms_list=FONT_SET, col_offset=0, total_columns=100) {
    visible = visible_letters(s);
    fonts = font_indices(s, visible, letter_forms_list);
    offsets = message_offsets(s, visible, fonts, letter_forms_list);
    colors = message_colors(s, visible);
    // Assumes all fonts have same height.
    rows = rows_of(letter_forms_list[0]);

    for (i = [0:len(s)-1]) {
        if (visible[i]) {
            letter(s[i], rows, letter_forms_list[fonts[i]], get_color_from_code(colors[i]), offsets[i]+col_offset, total_columns);
            // Draw white tile column between letters
            if (i != len(s)-1) {
                color_part("white") tiles([for (row = [0: rows - 1]) row], rows, 1, offsets[i+1] - 1 + col_offset, total_columns);
            }
        }
    }
}

// Boolean array indicating whether a letter in a message string
// is visible (vs. being a command character).
function visible_letters(m) =
    [for (i=0, after_prefix = false;
          i < len(m);
          after_prefix = !after_prefix && m[i] == COLOR_CHANGE,
          i = i + 1)
     after_prefix && m[i] == COLOR_CHANGE || !after_prefix && m[i] != COLOR_CHANGE];

function message_offsets(s, visible, fonts, letter_forms_list) =
    cumsum([0, for (i = [0:len(s)-1])
        !visible[i] ? 0 :
        fonts[i] != undef && is_member(s[i], letter_forms_list[fonts[i]]) ? tile_list(s[i], letter_forms_list[fonts[i]])[0] + 1 :
        2]);

function message_colors(s, visible) =
    [for (i = 0, current_color = "b"; i < len(s);
          i = i + 1,
          current_color = i > 0 && s[i-1] == COLOR_CHANGE && !visible[i] ? s[i] : current_color)
        current_color];

function measure_message(s, fonts, letter_forms_list) =
    let (offsets = message_offsets(s, visible_letters(s), fonts, letter_forms_list))
    len(offsets) > 0 ? offsets[len(offsets) - 1] - 1 : 0;

module letter(ch, rows, letter_forms, color="blue", col_offset=0, total_columns) {
    if (is_member(ch, letter_forms)) {
        raw_tiles = tile_list(ch, letter_forms);
        cols = raw_tiles[0];
        blue_tiles = tail(raw_tiles);
        white_tiles = missing_tiles(blue_tiles, rows, cols);
        color_part(color) tiles(blue_tiles, rows, cols, col_offset, total_columns);
        if (len(white_tiles) > 0) {
            color_part("white") tiles(white_tiles, rows, cols, col_offset, total_columns);
        }
    } else {
        // Treat unknown character as a space - a single blank column.
        color_part("white") tiles([for (row = [0: rows - 1]) row], rows, 1, col_offset, total_columns);
    }
}

module base_layer(rows, cols, trim_spacing = true) {
    height = rows * DX - TILE_SPACING;
    color_part("black")
        translate([-TILE_WIDTH/2, TILE_WIDTH/2 - height, 0])
            cube([cols * DX - (trim_spacing ? TILE_SPACING : 0), height, BASE_THICKNESS]);
}

// Letter-form data structure utilities.
function rows_of(letter_forms) = letter_forms[0];
function index_of(ch, letter_forms) = letter_forms != undef ? ord(ch) - letter_forms[1] : undef;
function is_member(ch, letter_forms) =
    let (index = index_of(ch, letter_forms))
    index != undef && index >= 0 && index < len(letter_forms[2]);
function tile_list(ch, letter_forms) = letter_forms[2][index_of(ch, letter_forms)];

// Find the indices of a character in a list of letter forms.
// Returns an array in indices - one per font.
function font_index(ch, letter_forms_list) =
    [for (i = [0:len(letter_forms_list)-1]) is_member(ch, letter_forms_list[i]) ? i : undef ];

// Returns an array of font indices, 1 per printable character in the message.
function font_indices(m, visible, letter_forms_list) =
    [for (i = [0:len(m)-1]) if (visible[i]) first_defined_index(font_index(m[i], letter_forms_list)) else undef];

function first_defined_index(a) =
    let (r = [for (i = [0 : len(a) - 1]) if (a[i] != undef) i])
    len(r) > 0 ? r[0] : undef;

module font_sampler(letter_forms=FONT_SET[0]) {
    num_symbols = len(letter_forms[2]);
    start_code = letter_forms[1];
    end_code = start_code + num_symbols - 1;

    // Favor more width - since letters are generally taller.
    cols = floor(sqrt(num_symbols) * 1.5);
    rows = ceil(num_symbols / cols);

    lines = [for (row = [0: rows - 1])
        let (start = start_code + cols * row,
             end = min(end_code, start_code + cols * (row + 1) - 1))
            [for (c = [start: end]) chr(c)]
        ];
    sign(lines, [letter_forms]);
}

// Compute the negative space of a letter matrix.
function missing_tiles(tiles, rows, cols) =
    concat(
        [for (i = [0: rows * cols - 1]) if (indexof(i, tiles) == -1) i],
        complementary_triangles(tiles));

function complementary_triangles(tiles) =
    [for (t = tiles) if (is_list(t)) [t[0], (t[1] + 4) % 8] ];

// List/vector helper functions
function flatten(l) = [ for (a = l) for (b = a) b ];
function tail(v) = len(v) > 1 ? [for (i = [1:len(v)-1]) v[i]] : [];
function cumsum(v) = [for (a=0, b=v[0]; a < len(v); a= a+1, b=b+(v[a]==undef?0:v[a])) b];
function indexof(v, l) = let (s = search(v, l)) len(s) == 0 ? -1 : s[0];
function maxvalue(v) = max(v);

// Need to be able to conditionally render parts based on color (for
// export to Bambu Studio for slicing.
module color_part(c) {
    if (COLOR_FILTER == "all" || c == COLOR_FILTER) {
        color(c) children();
    }
}

if (SHOW_FONT) {
    font_sampler();
} else {
    sign([for (t = [FIRST_LINE, SECOND_LINE, THIRD_LINE, FOURTH_LINE]) if (t != "") t]);
}

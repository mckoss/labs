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

// When printing in sections, include tabs and slots to join the pieces together.
USE_JOINERY = true;

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
TILE_DEPTH = 2;
// The "grout" thickness between tiles (mm)
TILE_SPACING = 0.5;
// Radius of chamfer (rounded corners) (mm)
CHAMFER_RADIUS = 0.5;
// Resolution of curve (number of steps from top to side)
CHAMFER_STEPS = 3;
// Thickness of flat sheet connecting all tiles (mm)
BASE_THICKNESS = 2; // [0:0.1:5]

DX = TILE_WIDTH + TILE_SPACING;

/* [Hidden] */

// Control character for color change
// Followed by "r", "g", "b", "k", or "w" for red, green, blue, black, or white.
COLOR_CHANGE = "~";

// Tiny 3x5 Fonts
//
// (c) 1980, 2025 Mike Koss
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the “Software”), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
//
// There are two fonts in the "Tiny 3x5" family.
//
// The first is a slightly modified version of the 3x5 font
// I created in 1980 for the Apple ][.  It is no longer
// monospaced as there are some 1 and 2 column symbols here
// as well.
//
// The numbers in this font are also in a blocky rather than
// rounded style.  I think that improves readability and also
// distinguishes numbers from letters more.
//
// This font uses only square pixels.
//
// The encoding for each character is:
//
//     [C, I1, I2, ..., In]
//
// where C is the number of columns of width used by the character
// and the indices are the row-major sequential indices into the character
// array (starting at zero for the upper left).
//
// Use the grid editor at https://mckoss.com/labs/models/grid-edit.html
// to modify individual letters.
TINY_3x5 = [
    5,         // Number of rows
    33,        // ASCII code of first character ('!')
    [
        [1, 0,1,2,4], //  33 '!'
        [3, 0,2,3,5], //  34 '"'
        [3, 0,2,3,4,5,6,8,9,10,11,12,14], //  35 '#'
        [3, 1,2,3,4,6,7,8,10,11,12,13], //  36 '$'
        [3, 0,2,5,7,9,12,14], //  37 '%'
        [3, 1,3,5,7,9,11,13,14], //  38 '&'
        [1, 0, 1], //  39 '''
        [2, 1,2,4,6,9], //  40 '('
        [2, 0,3,5,7,8], //  41 ')'
        [3, 3,5,7,9,11], //  42 '*'
        [3, 4,6,7,8,10], //  43 '+'
        [2, 7,8], //  44 ','
        [3, 6,7,8], //  45 '-'
        [1, 4], //  46 '.'
        [3, 2,5,7,10,12], //  47 '/'

        [3, 0,1,2,3,5,6,8,9,11,12,13,14], //  48 '0'
        [3, 1,3,4,7,10,12,13,14], //  49 '1'
        [3, 0,1,2,5,6,7,8,9,12,13,14], //  50 '2'
        [3, 0,1,2,5,6,7,8,11,12,13,14], //  51 '3'
        [3, 0,2,3,5,6,7,8,11,14], //  52 '4'
        [3, 0,1,2,3,6,7,8,11,12,13,14], //  53 '5'
        [3, 0,1,2,3,6,7,8,9,11,12,13,14], //  54 '6'
        [3, 0,1,2,5,8,11,14], //  55 '7'
        [3, 0,1,2,3,5,6,7,8,9,11,12,13,14], //  56 '8'
        [3, 0,1,2,3,5,6,7,8,11,14], //  57 '9'

        [1, 1,3], //  58 ':'
        [2, 3, 7,8], //  59 ';'
        [3, 2,4,6,10,14], //  60 '<'
        [3, 3,4,5,9,10,11], //  61 '='
        [3, 0,4,8,10,12], //  62 '>'
        [3, 1,3,5,8,10,13], //  63 '?'
        [3, 1,3,5,6,7,8,9,13,14], //  64 '@'

        [3, 1,3,5,6,7,8,9,11,12,14], //  65 'A'
        [3, 0,1,3,5,6,7,9,11,12,13], //  66 'B'
        [3, 1,3,5,6,9,11,13], //  67 'C'
        [3, 0,1,3,5,6,8,9,11,12,13], //  68 'D'
        [3, 0,1,2,3,6,7,9,12,13,14], //  69 'E'
        [3, 0,1,2,3,6,7,9,12], //  70 'F'
        [3, 1,2,3,6,8,9,11,13], //  71 'G'
        [3, 0,2,3,5,6,7,8,9,11,12,14], //  72 'H'
        [3, 0,1,2,4,7,10,12,13,14], //  73 'I'
        [3, 0,1,2,4,7,10,12,13], //  74 'J'
        [3, 0,2,3,5,6,7,9,11,12,14], //  75 'K'
        [3, 0,3,6,9,12,13,14], //  76 'L'
        [3, 0,2,3,4,5,6,7,8,9,11,12,14], //  77 'M'
        [3, 0,2,3,4,5,6,7,8,9,10,11,12,14], //  78 'N'
        [3, 1,3,5,6,8,9,11,13], //  79 'O'
        [3, 0,1,3,5,6,7,9,12], //  80 'P'
        [3, 1,3,5,6,8,10,14], //  81 'Q'
        [3, 0,1,3,5,6,7,9,11,12,14], //  82 'R'
        [3, 1,2,3,7,11,12,13], //  83 'S'
        [3, 0,1,2,4,7,10,13], //  84 'T'
        [3, 0,2,3,5,6,8,9,11,12,13,14], //  85 'U'
        [3, 0,2,3,5,6,8,10,13], //  86 'V'
        [3, 0,2,3,5,6,7,8,9,10,11,12,14], //  87 'W'
        [3, 0,2,3,5,7,9,11,12,14], //  88 'X'
        [3, 0,2,3,5,7,10,13], //  89 'Y'
        [3, 0,1,2,5,7,9,12,13,14], //  90 'Z'

        [2, 0,1,2,4,6,8,9], //  91 '['
        [3, 0,3,7,10,14], //  92 '\\'
        [2, 0,1,3,5,7,8,9], //  93 ']'
        [3, 1,3,5], //  94 '^'
        [3, 12,13,14], //  95 '_'
        [2, 0,3], //  96 '`'

        [3, 4,6,8,9,11,13,14], //  97 'a'
        [3, 0,3,4,6,8,9,11,12,13], //  98 'b'
        [3, 4,5,6,9,13,14], //  99 'c'
        [3, 2,4,5,6,8,9,11,13,14], // 100 'd'
        [3, 4,6,8,9,10,13,14], // 101 'e'
        [3, 1,2,4,6,7,8,10,13], // 102 'f'
        [3, 4,6,8,10,11,12,13], // 103 'g'
        [3, 0,3,4,6,8,9,11,12,14], // 104 'h'
        [1, 0,2,3,4], // 105 'i'
        [2, 1,5,7,8], // 106 'j'
        [3, 0,3,6,8,9,10,12,14], // 107 'k'
        [1, 0,1,2,3,4], // 108 'l'
        [3, 3,4,5,6,7,8,9,11,12,14], // 109 'm'
        [3, 4,6,8,9,11,12,14], // 110 'n'
        [3, 4,6,8,9,11,13], // 111 'o'
        [3, 3,4,6,8,9,10,12], // 112 'p'
        [3, 4,5,6,8,10,11,14], // 113 'q'
        [2, 2,4,5,6,8], // 114 'r'
        [2, 3,4,7,8], // 115 's'
        [3, 1,3,4,5,7,10,13], // 116 't'
        [3, 3,5,6,8,9,11,12,13,14], // 117 'u'
        [3, 3,5,6,8,9,11,13], // 118 'v'
        [3, 3,5,6,8,9,10,11,12,13,14], // 119 'w'
        [3, 3,5,7,10,12,14], // 120 'x'
        [3, 3,5,6,8,10,11,12,13], // 121 'y'
        [3, 3,4,5,7,8,9,10,12,13,14], // 122 'z'

        [3, 1,2,4,6,7,10,13,14], // 123 '{'
        [1, 0,1,3,4], // 124 '|'
        [3, 0,1,4,7,8,10,12,13], // 125 '}'
        [3, 2,3,4,5,6] // 126 '~'
    ]
];

// Tiny 3x5 Bias
//
// This font expands on the previous one to increase legibility.
// It incorporates triagular half-pixels in some letters, as well
// as allowing for 4 column characters where needed (like, M and W).
//
// Thanks you to Redditor u/Stone_Age_Sculptor for suggesting improvements
// to "1" and "f". (Jan 2025)
TINY_3x5_BIAS = [
    5,         // Number of rows
    33,        // ASCII code of first character ('!')
    [
        [1, 0,1,2,4], //  33 '!'
        [3,0,2,[3,7],[5,7]], //  34 '"'
        [3,[0,3],[2,3],3,4,5,6,8,9,10,11,[12,7],[14,7]], //  35 '#'
        [3,1,[2,5],[3,3],4,[6,1],7,[8,5],10,[11,7],[12,1],13], //  36 '$'
        [3,0,2,[4,3],5,[6,3],7,[8,7],9,[10,7],12,14], //  37 '%'
        [3,[0,3],1,[2,5],3,5,[6,1],7,[8,7],9,11,[12,1],13,14], //  38 '&'
        [1, 0, 1], //  39 '''
        [2, [0,3],[1,7],2,4,6,[8,1],[9,5]], //  40 '('
        [2, [0,1],[1,5],3,5,7,[8,3],[9,7]], //  41 ')'
        [3,[3,1],[4,5],[5,3],[6,3],7,[8,7],[9,7],[10,1],[11,5]], //  42 '*'
        [3, 4,6,7,8,10], //  43 '+'
        [2,7,[8,3],[9,7]], //  44 ','
        [3, 6,7,8], //  45 '-'
        [1, 4], //  46 '.'
        [3,[2,3],[4,3],5,[6,3],7,[8,7],9,[10,7],[12,7]], //  47 '/'

        [3,[0,3],1,[2,5],3,[4,3],5,6,7,8,9,[10,7],11,[12,1],13,[14,7]], //  48 '0'
        [2,[0,3],1,3,5,7,9], //  49 '1'
        [3,[0,3],1,[2,5],3,5,[7,3],[8,7],[9,3],[10,7],12,13,14], //  50 '2'
        [3,[0,3],1,[2,5],5,7,8,11,[12,1],13,[14,7]], //  51 '3'
        [3, 0,2,3,5,6,7,8,11,14], //  52 '4'
        [3,0,1,2,3,6,7,[8,5],11,12,13,[14,7]], //  53 '5'
        [3,[0,3],1,[2,7],3,6,7,[8,5],9,11,[12,1],13,[14,7]], //  54 '6'
        [3, 0,1,2,5,8,11,14], //  55 '7'
        [3,[0,3],1,[2,5],3,5,6,7,8,9,11,[12,1],13,[14,7]], //  56 '8'
        [3,[0,3],1,[2,5],3,5,[6,1],7,8,11,14], //  57 '9'

        [1, 1,3], //  58 ':'
        [2,3,7,[8,3],[9,7]], //  59 ';'
        [3,[4,3],[5,7],[6,3],[7,7],[9,1],[10,5],[13,1],[14,5]], //  60 '<'
        [3, 3,4,5,9,10,11], //  61 '='
        [3,[3,1],[4,5],[7,1],[8,5],[10,3],[11,7],[12,3],[13,7]], //  62 '>'
        [3,[0,3],1,[2,5],[3,1],5,[7,3],[8,7],[10,7],13], //  63 '?'
        [3, [0,3],1,[2,5],3,5,6,[7,1],[8,7],9,[11,3],[12,1],13,[14,7]], //  64 '@'

        [3, [0,3],1,[2,5],3,5,6,7,8,9,11,12,14], //  65 'A'
        [3, 0,1,[2,5],3,5,6,7,[8,5],9,11,12,13,[14,7]], //  66 'B'
        [3, [0,3],1,[2,5],3,6,9,[12,1],13,[14,7]], //  67 'C'
        [3, 0,1,[2,5],3,5,6,8,9,11,12,13,[14,7]], //  68 'D'
        [3, 0,1,2,3,6,7,9,12,13,14], //  69 'E'
        [3, 0,1,2,3,6,7,9,12], //  70 'F'
        [3, [0,3],1,[2,5],3,6,[7,3],8,9,11,[12,1],13,[14,7]], //  71 'G'
        [3, 0,2,3,5,6,7,8,9,11,12,14], //  72 'H'
        [3, 0,1,2,4,7,10,12,13,14], //  73 'I'
        [3, 0,1,2,4,7,10,12,13], //  74 'J'
        [3, 0,[2,3],3,[4,3],[5,7],6,7,9,[10,1],[11,5],12,[14,1]], //  75 'K'
        [3, 0,3,6,9,12,13,14], //  76 'L'
        [4, 0,[1,5],[2,3],3,4,5,6,7,8,[9,1],[10,7],11,12,15,16,19], //  77 'M'
        [3, 0,2,3,[4,5],5,6,7,8,9,[10,1],11,12,14], //  78 'N'
        [3, [0,3],1,[2,5],3,5,6,8,9,11,[12,1],13,[14,7]], //  79 'O'
        [3, 0,1,[2,5],3,5,6,7,[8,7],9,12], //  80 'P'
        [3,[0,3],1,[2,5],3,5,6,8,9,[10,1],11,[12,1],13,[14,1]], //  81 'Q'
        [3, 0,1,[2,5],3,5,6,7,[8,7],9,[10,1],[11,5],12,[14,1]], //  82 'R'
        [3, [0,3],1,[2,5],3,[6,1],7,[8,5],11,[12,1],13,[14,7]], //  83 'S'
        [3, 0,1,2,4,7,10,13], //  84 'T'
        [3, 0,2,3,5,6,8,9,11,[12,1],13,[14,7]], //  85 'U'
        [3, 0,2,3,5,6,8,9,[10,3],[11,7],12,[13,7]], //  86 'V'
        [4,0,3,4,7,8,[9,3],[10,5],11,12,13,14,15,16,[17,7],[18,1],19], //  87 'W'
        [3,[0,5],[2,3],[3,1],4,[5,7],7,[9,3],10,[11,5],[12,7],[14,1]], //  88 'X'
        [3,0,2,3,5,[6,1],7,[8,7],10,13], //  89 'Y'
        [3,0,1,2,[4,3],[5,7],[6,3],[7,7],9,12,13,14], //  90 'Z'

        [2, 0,1,2,4,6,8,9], //  91 '['
        [3,[0,5],3,[4,5],[6,1],7,[8,5],[10,1],11,[14,1]], //  92 '\'
        [2, 0,1,3,5,7,8,9], //  93 ']'
        [2,[0,3],[1,5],[2,7],[3,1]], //  94 '^'
        [3, 12,13,14], //  95 '_'
        [2,[0,1],[1,5]], //  96 '`'

        [3,[6,3],7,[8,5],9,11,[12,1],13,[14,1]], //  97 'a'
        [3,[0,5],3,6,7,[8,5],9,11,[12,1],13,[14,7]], //  98 'b'
        [3,[6,3],7,[8,5],9,[12,1],13,[14,7]], //  99 'c'
        [3,[2,3],5,[6,3],7,8,9,11,[12,1],13,[14,7]], // 100 'd'
        [3,[6,3],7,[8,5],9,[10,3],[11,7],[12,1],13,[14,7]], // 101 'e'
        [3,[1,3],2,4,6,7,8,10,13], // 102 'f'
        [3,[3,3],4,[5,5],6,8,[9,1],10,11,12,13,[14,7]], // 103 'g'
        [3,[0,5],3,6,7,[8,5],9,11,12,14], // 104 'h'
        [1,[1,7],[2,3],3,4], // 105 'i'
        [2,[3,7],[5,3],7,8,[9,7]], // 106 'j'
        [3,[0,5],3,6,[7,3],[8,7],9,10,12,[13,1],[14,5]], // 107 'k'
        [1,[0,5],1,2,3,4], // 108 'l'
        [4,8,[9,5],[10,3],[11,5],12,[13,1],[14,7],15,16,19], // 109 'm'
        [3,6,7,[8,5],9,11,12,14], // 110 'n'
        [3,[6,3],7,[8,5],9,11,[12,1],13,[14,7]], // 111 'o'
        [3,[3,3],4,[5,5],6,8,9,10,[11,7],12], // 112 'p'
        [3,[3,3],4,[5,5],6,8,[9,1],10,11,14], // 113 'q'
        [2,4,[5,5],6,8], // 114 'r'
        [2,[4,3],[5,5],[6,1],[7,5],[8,1],[9,7]], // 115 's'
        [3,[1,5],4,[6,3],7,[8,7],10,13], // 116 't'
        [3,6,8,9,11,[12,1],13,[14,7]], // 117 'u'
        [3,6,8,9,[10,3],[11,7],12,[13,7]], // 118 'v'
        [4,8,11,12,[13,3],[14,5],15,16,[17,7],[18,1],19], // 119 'w'
        [3,6,[7,3],8,10,12,[13,7],14], // 120 'x'
        [3,6,8,[9,1],10,[11,7],[12,3],[13,7]], // 121 'y'
        [2,4,5,[6,3],[7,7],8,9], // 122 'z'

        [3,[1,3],2,4,6,7,10,[13,1],14], // 123 '{'
        [1, 0,1,3,4], // 124 '|'
        [3,0,[1,5],4,7,8,10,12,[13,7]], // 125 '}'
        [3,[2,5],[3,3],4,[5,7],[6,1]] // 126 '~'
    ]
];

// Unicode suit characters (spades, hearts, diamonds, clubs) "♠♡♢♣"
// The heart is really the only good one here.
// And they are all filled in, rather than outlined as in most unicode fonts.
TINY_3x5_SUITS = [
    5,         // Number of rows
    9824,      // Unicode code of first character (♠)
    [
        [4,[1,3],[2,5],[4,3],5,6,[7,5],8,9,10,11,[12,1],13,14,[15,7],[17,3],[18,5]],            // 9824 '♠'
        [4,[4,3],[5,5],[6,3],[7,5],[8,1],9,10,[11,7],[13,1],[14,7]], // 9825 '♡'
        [4,[5,3],[6,5],[8,3],9,10,[11,5],[12,1],13,14,[15,7],[17,1],[18,7]],                          // 9826 '♢'
        [4,[5,3],[6,5],[8,3],[9,3],[10,5],[11,5],[12,1],[13,1],[14,7],[15,7],[17,3],[18,5]], // 9827 '♣'
    ]
];

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
    join_left_edge = extent[0] != -border;
    join_right_edge = extent[1] != max_width + border - 1;
    translate([DX * (FIRST_COLUMN - border), DX * border, 0])
        base_layer(text_rows + 2 * border, extent[1] - extent[0] + 1, join_left_edge, join_right_edge);

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

// Print the base layer under the tiles.  If the sign is printed in sections
// then the left and right edges of the base layer will need to be
// augmented with tabs and slots to allow them to be joined together.
module base_layer(rows, cols, join_left_edge, join_right_edge) {
    tab_thickness = BASE_THICKNESS * 0.5;
    width = cols * DX - (join_right_edge ? 0 : TILE_SPACING);
    height = rows * DX - TILE_SPACING;
    color_part("black")
        translate([-TILE_WIDTH/2, TILE_WIDTH/2 - height, 0]) {
            if (USE_JOINERY && join_right_edge) {
                sub_slots_right(height, width, tab_thickness)
                    cube([width, height, BASE_THICKNESS]);
            } else {
                cube([width, height, BASE_THICKNESS]);
            }
            if (USE_JOINERY && join_left_edge)
                add_tabs_left(height, tab_thickness);
        }
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

//
// Dovetail joint modules
//
SLOT_EXTRA_HEIGHT = 0.2;
MIN_TAIL = 10;
E = 0.1;

// Tail oriented to the left centered at the base
module wedge(tail, base, depth, height) {
  linear_extrude(height)
    polygon([[0, base/2], [-depth, tail/2],
             [-depth, -tail/2], [0, -base/2]]);
}

// Equally spaced tabs fill an edge of length
// edge (vertical from [0, 0, 0]) s.t. E = N(T+B)
// where T is the max width of a tab and B
// is the base (or min width) of the tab.
// Use B = T / 2, so E = N * T * 3/2
// And, T = E / N * 2/3
// We also choose depth of tab equal to T.
module tabs(count, edge, height) {
  tail = edge / count * 2/3;
  base = tail / 2;
  spacing = tail + base;
  for (i=[0:count-1]) {
    translate([0, i * spacing + tail/2 + base/2, 0])
      wedge(tail, base, tail, height);
  }
}

// Choose a number of tabs to fill the edge equally,
// with a max tab width is at least min_tail.
// N = floor(E/((T+B))
module auto_tabs(min_tail, edge, height) {
  count = floor(edge / (min_tail * 3/2));
  tabs(count, edge, height);
}

module add_tabs_left(edge, height) {
  translate([E, 0, 0])
    auto_tabs(MIN_TAIL, edge, height);
}

// Subtracts tabs from the right edge of a child
// of the given width.
module sub_slots_right(edge, width, height) {
  translate([width, 0, 0])
  difference() {
    translate([-width, 0, 0])
        children();
    translate([E, 0, -E])
      auto_tabs(MIN_TAIL, edge, height + E + SLOT_EXTRA_HEIGHT);
  }
}

//
// Two possible outputs - a sign or a font sampler
//

if (SHOW_FONT) {
    font_sampler();
} else {
    sign([for (t = [FIRST_LINE, SECOND_LINE, THIRD_LINE, FOURTH_LINE]) if (t != "") t]);
}

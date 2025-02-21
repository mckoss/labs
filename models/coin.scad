// Challenge coin generator.
// All dimensions in millimeters.
// (c) 2013 - 2025 Mike Koss
// License: MIT (free to use with attribution)

// preview[view:south, tilt:top diagonal]

/* [Text] */
TOP_TEXT = "In Coin We Trust";
BOTTOM_TEXT = "2025";
REVERSE_TOP = "Heads I Win";
REVERSE_BOTTOM = "Tails You Lose";

/* [Coin Size and Parts] */

// (mm)
DIAMETER = 51;

// (mm)
THICKNESS = 3.2;

// Which colors to print.
COLOR_FILTER = "all"; // ["all", "black", "gold"]

/* [Text Properties] */

// Letter height (mm)
TEXT_HEIGHT = 5.0;
// ratio (1.0 is nominal)
SPACING = 1.0; // [0.4:0.1:1.6]
// Print height (mm)
RELIEF = 0.7;
// Font
FONT = "Liberation Sans:style=Bold";

/* [Image] */

// Image file - typically using Inkscape DXF or SVG
OBVERSE_IMAGE = "globe.svg";
IMAGE_CENTER = [55, 55];
IMAGE_SCALE = 0.2;

/* [Hidden] */

// Epsilon
E = 0.01;

// Typical value for layer_height
layer_height = 0.2;

module coin(
    top_text="",             // Text of centered top text
    bottom_text="",          // Text of centered bottom text
    rev_top_text="",         // Reverse top text
    rev_bottom_text="",      // Reverse bottom text
    size=DIAMETER,           // Diameter of coin
    thickness=THICKNESS,     // Total coin thickness
    relief=RELIEF,           // Height of raised (relief) features
    text_height=TEXT_HEIGHT, // Height of a text letter
    spacing=SPACING,         // 1.0 == nominal spacing (ratio)
    rim_width=0.5,            // Rim edge thickness
    image_file=""
    ) {
  // Coin cylinder will be (from bottom up):
  // Gold (relief height - layer_height)
  // Black (background_height)
  // Gold (background_height)
  // So 2 * background_height + relief - layer_height == thickness - relief
  // therefore:
  background_height = (thickness - 2 * relief + layer_height) / 2;

  difference() {
    union() {
      color_part("gold")
        cylinder(r=size / 2, h=relief - layer_height, $fn=180);
      color_part("black")
        translate([0, 0, relief - layer_height])
          cylinder(r=size / 2, h=background_height, $fn=180);
      color_part("gold")
        translate([0, 0, relief - layer_height + background_height])
          cylinder(r=size / 2, h=background_height, $fn=180);
      color_part("black")
        translate([0, 0, thickness - relief - E])
          face(top_text, bottom_text, size, relief + E, text_height, spacing, rim_width,
               image_file=image_file);
    }
    translate([0, 0, relief - E])
      rotate(a=180, v=[1, 0, 0])
        face(rev_top_text, rev_bottom_text, size, relief + 2 * E, text_height, spacing,
             rim_width, rim=false);
  }
}

module face(
    top_text="",      // Text of centered top text
    bottom_text="",   // Text of centered bottom text
    size=39,          // Diameter of coin
    relief=0.5,       // Height of raised (relief) features
    text_height=5.0,  // Height of a text letter
    spacing=1.0,      // 1.0 == nominal spacing (ratio)
    rim_width=0.5,    // Rim edge thickness
    rim=true,         // Boolean control drawing rim ridge
    image_file=""     // Optional face image (DXF file)
    ) {
  if (rim) {
    ring(r=size / 2, thickness=rim_width, height=relief);
  }
  linear_extrude(height=relief)
    arc_text(top_text, size / 2 - rim_width * 4, text_height, spacing, true);
  linear_extrude(height=relief)
    arc_text(bottom_text, size / 2 - rim_width * 4, text_height, spacing, false);
  if (image_file != "") {
    linear_extrude(height=relief, convexity=10)
      scale(IMAGE_SCALE)
        translate([-IMAGE_CENTER[0], -IMAGE_CENTER[1], 10])
          import(file=image_file);
  }
}

module arc_text(
    text,
    r,   // Outside radius of text
    text_height=3.0,
    spacing=1.0,
    top=true
    ) {
  base_radius = r - text_height;
  total_width = text_width(text, text_height);
  // relative pos from -1/2 to 1/2 of width
  start_pos = -total_width/2;
  x_pos = character_pos(text, text_height);
  if (len(text) > 0) {
    for (i = [0 : len(text) - 1]) {
      // Relative pos of center of letter
      pos = start_pos + x_pos[i] + char_width(text[i], text_height)/2;
      angle = (top ? -1 : 1 ) * pos / base_radius / PI * 180;
      rotate(angle)
        // Account for descender height about 20% of font height
        translate([0, top ? base_radius : -base_radius - text_height * 4 / 5, 0]) {
          text(text[i], size=text_height, halign="center", font=FONT);
        }
    }
  }
}

// Ring around origin (at z=0)
module ring(r, thickness, height) {
  translate([0, 0, height / 2]) {
    difference() {
      cylinder(h=height, r=r, $fa=3, center=true);
      cylinder(h=height + 2 * E, r=r - thickness, $fa=3, center=true);
    }
  }
}

// Estimator of text measurement (until textmetrics is available in OpenSCAD)
// Based on the ratio of character width to ascent for Arial font on Windows.

ascii_ratios = [ 0.37, 0.37, 0.47, 0.74, 0.74, 1.19, 0.89, 0.25, 0.44, 0.44, 0.52, 0.78, 0.37,
  0.44, 0.37, 0.37, 0.74, 0.74, 0.74, 0.74, 0.74, 0.74, 0.74, 0.74, 0.74, 0.74,
  0.37, 0.37, 0.78, 0.78, 0.78, 0.74, 1.35, 0.89, 0.89, 0.96, 0.96, 0.89, 0.81,
  1.04, 0.96, 0.37, 0.67, 0.89, 0.74, 1.11, 0.96, 1.04, 0.89, 1.04, 0.96, 0.89,
  0.81, 0.96, 0.89, 1.26, 0.89, 0.89, 0.81, 0.37, 0.37, 0.37, 0.63, 0.74, 0.44,
  0.74, 0.74, 0.67, 0.74, 0.74, 0.37, 0.74, 0.74, 0.3, 0.3, 0.67, 0.3, 1.11,
  0.74, 0.74, 0.74, 0.74, 0.44, 0.67, 0.37, 0.74, 0.67, 0.96, 0.67, 0.67, 0.67,
  0.45, 0.35, 0.45, 0.78 ];

function char_ratio(ch) = ord(ch) < 32 || ord(ch) > 126 ? 0.74 : ascii_ratios[ord(ch) - 32];
function char_width(ch, size) = size * char_ratio(ch);
function character_pos(str, size) = [0, each cumsum([for (ch=str) char_width(ch, size)])];
function text_width(str, size) = len(str) == 0 ? 0 : character_pos(str, size)[len(str)];
function cumsum(v) = [for (i=0, b=v[0]; i < len(v); i=i+1, b=(i<len(v)?b+v[i]:b)) b];

// Need to be able to conditionally render parts based on color (for
// export to Bambu Studio for slicing.
module color_part(c) {
    if (COLOR_FILTER == "all" || c == COLOR_FILTER) {
        color(c) children();
    }
}

coin(top_text=TOP_TEXT,
     bottom_text=BOTTOM_TEXT,
     rev_top_text=REVERSE_TOP,
     rev_bottom_text=REVERSE_BOTTOM,
     image_file=OBVERSE_IMAGE
     );

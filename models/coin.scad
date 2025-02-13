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

/* [Coin Size] */

// (mm)
DIAMETER = 39;
// (mm)
THICKNESS = 3.2;

/* [Text Properties] */

// Letter height (mm)
TEXT_HEIGHT = 4.0;
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
  difference() {
    union() {
      cylinder(r=size / 2, h=thickness - relief, $fa=3);
      translate([0, 0, thickness - relief - E])
        face(top_text, bottom_text, size, relief + E, text_height, spacing, rim_width, image_file=image_file);
      }
    translate([0, 0, relief])
      rotate(a=180, v=[1, 0, 0])
      face(rev_top_text, rev_bottom_text, size, relief + E, text_height, spacing, rim_width,
           rim=false);
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
  ang = spacing * atan2(text_height, r);
  start_ang = (len(text) - 1) / 2 * ang;
  ang_sgn = top ? -1 : 1;
  // Account for descender height about 20% of font height
  base_radius = top ? r - text_height : -r + text_height / 5;
  if (len(text) > 0) {
    for (i = [0 : len(text) - 1]) {
      rotate(a=ang_sgn * (ang * i - start_ang), v=[0, 0, 1])
        translate([0, base_radius, 0]) {
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

coin(top_text=TOP_TEXT,
     bottom_text=BOTTOM_TEXT,
     rev_top_text=REVERSE_TOP,
     rev_bottom_text=REVERSE_BOTTOM,
     image_file=OBVERSE_IMAGE
     );

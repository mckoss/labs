// Challenge coin generator.
// All dimensions in millimeters.

use <write.scad>

// Epsilon
E = 0.01;


module coin(
    top_text="",        // Text of centered top text
    bottom_text="",     // Text of centered bottom text
    rev_top_text="",    // Reverse top text
    rev_bottom_text="", // Reverse bottom text
    size=39,            // Diameter of coin
    thickness=3.2,      // Total coin thickness
    relief=0.5,         // Height of raised (relief) features
    text_height=5.0,    // Height of a text letter
    spacing=1.0,        // 1.0 == nominal spacing (ratio)
    rim_width=0.5       // Rim edge thickness
    ) {
  translate([0, 0, relief])
    cylinder(r=size / 2, h=thickness - 2 * relief, $fa=1);
  translate([0, 0, thickness - relief])
    face(top_text, bottom_text, size, relief, text_height, spacing, rim_width);
  translate([0, 0, relief])
    rotate(a=180, v=[1, 0, 0])
    face(rev_top_text, rev_bottom_text, size, relief, text_height, spacing, rim_width);
}

module face(
    top_text="",      // Text of centered top text
    bottom_text="",   // Text of centered bottom text
    size=39,          // Diameter of coin
    relief=0.5,       // Height of raised (relief) features
    text_height=5.0,  // Height of a text letter
    spacing=1.0,      // 1.0 == nominal spacing (ratio)
    rim_width=0.5,    // Rim edge thickness
    image_file=""     // Optional face image (DXF file)
    ) {
  ring(r=size / 2, thickness=rim_width, height=relief);
  arc_text(top_text, size / 2 - rim_width * 3, text_height, relief, spacing, true);
  arc_text(bottom_text, size / 2 - rim_width * 3, text_height, relief, spacing, false);
  if (image_file != "") {
    linear_extrude(height=relief, center=true, convexity=10)
      import_dxf(file=image_file, layer="none");
  }
}

module arc_text(
    text,
    r,
    text_height=3.0,
    height=1.0,
    spacing=1.0,
    top=true
    ) {
  ang = spacing * atan2(text_height, r);
  start_ang = (len(text) - 1) / 2 * ang;
  ang_sgn = top ? -1 : 1;
  offset_sgn = top ? 1 : -1;
  for (i = [0 : len(text) - 1]) {
    rotate(a=ang_sgn * (ang * i - start_ang), v=[0, 0, 1])
      translate([0, offset_sgn * (r - text_height / 2), height / 2])
        write(text[i], h=text_height, t=height, center=true, font="Letters.dxf");
  }
}

// Ring around origin (at z=0)
module ring(r, thickness, height) {
  translate([0, 0, height / 2]) {
    difference() {
      cylinder(h=height, r=r, $fa=1, $fs=1, center=true);
      cylinder(h=height + E, r=r - thickness, $fa=1, $fs=1, center=true);
    }
  }
}

coin(top_text="HELLO", bottom_text="World",
     rev_top_text="Oh yeah", rev_bottom_text="I went there");

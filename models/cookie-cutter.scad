// Cookie Cutter renders a DXF file as a cookie cutter.
// by Mike Koss (c) 2013
// FILE should be  contained to a 100x100 mm area.

SCALE = 1.0;

E = 0.1;
FILE = "club.dxf";

// Cookie cutter cutting depth.
DEPTH = 15;
MIN_WALL = 0.5;
MAX_WALL = 2.0;

module cookie_cutter() {
  outline(DEPTH, MAX_WALL, MIN_WALL) child(0);
  intersection() {
    linear_extrude(height=2)
      child(0);
    grid(100 * SCALE, 100 * SCALE, 10, 2);
  }
}

module outline(height, base, top) {
  difference() {
    minkowski() {
      linear_extrude(height=E)
        child(0);
      cylinder(r1=base, r2=top, h=height - E, $fn=6);
    }
    translate([0, 0, -E])
      linear_extrude(height=height + 2 * E)
        child(0);
  }
}

// Create a rectilinear grid to add stiffness and
// ensure any holes within the image are connected to the part.
module grid(x, y, d, thickness) {
  cx = floor(x / d);
  cy = floor(y / d);
  for (ix = [0: cx]) {
    translate([(ix - cx / 2) * d, 0, thickness / 2])
      cube([thickness, y + thickness, thickness], center=true);
  }
  for (iy = [0: cy]) {
    translate([0, (iy - cy / 2) * d, thickness / 2])
      cube([x + thickness, thickness, thickness], center=true);
  }
}

// Why is the file scaled by 80% from the 100mm svg original?
cookie_cutter()
  scale([-SCALE, SCALE, 1]) translate([-50, -50, 0]) scale(1.25) import(file=FILE);

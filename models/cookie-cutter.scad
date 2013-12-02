// Cookie Cutter renders a DXF file as a cookie cutter.
// by Mike Koss (c) 2013

E = 0.1;
FILE = "test.dxf";

module cookie_cutter() {
  outline(15, 2, 0.75) child(0);
  //outline(2, 6, 2) child(0);
  intersection() {
    linear_extrude(height=2)
      child(0);
    grid(400, 400, 10, 2);
  }
}

module outline(height, base, top) {
  difference() {
    minkowski() {
      linear_extrude(height=E)
        child(0);
      cylinder(r1=base, r2=top, h=height - E);
    }
    translate([0, 0, -E])
      linear_extrude(height=height + 2 * E)
        child(0);
  }
}

module grid(x, y, d, thickness) {
  cx = floor(x / d);
  cy = floor(y / d);
  translate([-x / 2, -y / 2, 0]) {
    for (ix = [0: cx]) {
      translate([ix * d, 0, 0])
        cube([thickness, y + thickness, thickness]);
    }
    for (iy = [0: cy]) {
      translate([0, iy * d, 0])
        cube([x + thickness, thickness, thickness]);
    }
  }
}

cookie_cutter() import(file=FILE);

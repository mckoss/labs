linear_extrude(15)
  import("ribeiro-outer.dxf");

translate([54, 2, 0])
  linear_extrude(11) scale([-1, 1, 1])
    import("ribeiro-emboss.dxf");

intersection() {
  linear_extrude(height=2)
    import("ribeiro-base.dxf");
  translate([50, 50, 0])
    grid(100, 100, 3, 1);
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

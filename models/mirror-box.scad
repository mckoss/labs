INCH = 25.4;
E = 0.01;

FRAME_INNER = INCH + 1;
BORDER = 2;
FRAME_OUTER = FRAME_INNER + 2 * BORDER;

module holder() {
  difference() {
    sphere(r=FRAME_OUTER / 2, $fa=3, $fs=1);
    cylinder(r=FRAME_INNER / 2, h=2, $fa=3, $fs=1);

    translate([0, 0, -FRAME_OUTER / 2])
      cube(FRAME_OUTER + E, center=true);
  }
}

rotate(a=45, v=[0, 1, 0])
  holder();
translate([0, 0, -sqrt(2) / 4 * FRAME_OUTER])
  difference() {
    cylinder(r=FRAME_OUTER / 2, BORDER * sqrt(2) / 2, $fa=3, $fs=1);
    translate([0, 0, -E])
      cylinder(r=FRAME_INNER / 2, h=sqrt(2) / 4 * FRAME_OUTER + 2 * E, $fa=3, $fs=1);
  }

use <cookie-cutter.scad>;

SCALE = 1.0;

chamfer(11, edge=1.2)
  scale(0.9)
    scale([-1, 1, 1])
      translate([-29, -32.5, 0]) import("ribeiro-symbol.dxf");

cookie_cutter()
  circle(r=35, $fa=10);

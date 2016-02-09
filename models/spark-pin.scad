$fn = 4;
$fs = 0.5;
E = 0.01;

INCH = 25.4;
GAP = 0.5;
BACK_R = INCH / 8 + GAP;
BACK_H = INCH / 16 + GAP;

module round_it() {
  minkowski() {
    cylinder(r1=3, r2=0, h=3.5);
    child(0);
  }
}

difference() {
  round_it() {
    linear_extrude(0.1)
      import("mof-spark.dxf");
  }
  # translate([19, 20, BACK_H / 2 - E])
    cylinder(r=BACK_R, h=BACK_H, center=true, $fn=16);
}

echo("Back diameter", BACK_R * 2);

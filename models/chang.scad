FAST = true;
E = 0.1;
$fa = 5;

module pendant() {
  cylinder(r=50, h=2);
  translate([0, 0, 2])
    chamfer(2)
      translate([-36, -40, 0]) child(0);
  ring(50, 2, 4);
  translate([0, 50, 0])
    difference() {
      ring(10, 2, 4);
      translate([0, -12, 0])
        cube(20, center=true);
    }
}

module chamfer(height, edge=1) {
  if (!FAST) {
    minkowski() {
      linear_extrude(height=height - edge)
        child(0);
      cylinder(r1=edge, r2=0.1, h=edge, $fn=6);
    }
  } else {
    linear_extrude(height=height)
      child(0);
  }
}

// Ring around origin (at z=0)
module ring(r, thickness, height) {
  translate([0, 0, height / 2]) {
    difference() {
      cylinder(h=height, r=r, center=true);
      cylinder(h=height + 2 * E, r=r - thickness, center=true);
    }
  }
}

scale([0.5, 0.5, 3/4])
  pendant() import("chang.dxf");
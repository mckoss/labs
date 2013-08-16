
module ocarina() {
  difference() {
    import("treefrog.stl");
    # translate([0, -15, 15.2])
      rotate(a=55, v=[1, 0, 0])
        cylinder(r=1.5, h=10, $fs=1);
    for (y = [-7, 0, 7]) {
    # translate([0, y, 6])
        rotate(a=-35, v=[1, 0, 0])
          cylinder(r=2, h=15, $fs=1);
    }
  }
}

module body_interior() {
  translate([0, 0, 3])
    scale(0.7)
      body_only();
}

module body_only() {
  difference() {
    import("treefrog.stl");
    translate([14, 0, 0])
      rotate(a=45, v=[0, 1, 0])
        cube([20, 50, 20], center=true);
    translate([-14, 0, 0])
      rotate(a=45, v=[0, 1, 0])
        cube([20, 50, 20], center=true);
  }
}

ocarina();
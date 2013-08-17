module ocarina() {
  difference() {
   import("treefrog2.stl");
    # translate([0, 0, 8.5])
      rotate(a=-20, v=[1, 0, 0])
        pipes();
  }
}

module pipes() {
  union() {
/*
    scale([0.4, 0.7, 0.30])
       sphere(r=15, $fa=30);
*/
    for (y = [-10 , -3 , 4 /*, 11*/]) {
      translate([0, y, 0])
        cylinder(r=2, h=13, $fs=1);
    }
    rotate(a=83, v=[1, 0, 0])
      cylinder(r=1.5, h=30, $fs=1);
  }
}

ocarina();

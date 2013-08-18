use <spiff.scad>;

intersection() {
  scale([1, 1, 1])
    linear_extrude(10)
      write("M");

  translate([0, 10, 0])
    rotate(a=90, v=[1, 0, 0])
      scale([1.7, 1, 1])
        linear_extrude(10)
          write("C");

  translate([0, 0, 10])
    rotate(a=90, v=[0, 1, 0])
      scale([1.7, 1, 1])
        linear_extrude(10)
          write("K");

}

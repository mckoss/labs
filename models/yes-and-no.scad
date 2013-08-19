use <spiff.scad>;

intersection() {
  rotate(a=90, v=[1, 0, 0])
    linear_extrude(22)
      write("YES");

  translate([0, -22, 0])
      rotate(a=90, v=[0, 0, 1])
        rotate(a=90, v=[1, 0, 0])
          scale([1.7, 1, 1])
            linear_extrude(19)
              write("NO");
}

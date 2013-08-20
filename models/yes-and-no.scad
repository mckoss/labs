use <spiff.scad>;

PART = "all"; // [y, e, s, all]

module y() {
  translate([0, -12, 0])
  intersection() {
    rotate(a=90, v=[1, 0, 0])
      linear_extrude(10)
        write("Y");

    translate([0, -10, 0])
        rotate(a=90, v=[0, 0, 1])
          rotate(a=90, v=[1, 0, 0])
            scale([1.7, 1, 1])
              linear_extrude(6)
                write("N");
  }
}

module es() {
intersection() {
  translate([8, 0, 0])
    rotate(a=90, v=[1, 0, 0])
      linear_extrude(10)
        write("ES");

  translate([8, -10, 0])
    rotate(a=90, v=[0, 0, 1])
      rotate(a=90, v=[1, 0, 0])
        scale([1.7, 1, 1])
          linear_extrude(12)
            write("O");
}
}

if (PART == "y") {
   translate([0, 0, 10])
   rotate(a=180, v=[0, 1, 0])
     y();
}

if (PART == "e") {
  translate([0, 0, -8])
  rotate(a=-90, v=[0, 1, 0])
  intersection() {
    # translate([8, -10, 0])
      cube([5, 10, 10]);
    es();
  }
}

if (PART == "s") {
//  translate([0, 0, -8])
//  rotate(a=-90, v=[0, 1, 0])
  intersection() {
    # translate([14, -10, 0])
      cube([6, 10, 10]);
    es();
  }
}

if (PART == "all") {
  y();
  es();
}

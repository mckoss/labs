$fa = 3;
E = 0.01;

HEAD_SIZE = 130;
THICKNESS = 3;

module head_band() {
  difference() {
    scale([1.05, 1, 1])
      sphere(r=HEAD_SIZE / 2 + THICKNESS);
    translate([0, 0, -HEAD_SIZE])
      cube(HEAD_SIZE * 2, center=true);
    translate([-20, 0, 0])
      rotate(a=-25, v=[0, 1, 0])
        translate([0, 0, HEAD_SIZE])
          cube(HEAD_SIZE * 2, center=true);
    sphere(r=HEAD_SIZE / 2);
    for (i = [0:20]) {
      rotate(a=-i * 180 / 20, v=[0, 0, 1])
        translate([0, HEAD_SIZE / 2 + 8, THICKNESS * 2])
          rotate(a=7, v=[1, 0, 0])
            scale([1, 2, 1])
              cylinder(r=4, h=40);
    }
  }
}

module spike() {
  linear_extrude(THICKNESS)
    polygon([[10, 0], [0, 60], [-10, 0]]);
}

head_band();
for (i = [0:6]) {
  rotate(a=-i * 30, v=[0, 0, 1])
    translate([0, HEAD_SIZE / 2, 0])
      spike();
}

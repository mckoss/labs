// Xmas tree ornament
// by Mike Koss (c) 2014

HEIGHT=100;
RADIUS=30;
THICKNESS=2;
E = 0.1;

$fa=3;
$fs=1;


module piped(from, to, width=1) {
  translate(from)
  multmatrix(m=[
    [1, 0, to[0] - from[0], 0],
    [0, 1, to[1] - from[1], 0],
    [0, 0, to[2] - from[2], 0],
    [0, 0, 0, 1],
  ])
    translate([0, 0, 0.5])
      cube([width, width, 1], center=true);
}

module spiral(height, radius, turns=1, sides=32, width=THICKNESS) {
  for (i = [0 : turns * sides - 1]) {
    assign(
      x1 = radius * cos(i * 360 / sides) * (turns * sides - i) / (turns * sides),
      y1 = radius * sin(i * 360 / sides) * (turns * sides - i) / (turns * sides),
      z1 = height * i / (turns * sides),
      x2 = radius * cos((i + 1) * 360 / sides) * (turns * sides - i - 1) / (turns * sides),
      y2 = radius * sin((i + 1) * 360 / sides) * (turns * sides - i - 1) / (turns * sides),
      z2 = height * (i + 1) / (turns * sides)) {
        piped([x1, y1, z1], [x2, y2, z2], width=width);
     }
   }
}

module multiRotate(steps=8) {
  for (i = [0: steps - 1]) {
    rotate(a=360 * i / steps, v=[0, 0, 1])
      child();
  }
}

// Ring around origin (at z=0)
module ring(r, thickness=THICKNESS, height=THICKNESS) {
  difference() {
    cylinder(h=height, r=r, center=true);
    cylinder(h=height + 2 * E, r=r - thickness, center=true);
  }
}

multiRotate()
  spiral(HEIGHT, RADIUS, width=2);
multiRotate()
  mirror([0, 1, 0])
    spiral(HEIGHT, RADIUS, width=2);
translate([0, 0, THICKNESS/2])
  ring(RADIUS+THICKNESS/2);

translate([0, 0, HEIGHT + 4])
  rotate(a=90, v=[1, 0, 0])
    ring(5);

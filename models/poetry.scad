use <write/Write.scad>
$fa = 3;
E = 0.1;
INCH = 25.4;

WIDTH = 1.75 * INCH;
HEIGHT = 4 * INCH;
THICKNESS = 2;

PINCH = 0.75;

// outer radius
module cone(r1, r2, height = HEIGHT / 2, thickness=THICKNESS) {
  difference() {
    cylinder(r1=r1, r2=r2, h=height);
    translate([0, 0, -E])
      cylinder(r1=r1 - thickness, r2=r2 - thickness,
               h=height + 2 * E);
  }
}

module ring(radius, height, thickness=THICKNESS) {
  difference() {
    cylinder(r=radius, h=height);
    translate([0, 0, -E])
      cylinder(r=radius - thickness, h=height + 2 * E);
  }
}

module bow() {
  rotate(a=90, v=[0, 1, 0])
    scale([1, 0.25, 1])
      ring(HEIGHT/4, 2, 4);
}

module spiral_text(
    text,
    radius,
    step_angle=11,
    text_height=6.0,
    thickness=THICKNESS
    ) {
  for (i = [0 : len(text) - 1]) {
    assign(x = radius * cos(i * step_angle),
           y = radius * sin(i * step_angle),
           z = i * text_height * 1.5 * step_angle / 360) {
      translate([x, y, -z])
        rotate(a=90 + i * step_angle, v=[0, 0, 1])
        rotate(a=5, v=[0, 1, 0])
        rotate(a=90, v=[1, 0, 0])
            write(text[i], h=text_height, t=thickness, center=true);
     }
  }
}

translate([0, 0, HEIGHT / 2 - 2])
  ring(PINCH * WIDTH / 2 + 2, 4, thickness=2);

translate([PINCH * WIDTH / 2 + 3, 0, HEIGHT * 3 / 4])
  rotate(a=5, v=[0, 1, 0])
    bow();
translate([PINCH * WIDTH / 2 + 3, 0, HEIGHT / 4])
  rotate(a=-5, v=[0, 1, 0])
    bow();

// Knot
translate([PINCH * WIDTH / 2 + 1, 0, HEIGHT / 2])
rotate(a=90, v=[0, 1, 0])
difference() {
  sphere(r=4);
  translate([0, 0, -5])
    cube(10, center=true);
}

poem = "Bend this word word back on itself tear along the dotted mine field questions stuck on themselves fold in the egg whites of their eyes and don't shoot yourself in the foot";

translate([0, 0, HEIGHT - E]) union () {
difference() {
  scale([1, 1, -1])
    cone(WIDTH / 2, WIDTH / 2 * PINCH, thickness=THICKNESS / 2);
  translate([0, 0, -5])
    spiral_text(poem, PINCH * WIDTH / 2, thickness=WIDTH / 4);
}
scale([1, 1, -1])
cone(WIDTH / 2 - THICKNESS / 2 + E,
     WIDTH / 2 * PINCH - THICKNESS / 2 + E,
     thickness=THICKNESS / 2);
}

union() {
difference() {
  cone(WIDTH / 2, WIDTH / 2 * PINCH, thickness=THICKNESS / 2);
  translate([0, 0, HEIGHT / 2])
    spiral_text(poem, PINCH * WIDTH / 2, thickness=WIDTH / 4);
}
cone(WIDTH / 2 - THICKNESS / 2 + E,
     WIDTH / 2 * PINCH - THICKNESS / 2 + E,
     thickness=THICKNESS / 2);
}

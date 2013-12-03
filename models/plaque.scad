$fs=1;
$fa=3;

THICKNESS = 10;
WIDTH = 200;
HEIGHT = 240;
CUTOUT = 40;

difference() {
  scale([1, HEIGHT / WIDTH, 1])
    intersection() {
      translate([-WIDTH / 2, 0, 0])
        cylinder(r=WIDTH, h=THICKNESS);
      translate([WIDTH / 2, 0, 0])
        cylinder(r=WIDTH, h=THICKNESS);
      translate([0, -WIDTH, 0])
        cube([WIDTH * 2, WIDTH * 2, THICKNESS * 2], center=true);
    }
  translate([-WIDTH / 2, 0, THICKNESS / 2])
    cylinder(r=CUTOUT, h=THICKNESS * 2, center=true);
  translate([WIDTH / 2, 0, THICKNESS / 2])
    cylinder(r=CUTOUT, h=THICKNESS * 2, center=true);
}
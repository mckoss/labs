use <naca.scad>;

difference() {

union() {
  translate([-50, 0, 0]) body(250);
  wing(40, 60, 0.2, 70);
  translate([125, 0, 0]) wing(20, 30, 0.3, 60);
}

translate([50, 0, -25]) cube([300, 200, 50], center=true);
}

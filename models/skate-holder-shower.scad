$fa = 3;
E = 0.1;
INCH = 25.4;

D = 3 * INCH;
H = 1 * INCH;

SLOT_WIDTH = 1/8 * INCH;

WALL_THICKNESS = 4;

font = "Arial";

difference() {
    cylinder(h=H, r=D/2);
    translate([0, 0, H - 5])
    cube([D+E, SLOT_WIDTH, H], true);

    radial_text(text="QUINCY♥TOPHER", radius=D/2 - WALL_THICKNESS/2,
        start_angle=20, stop_angle=160);
    radial_text(text="♥ GIANNA ♥", radius=D/2 - WALL_THICKNESS/2,
        start_angle=220, stop_angle=320);
}



module radial_text(
    text,
    radius,
    start_angle=0,
    stop_angle = 160,
    thickness=WALL_THICKNESS) {

  step_angle = (stop_angle - start_angle) / (len(text) - 1);
  text_height = step_angle / 180 * PI * radius;
  for (i = [0 : len(text) - 1]) {
      angle = start_angle + i * step_angle;
      x = radius * cos(angle);
      y = radius * sin(angle);
      translate([x, y, H / 2 - 1])
        rotate(a=90 + angle, v=[0, 0, 1])
        rotate(a=90, v=[1, 0, 0])
            write(text[i], h=text_height, t=thickness);
  }
}

module write(word, h, t){
  translate([0, 0, -t/2])
  linear_extrude(height=t)
    text(word, font=font, size=h, halign="center", valign="center");
}

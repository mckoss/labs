// The Microsoft Blibbet
// (c) 2025 Mike Koss

COLOR_FILTER = "all"; // ["all", "white", "black"]

RADIUS = 40;
THICKNESS = 2;
BASE_THICKNESS = 0.8;

SLICE_GAP = 1.2;

LARGE_SLICE_THICKNESS = (2 * RADIUS - 8 * SLICE_GAP)/9;
SMALL_SLICE_THICKNESS = LARGE_SLICE_THICKNESS * 5/12;

SLICE_SPACING = LARGE_SLICE_THICKNESS + SLICE_GAP;

R1= RADIUS / 3;
R2 = RADIUS * 2 / 3;
R_MID = (RADIUS + R2) / 2;

BEVEL_DEPTH = THICKNESS/2;

E = 0.1;

$fn = 200;

FONT = "Arial";

TOP_GAPS = [for (i=[0:7]) RADIUS - LARGE_SLICE_THICKNESS - i * SLICE_SPACING];
CENTER_GAPS = [for (y=TOP_GAPS) y-SLICE_GAP/2];
HIGH_BAR_CENTERS = [for (y=CENTER_GAPS) y - SLICE_GAP/2 - SMALL_SLICE_THICKNESS/2];

echo(TOP_GAPS);
echo(CENTER_GAPS);

module blibbet() {
  difference() {
    cylinder_top_bevel(h=THICKNESS, r=RADIUS, b=BEVEL_DEPTH);
    cut_with_bevel(R2, BEVEL_DEPTH);
    for (y=CENTER_GAPS) {
      translate([0, y, THICKNESS/2])
        cube([2*(RADIUS + E), SLICE_GAP, 2*THICKNESS], center=true);
    }
  }
  difference() {
    small_bars();
    cut_with_bevel(R1, BEVEL_DEPTH);
  }
}

module cylinder_top_bevel(h, r, b) {
  cylinder(h=h-b, r=r);
  translate([0, 0, h-b])
    cylinder(h=b, r1=r, r2=r-b);
}

module cut_with_bevel(r, b) {
    translate([0, 0, -E])
      cylinder(h=THICKNESS + 2 * E, r=r);
    translate([0, 0, THICKNESS-b])
      cylinder(r1=r-E, r2=r+b+E, h=b+E);
}

module small_bar() {
  translate([0, 0, THICKNESS/2])
    cube([2*R_MID, SMALL_SLICE_THICKNESS, THICKNESS], center=true);
}

module small_bars() {
  small_bar();
  translate([0, HIGH_BAR_CENTERS[1], 0])
    small_bar();
  translate([0, HIGH_BAR_CENTERS[2], 0])
    small_bar();
  translate([0, -HIGH_BAR_CENTERS[1], 0])
    small_bar();
  translate([0, -HIGH_BAR_CENTERS[2], 0])
    small_bar();
}

module color_part(c) {
    if (COLOR_FILTER == "all" || c == COLOR_FILTER) {
        color(c) children();
    }
}

module engrave(word, h, t, dy=0) {
  difference() {
    children();
    rotate([0, 180, 0])
      translate([0, dy, -t+E])
        write(word, h, t);
  }
}

module write(word, h, t){
  linear_extrude(height=t)
    text(word, font=FONT, size=h, halign="center", valign="center");
}

color_part("black")
  translate([0, 0, 3*BASE_THICKNESS])
    blibbet();

color_part("white")
  engrave("Excel", 10, BASE_THICKNESS+2*E, 15)
  engrave("XL", 10, BASE_THICKNESS+2*E, -15)
  engrave("9/30/2025", 4, BASE_THICKNESS+2*E, -30)
  engrave("Sept. 30, 1985", 6, BASE_THICKNESS+2*E)
    cylinder(h=BASE_THICKNESS, r=RADIUS);

color_part("black")
  translate([0, 0, BASE_THICKNESS])
    cylinder(h=BASE_THICKNESS, r=RADIUS);

color_part("white")
  translate([0, 0, 2*BASE_THICKNESS])
    cylinder(h=BASE_THICKNESS, r=RADIUS);

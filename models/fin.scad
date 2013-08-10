use <naca.scad>;

PART = "foil"; // [eliptical, foil, box]

TAB_X = 6.2;
TAB_Y = 20.6;
TAB_Z = 13.0;
TAB_SPACING = 33.0;
TAB_CENTER = TAB_Y + TAB_SPACING / 2;
TAB_DENT = 7.0;

FIN_BASE = 89.1;
FIN_HEIGHT = 74.0;
FIN_WIDTH = 6.4;
FIN_LENGTH = 100.0;
FIN_RADIUS = 400.0;

SUPPORT_BASE = 120;


// Epsilon
E = 0.01;

module eliptical_fin() {
  tabs();
  translate([0, TAB_CENTER, 0])
    center_eliptical();
}

module box_fin() {
   tabs();
   difference() {
     translate([0, TAB_CENTER, 0])
        center_box();
     via();
     translate([0, TAB_SPACING + TAB_Y, 0])
       via();
   }
}

module foil_fin() {
  rotate(a=-90, v=[0, 0, 1])
    tabs();
  hull() {
    translate([TAB_CENTER - SUPPORT_BASE / 2, 0, 0])
      naca_25d(SUPPORT_BASE);
    translate([TAB_CENTER - FIN_BASE / 2, 0, FIN_HEIGHT / 5])
      naca_25d(FIN_BASE);
  }
  hull() {
    translate([TAB_CENTER - FIN_BASE / 2, 0, FIN_HEIGHT / 5])
      naca_25d(FIN_BASE);
    translate([TAB_CENTER - FIN_BASE / 2 + FIN_BASE / 4, 0, FIN_HEIGHT])
        naca_25d(FIN_BASE * 0.75);
  }
  wing_extension();
  reflect_y() wing_extension();
}

module wing_extension() {
  hull() {
    translate([TAB_CENTER - FIN_BASE / 2 + FIN_BASE / 4, 0, FIN_HEIGHT])
        naca_25d(FIN_BASE * 0.75);
    translate([TAB_CENTER - FIN_BASE / 2 + FIN_BASE / 4, 0, FIN_HEIGHT])
      rotate(a=45, v=[1, 0, 0])
        naca_25d(FIN_BASE * 0.75);
    translate([TAB_CENTER - FIN_BASE / 2 + FIN_BASE / 2, -25, FIN_HEIGHT + 25])
      rotate(a=45, v=[1, 0, 0])
        naca_25d(FIN_BASE * 0.50);
  }
}

module winglet() {
  rotate(a=45, v=[1, 0, 0])
    naca(FIN_BASE * .5, FIN_BASE * .5, taper=0.75, sweep_ang=15);
}

module reflect_y() {
  multmatrix(m=[[1, 0, 0, 0],
                [0, -1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]])
    child(0);
}

module via() {
  translate([0, 0, -2])
    rotate(a=45, v=[0, 1, 0])
    translate([0, (TAB_Y - TAB_DENT) / 2, 0])
    cube([TAB_DENT, TAB_DENT, FIN_HEIGHT]);
}

module center_box(channels=2) {
  width = FIN_WIDTH * (3 * channels + 1);
  difference () {
    translate([-width / 2, -FIN_LENGTH / 2, 0])
      cube([width, FIN_LENGTH, FIN_HEIGHT / (channels + 1) + 2 * FIN_WIDTH]);
    for (c = [1: channels]) {
      translate([FIN_WIDTH / 2 - (channels - c) * (FIN_WIDTH * 3), -FIN_LENGTH / 2 - E, FIN_WIDTH])
        cube([FIN_WIDTH * 2, FIN_LENGTH + 2 * E, FIN_HEIGHT / (channels + 1)]);
    }
  }
}

module tabs() {
  translate([0, 0, E]) {
    tab(-1);
    translate([0, TAB_Y + TAB_SPACING, 0])
      tab(1);
  }
}

module tab(dir=-1) {
   translate([0, TAB_Y / 2, -TAB_Z / 2])
     difference () {
       cube([TAB_X, TAB_Y, TAB_Z], center=true);
         translate([dir * TAB_X / 3, 0, 0])
           rotate(a=-45, v=[0, 1, 0])
             cube(size=TAB_DENT, center=true);
    }
}

module center_eliptical() {
  intersection() {
    scale([FIN_WIDTH / FIN_LENGTH, 1, 1])
      cylinder(r=FIN_LENGTH / 2, h=FIN_HEIGHT);
/*
    scale([FIN_WIDTH / FIN_HEIGHT / 2, 1, 1])
      translate([0, FIN_LENGTH / 2, 0])
        rotate(a=90, v=[1, 0, 0])
          cylinder(r=FIN_HEIGHT, h=FIN_LENGTH + E);
*/
  }
}

if (PART == "eliptical") eliptical_fin();
if (PART == "foil") foil_fin();
if (PART == "box") box_fin();
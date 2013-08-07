TAB_X = 6.3;
TAB_Y = 20.6;
TAB_Z = 14.0;
TAB_SPACING = 33.0;
TAB_CENTER = TAB_Y + TAB_SPACING / 2;
TAB_DENT = 7.0;

FIN_BASE = 89.1;
FIN_HEIGHT = 74.0;
FIN_WIDTH = 6.4;
FIN_LENGTH = 100.0;
FIN_RADIUS = 400.0;


// Epsilon
E = 0.01;

module whole_fin() {
  translate([0, 0, E]) {
    tab();
    translate([0, TAB_Y + TAB_SPACING, 0])
      tab();
  }
  fin();
}

module tab() {
   translate([-TAB_X / 2, 0, -TAB_Z])
     difference () {
       cube([TAB_X, TAB_Y, TAB_Z]);
       translate([TAB_X / 2, TAB_Y / 2 - TAB_DENT / 2, 7])
         rotate(a=45, v=[0, 1, 0])
           cube(size=TAB_DENT);
    }
}

module fin() {
  translate([0, TAB_CENTER, 0])
    linear_extrude(height=FIN_HEIGHT)
      section();
}

module section() {
  intersection() {
    translate([FIN_RADIUS - FIN_WIDTH / 2, 0, 0])
      circle(r=FIN_RADIUS, $fa=3);
    translate([-FIN_RADIUS + FIN_WIDTH / 2, 0, 0])
      circle(r=FIN_RADIUS, $fa=3);
  }
}

whole_fin();

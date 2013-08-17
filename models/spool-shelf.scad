/*
   Spool Shelf - by Mike Koss (August, 2013)

   Hold one or more spools with a stackable shelving unit.
*/

E = 0.01;

SPOOLS = 3;

SPOOL_R = 100;
SPOOL_W = 75;
SPOOL_GAP = 10;
SPOOL_CLEARANCE = 5;

SHELF_WIDTH = SPOOLS * (SPOOL_W + SPOOL_GAP) + SPOOL_GAP;
RAIL_SEP = SPOOL_R;

END_WIDTH = 10;
END_HEIGHT = 30;
RAIL_WIDTH = END_WIDTH;
END_DEPTH = RAIL_SEP + 2 * RAIL_WIDTH;

module shelf() {
  shelf_end();
  translate([END_WIDTH + SHELF_WIDTH, 0, 0])
    shelf_end();
  difference() {
    union() {
      translate([END_WIDTH, -RAIL_SEP / 2 - RAIL_WIDTH / 2, 0])
        rail();
    translate([END_WIDTH, RAIL_SEP / 2 + RAIL_WIDTH / 2, 0])
      rail();
    }
    translate([END_WIDTH, 0, 0])
      spool(SHELF_WIDTH);
  }
}

module rail() {
  translate([-E, -RAIL_WIDTH / 2, 0])
    cube([SHELF_WIDTH + 2 * E, RAIL_WIDTH, END_HEIGHT]);
}

module shelf_end() {
  translate([0, -END_DEPTH / 2, 0])
    cube([END_WIDTH, END_DEPTH, END_HEIGHT]);
}

module spool(width=SPOOL_W) {
  translate([0, 0, SPOOL_R + SPOOL_CLEARANCE])
    rotate(a=90, v=[0, 1, 0])
      cylinder(r=SPOOL_R, h=width, $fa=3);
}

module spools() {
  for (i = [0 : SPOOLS-1]) {
    translate([END_WIDTH + SPOOL_GAP + i * (SPOOL_W + SPOOL_GAP), 0, 0])
      spool();
  }
}


shelf();
% spools();
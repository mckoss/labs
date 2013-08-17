/*
   Spool Shelf - by Mike Koss (August, 2013)

   Hold one or more spools with a stackable shelving unit.
*/

E = 0.01;

SPOOLS = 4;

SPOOL_R = 100;
SPOOL_W = 75;
SPOOL_GAP = 20;
SPOOL_CLEARANCE = 5;

SHELF_WIDTH = SPOOLS * (SPOOL_W + SPOOL_GAP) + SPOOL_GAP;
RAIL_SEP = SPOOL_R;

END_WIDTH = 15;
END_HEIGHT = 30;
RAIL_WIDTH = END_WIDTH;

module shelf() {
  shelf_end();
  translate([END_WIDTH + SHELF_WIDTH, 0, 0])
    shelf_end();
  translate([END_WIDTH, -RAIL_SEP / 2 - RAIL_WIDTH / 2, 0])
    rail();
  translate([END_WIDTH, RAIL_SEP / 2 + RAIL_WIDTH / 2, 0])
    rail();
}

module rail() {
  translate([-E, -RAIL_WIDTH / 2, 0])
    cube([SHELF_WIDTH + 2 * E, RAIL_WIDTH, END_HEIGHT]);
}

module shelf_end() {
  translate([0, -SPOOL_R, 0])
    cube([END_WIDTH, SPOOL_R * 2, END_HEIGHT]);
}

module spool() {
  translate([0, 0, SPOOL_R + SPOOL_CLEARANCE])
    rotate(a=90, v=[0, 1, 0])
      cylinder(r=SPOOL_R, h=SPOOL_W, $fa=3);
}

module spools() {
  for (i = [0 : SPOOLS-1]) {
    translate([END_WIDTH + SPOOL_GAP + i * (SPOOL_W + SPOOL_GAP), 0, 0])
      spool();
  }
}

shelf();
spools();

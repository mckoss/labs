/*
   Spool Shelf - by Mike Koss (August, 2013)

   Hold one or more spools with a stackable shelving unit.
*/

E = 0.01;
GAP = 0.1;

PART = "shelf"; // [shelf, post]

SPOOLS = 1;

SPOOL_R = 100;
SPOOL_W = 75;
SPOOL_GAP = 10;
SPOOL_CLEARANCE = 3;

SHELF_WIDTH = SPOOLS * (SPOOL_W + SPOOL_GAP) + SPOOL_GAP;
RAIL_SEP = SPOOL_R;

END_WIDTH = 10;
RAIL_WIDTH = END_WIDTH;
END_DEPTH = RAIL_SEP + 2 * RAIL_WIDTH;
END_HEIGHT = SPOOL_CLEARANCE + SPOOL_R - sqrt(pow(SPOOL_R, 2) - pow(END_DEPTH / 2, 2));

RAIL_CENTER = RAIL_SEP / 2 + RAIL_WIDTH / 2;

POST_WIDTH = END_WIDTH - 4;
POST_HOLE = END_HEIGHT / 3;
BRACE_DEPTH = POST_WIDTH / 2;
BRACE_HEIGHT = SPOOL_R * 2 / 7;
POST_HEIGHT = SPOOL_R * 2 + BRACE_HEIGHT + POST_HOLE - SPOOL_GAP;

module shelf() {
  shelf_end();
  translate([2 * END_WIDTH + SHELF_WIDTH, 0, 0])
    reflect_x()
      shelf_end();
  difference() {
    union() {
      translate([END_WIDTH, -RAIL_CENTER, 0])
        rail();
      translate([END_WIDTH, RAIL_CENTER, 0])
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
  difference() {
    translate([0, -END_DEPTH / 2, 0])
      cube([END_WIDTH, END_DEPTH, END_HEIGHT]);
  translate([END_WIDTH / 2, -RAIL_CENTER, END_HEIGHT])
    cube([POST_WIDTH + 2 * GAP, POST_WIDTH + 2 * GAP, 2 * POST_HOLE], center=true);
  translate([END_WIDTH / 2, RAIL_CENTER, END_HEIGHT])
    cube([POST_WIDTH + 2 * GAP, POST_WIDTH + 2 * GAP, 2 * POST_HOLE], center=true);
  }
  % translate([END_WIDTH / 2, -RAIL_CENTER, END_HEIGHT - POST_HOLE])
      post();
  % translate([END_WIDTH / 2, +RAIL_CENTER, END_HEIGHT - POST_HOLE])
      post();
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

module post() {
  translate([0, 0, POST_HEIGHT / 2])
    cube([POST_WIDTH, POST_WIDTH, POST_HEIGHT], center=true);
  translate([0, 0, POST_HEIGHT])
    brace();
}

module brace() {
  rotate(a=-90, v=[1, 0, 0])
    linear_extrude(BRACE_DEPTH, center=true)
      polygon([[0, 0], [BRACE_HEIGHT, 0], [0, BRACE_HEIGHT]]);
}

module reflect_x() {
  multmatrix(m=[[-1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]])
    child(0);
}

if (PART == "shelf") {
  shelf();
  spools();
}
if (PART == "post") {
  translate([POST_HEIGHT / 2, 0, POST_WIDTH / 2])
    rotate(a=-90, v=[0, 1, 0])
      post();
}

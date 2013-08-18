/*
   Spool Shelf - by Mike Koss (August, 2013)

   Hold one or more spools with a stackable shelving unit.
*/

E = 0.01;
GAP = 0.1;

PART = "shelf"; // [shelf, post, post-mirror]

SPOOLS = 1;

SPOOL_R = 100;
SPOOL_W = 75;
SPOOL_GAP = 10;
SPOOL_CLEARANCE = 3;

SHELF_WIDTH = SPOOLS * (SPOOL_W + SPOOL_GAP);
RAIL_SEP = SPOOL_R;

END_WIDTH = 10;
END_DEPTH = RAIL_SEP + 2 * END_WIDTH;
END_HEIGHT = SPOOL_CLEARANCE + SPOOL_R - sqrt(pow(SPOOL_R, 2) - pow(END_DEPTH / 2, 2));

RAIL_CENTER = RAIL_SEP / 2 + END_WIDTH / 2;

POST_WIDTH = END_WIDTH - 4;
POST_HOLE = END_HEIGHT / 2 - 3;
BRACE_DEPTH = POST_WIDTH / 2;
BRACE_HEIGHT = SPOOL_R * 2 / 7;
POST_HEIGHT = SPOOL_R * 2 + BRACE_HEIGHT + POST_HOLE - SPOOL_GAP;

module shelf() {
  difference() {
    frame(SHELF_WIDTH + 2 * END_WIDTH,
          RAIL_SEP + 2 * END_WIDTH, END_HEIGHT, END_WIDTH);
    translate([-SHELF_WIDTH / 2 - END_WIDTH / 2, 0, 0])
      side_cutouts();
    translate([SHELF_WIDTH / 2 + END_WIDTH / 2, 0, 0])
      reflect_x()
        side_cutouts();
    spool(SHELF_WIDTH - 2 * E);
  }
  % spools();
}

module frame(width, depth, height, thickness) {
  translate([0, 0, height / 2])
  difference() {
    cube([width, depth, height], center=true);
    cube([width - 2 * thickness, depth - 2 * thickness, height + 1], center=true);
  }
}

module side_cutouts() {
  for (y = [-RAIL_CENTER, RAIL_CENTER]) {
    translate([0, y, END_HEIGHT])
      cube([POST_WIDTH + 2 * GAP, POST_WIDTH + 2 * GAP, 2 * POST_HOLE], center=true);
  }
  translate([0, -RAIL_CENTER, 0])
    post_cutout();
  translate([0, +RAIL_CENTER, 0])
    reflect_y()
      post_cutout();
}

module post_cutout() {
  translate([0, 0, END_HEIGHT - POST_HOLE])
     post();
  translate([0, 0, -POST_HEIGHT + POST_HOLE])
    post();
}

module spools() {
  translate([-((SPOOLS - 1) * (SPOOL_W + SPOOL_GAP)) / 2, 0, 0])
  for (i = [0 : SPOOLS-1]) {
    translate([i * (SPOOL_W + SPOOL_GAP), 0, 0])
      spool();
  }
}

module spool(width=SPOOL_W) {
  translate([-width / 2, 0, SPOOL_R + SPOOL_CLEARANCE])
    rotate(a=90, v=[0, 1, 0])
      cylinder(r=SPOOL_R, h=width, $fa=3);
}

module post() {
  translate([0, 0, POST_HEIGHT / 2])
    cube([POST_WIDTH, POST_WIDTH, POST_HEIGHT], center=true);
  translate([POST_WIDTH / 2 - E, 0, POST_HEIGHT])
    brace();
  rotate(a=90, v=[0, 0, 1])
    translate([POST_WIDTH / 2 - E, (POST_WIDTH - BRACE_DEPTH) / 2, 0])
      reflect_z()
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

module reflect_y() {
  multmatrix(m=[[1, 0, 0, 0],
                [0, -1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]])
    child(0);
}

module reflect_z() {
  multmatrix(m=[[1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, -1, 0],
                [0, 0, 0, 1]])
    child(0);
}

module print_post() {
  translate([POST_HEIGHT / 2, 0, POST_WIDTH / 2])
    rotate(a=-90, v=[0, 1, 0])
      post();
}

if (PART == "shelf") {
  shelf();
}

if (PART == "post") {
  print_post();
}

if (PART == "post-mirror") {
  reflect_y() print_post();
}

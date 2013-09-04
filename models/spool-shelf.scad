/*
   Spool Shelf - by Mike Koss (August, 2013)

   Hold one or more spools with a stackable shelving unit.
*/

E = 0.01;
GAP = 0.3;
$fa=3;
$fs=1;

PART = "shelf"; // [shelf, post, post-mirror, test-shelf]

SPOOLS = 3;

SPOOL_R = 100;
SPOOL_W = 75;
SPOOL_GAP = 10;
SPOOL_CLEARANCE = 3;

SHELF_WIDTH = SPOOLS * (SPOOL_W + SPOOL_GAP);
RAIL_SEP = SPOOL_R;

END_WIDTH = 10;
END_DEPTH = RAIL_SEP + 2 * END_WIDTH;
END_HEIGHT = SPOOL_CLEARANCE + SPOOL_R - sqrt(pow(SPOOL_R, 2) - pow(END_DEPTH / 2, 2));

GUIDE_HEIGHT= END_HEIGHT / 2;
GUIDE_DIAMETER = 3;

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

    guides();
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
  translate([0, -RAIL_CENTER, 0])
    post_cutout();
  translate([0, +RAIL_CENTER, 0])
    reflect_y()
      post_cutout();
}

module post_cutout() {
  translate([0, 0, END_HEIGHT - POST_HOLE])
     post(negative=true);
  translate([0, 0, -POST_HEIGHT + POST_HOLE])
    post(negative=true);
}

module spools() {
  translate([-((SPOOLS - 1) * (SPOOL_W + SPOOL_GAP)) / 2, 0, 0])
  for (i = [0 : SPOOLS-1]) {
    translate([i * (SPOOL_W + SPOOL_GAP), 0, 0])
      spool();
  }
}

module guides() {
  translate([-((SPOOLS - 1) * (SPOOL_W + SPOOL_GAP)) / 2, 0, 0])
  for (i = [0 : SPOOLS-1]) {
    translate([i * (SPOOL_W + SPOOL_GAP), 0, 0])
      guide();
  }
}

module guide() {
  translate([0, -RAIL_SEP / 2 + E, GUIDE_HEIGHT])
    rotate(a=90, v=[1, 0, 0])
      union() {
        cylinder(r1=GUIDE_DIAMETER / 2 + 1, r2=GUIDE_DIAMETER / 2, h=3);
        cylinder(r=GUIDE_DIAMETER / 2, h=END_WIDTH + 2 * E);
        translate([0, 0, END_WIDTH + 2 * E - 3])
            cylinder(r1=GUIDE_DIAMETER / 2, r2=GUIDE_DIAMETER / 2 + 1, h=3);
      }
}

module spool(width=SPOOL_W) {
  translate([-width / 2, 0, SPOOL_R + SPOOL_CLEARANCE])
    rotate(a=90, v=[0, 1, 0])
      cylinder(r=SPOOL_R, h=width, $fa=3);
}

module post(negative=false) {
  print_width = POST_WIDTH + (negative ? 2 * GAP : 0);
  translate([0, 0, POST_HEIGHT / 2])
    cube([print_width, print_width, POST_HEIGHT], center=true);
  translate([POST_WIDTH / 2 - E, 0, POST_HEIGHT])
    brace(negative);
  rotate(a=90, v=[0, 0, 1])
    translate([POST_WIDTH / 2 - E, (POST_WIDTH - BRACE_DEPTH) / 2, 0])
      reflect_z()
        brace(negative);
}

module brace(negative=false) {
  print_height = BRACE_HEIGHT + (negative ? 2 * GAP : 0);
  print_depth = BRACE_DEPTH + (negative ? 2 * GAP : 0);
  rotate(a=-90, v=[1, 0, 0])
    if (negative) {
      translate([0, 0, -print_depth / 2])
        cube([print_height, print_height, print_depth]);
    } else {
      linear_extrude(print_depth, center=true)
        polygon([[0, 0], [print_height, 0], [0, print_height]]);
    }
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

module test_shelf() {
  difference() {
    shelf();
    translate([62, 0, 0])
      cube([150, 150, 80], center=true);
  }
}

if (PART == "shelf") {
  shelf();
}

if (PART == "test-shelf") {
  test_shelf();
}

if (PART == "post") {
  print_post();
}

if (PART == "post-mirror") {
  reflect_y() print_post();
}

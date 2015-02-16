// Firebase screw-together logo.
// by Mike Koss (c) 2015

use <threads.scad>

DEBUG = false;

$fa=3;
$fs=1;
E = 0.1;

BLACK = [0.3, 0.3, 0.3];
YELLOW = [1.0, 0.85, 0.19];

//
// Build options.
//
PART = "top-cap";
// [top-cap, top-connector, middle, bottom-connector, bottom-cap, ALL]

if (PART == "top-connector") {
  color(BLACK) hollow_connector(open=true);
}

if (PART == "bottom-connector") {
  color(BLACK) hollow_connector(open=false);
}

if (PART == "top-cap") {
  color(YELLOW) top_cap();
}

if (PART == "bottom-cap") {
  color(YELLOW) bottom_cap();
}

if (PART == "middle") {
  color(YELLOW) middle_slice();
}

if (PART == "all") {
  all();
}

// Rotate part 180 degrees on z axis - but preserve handedness.
module flip_z() {
  rotate(180, v=[0, 1, 0])
    children(0);
}

module all() {
  exploded = 10;
  middle_pos = 0;
  top_connector_pos = middle_pos + exploded +
    CONNECTOR_LENGTH / 2 + WALL_THICKNESS / 2 + AIR_GAP;
  top_cap_pos = top_connector_pos + exploded + SLICE_GAP / 2 + SLICE_HEIGHT / 2;

  translate([0, 0, top_cap_pos])
    color(YELLOW) top_cap();
  translate([0, 0, top_connector_pos])
    color(BLACK) hollow_connector(open=true);
  color(YELLOW) middle_slice();
  translate([0, 0, -top_connector_pos])
    color(BLACK) hollow_connector(open=false);
  translate([0, 0, -top_cap_pos])
    color(YELLOW) bottom_cap();
}


//
// Part Dimensions
//
OUTER_DIAMETER = 50;

SLICE_HEIGHT = OUTER_DIAMETER * 1.1 / 3.6;
SLICE_GAP = OUTER_DIAMETER * 0.4 / 3.6;
SLICE_BASE = SLICE_GAP / 3;
SLICES = 3;
TOTAL_HEIGHT = SLICES * (SLICE_GAP + SLICE_HEIGHT) + SLICE_BASE - SLICE_GAP;
INNER_DIAMETER = OUTER_DIAMETER * 0.9;
WALL_THICKNESS = 3;

//
// Thread constants
//
PITCH = 2;
STARTS = 3;
AIR_GAP = 0.5;
THREAD_LENGTH = SLICE_HEIGHT / 2  - WALL_THICKNESS / 2 - AIR_GAP;
CONNECTOR_LENGTH = 2 * THREAD_LENGTH + SLICE_GAP;

module top_cap() {
  rotate(180, v=[0, 1, 0])
    bottom_cap();
}

module bottom_cap() {
  difference() {
    slice();
    slice_threads();
    translate([0, 0, WALL_THICKNESS])
      cylinder(h=SLICE_HEIGHT + 2 * E, r=INNER_DIAMETER / 2 - WALL_THICKNESS, center=true);
  }
}

module middle_slice() {
  difference() {
    slice();
    middle_slice_cuts();
  }
}

module middle_slice_cuts() {
  cylinder(h=SLICE_HEIGHT + 2 * E, r=INNER_DIAMETER / 2 - WALL_THICKNESS, center=true);
  slice_threads();
  flip_z() slice_threads();
}

module slice() {
  if (DEBUG) {
    cylinder(h=SLICE_HEIGHT, r=OUTER_DIAMETER / 2, center=true);
  } else {
    beveled_cylinder(h=SLICE_HEIGHT, r=OUTER_DIAMETER / 2, bevel_radius=2, center=true);
  }
}

module beveled_cylinder(r=10, h=5, bevel_radius=2, center=true) {
  bevel=[
         [cos(90), sin(90)],
         [cos(68), sin(68)],
         [cos(45), sin(45)],
         [cos(22), sin(22)],
         [cos(0), sin(0)]
         ];
  bevel_pts = [
               [0, 0], [0, h],
               [r, h] + (bevel[0]+[-1, -1]) * bevel_radius,
               [r, h] + (bevel[1]+[-1, -1]) * bevel_radius,
               [r, h] + (bevel[2]+[-1, -1]) * bevel_radius,
               [r, h] + (bevel[3]+[-1, -1]) * bevel_radius,
               [r, h] + (bevel[4]+[-1, -1]) * bevel_radius,

               [r, 0] + ([bevel[4][0], -bevel[4][1]] + [-1, 1]) * bevel_radius,
               [r, 0] + ([bevel[3][0], -bevel[3][1]] + [-1, 1]) * bevel_radius,
               [r, 0] + ([bevel[2][0], -bevel[2][1]] + [-1, 1]) * bevel_radius,
               [r, 0] + ([bevel[1][0], -bevel[1][1]] + [-1, 1]) * bevel_radius,
               [r, 0] + ([bevel[0][0], -bevel[0][1]] + [-1, 1]) * bevel_radius
    ];
  translate([0, 0, center ? -h / 2 : 0])
    rotate_extrude($fa=3, convexity=3)
      polygon(points=bevel_pts);
}


module slice_threads() {
  translate([0, 0, WALL_THICKNESS / 2 + AIR_GAP])
    metric_thread(internal=true,
                  length=THREAD_LENGTH + E,
                  diameter=INNER_DIAMETER, pitch=PITCH,
                  n_starts=STARTS);
}

module hollow_connector(open=true) {
  difference() {
    connector();
    translate([0, 0, open ? -E : WALL_THICKNESS])
      cylinder(h=CONNECTOR_LENGTH + 2 * E,
               r=INNER_DIAMETER / 2 - WALL_THICKNESS,
               center=true);
  }
}

// 2-sided threaded connector - centered around origin.
module connector() {
  connector_threads();
  cylinder(h=SLICE_GAP, r=INNER_DIAMETER / 2, center=true);
  flip_z()
    connector_threads();
}

module connector_threads() {
  translate([0, 0, SLICE_GAP / 2 - E])
    metric_thread(length=THREAD_LENGTH,
                  diameter=INNER_DIAMETER,
                  pitch=PITCH,
                  n_starts=STARTS);
}

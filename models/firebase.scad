// Firebase screw-together logo.
// by Mike Koss (c) 2015

use <threads.scad>

DEBUG = true;

$fa=3;
$fs=1;
E = 0.1;

BLACK = [0.3, 0.3, 0.3];
YELLOW = [1.0, 0.85, 0.19];

//
// Build options.
//
PART = "ALL"; // [connector, top-cap, middle, bottom-cap, ALL]]

if (PART == "connector") {
  color(BLACK) hollow_connector();
}

if (PART == "top-cap") {
  color(YELLOW) slice();
}

exploded = 20;

// Rotate part 180 degrees on z axis.
module flip_z() {
  rotate(a=180, v=[0, 1, 0])
    children(0);
}

if (PART == "ALL") {
  translate([0, 0, CONNECTOR_LENGTH / 2 + WALL_THICKNESS / 2 + AIR_GAP + exploded])
    color(BLACK) hollow_connector();
  color(YELLOW) middle_slice();
  flip_z() {
    translate([0, 0, CONNECTOR_LENGTH / 2 + WALL_THICKNESS / 2 + AIR_GAP + exploded])
      color(BLACK) hollow_connector();
      }
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
THREAD_LENGTH = SLICE_HEIGHT / 2  - WALL_THICKNESS / 2;
AIR_GAP = 0.5;

module end_cap() {
  difference() {
    slice();
    translate([0, 0, WALL_THICKNESS])
      union() {
      cylinder(h=SLICE_HEIGHT, r=OUTER_DIAMETER / 2 - WALL_THICKNESS - 0);
    }
  }
}

module middle_slice() {
  difference() {
    slice();
    slice_threads();
    flip_z() slice_threads();
    cylinder(h=SLICE_HEIGHT, r=INNER_DIAMETER / 2 - WALL_THICKNESS, center=true);
  }
}

module slice() {
  bevel = 2;
  beveled_cylinder(h=SLICE_HEIGHT, r=OUTER_DIAMETER / 2, bevel_radius=2, center=true);
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
    rotate_extrude($fa=3)
      polygon(points=bevel_pts);
}


module slice_threads() {
  translate([0, 0, WALL_THICKNESS / 2 + AIR_GAP])
    metric_thread(internal=true,
                  length=THREAD_LENGTH - AIR_GAP + 2,
                  diameter=INNER_DIAMETER, pitch=PITCH,
                  n_starts=STARTS);
}

module hollow_connector() {
  difference() {
    connector();
    cylinder(h=CONNECTOR_LENGTH, r=INNER_DIAMETER / 2 - WALL_THICKNESS, center=true);
  }
}

module connector() {
  translate([0, 0, SLICE_GAP / 2 - E])
    metric_thread(length=THREAD_LENGTH - AIR_GAP,
                  diameter=INNER_DIAMETER, pitch=PITCH,
                  n_starts=STARTS);
  cylinder(h=SLICE_GAP, r=INNER_DIAMETER / 2, center=true);
  translate([0, 0, -THREAD_LENGTH + AIR_GAP - SLICE_GAP / 2 + E])
      metric_thread(length=THREAD_LENGTH - AIR_GAP,
                    diameter=INNER_DIAMETER, pitch=PITCH,
                    n_starts=STARTS);
}

CONNECTOR_LENGTH = 2 * (THREAD_LENGTH - AIR_GAP) + SLICE_GAP;

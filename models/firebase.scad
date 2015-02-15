// Firebase screw-together logo.
// by Mike Koss (c) 2015

use <threads.scad>

PART = "ALL"; // [connector, cap, middle, ALL]]

$fa=3;
$fs=1;
E = 0.1;

DEBUG = true;

BLACK = [0.3, 0.3, 0.3];
YELLOW = [1.0, 0.85, 0.19];

OUTER_DIAMETER = 50;

SLICE_HEIGHT = OUTER_DIAMETER * 1.1 / 3.6;
SLICE_GAP = OUTER_DIAMETER * 0.4 / 3.6;
SLICE_BASE = SLICE_GAP / 3;
SLICES = 3;
TOTAL_HEIGHT = SLICES * (SLICE_GAP + SLICE_HEIGHT) + SLICE_BASE - SLICE_GAP;
INNER_DIAMETER = OUTER_DIAMETER * 0.9;
WALL_THICKNESS = 3;

// Thread constants
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

module slice() {
  bevel = 2;
  if (DEBUG) {
    cylinder(h=SLICE_HEIGHT, r=OUTER_DIAMETER / 2, center=true);
  } else {
    minkowski() {
      cylinder(h=SLICE_HEIGHT - 2 * bevel,
               r=OUTER_DIAMETER / 2 - 2 * bevel,
               $fa=3, center=true);
      sphere(r=bevel, $fs=1);
    }
  }
}

module slice_threads() {
  translate([0, 0, WALL_THICKNESS / 2 + AIR_GAP])
    metric_thread(internal=true,
                  length=THREAD_LENGTH - AIR_GAP + 2,
                  diameter=INNER_DIAMETER, pitch=PITCH,
                  n_starts=STARTS);
}

module threaded_slice() {
  difference() {
    slice();
    slice_threads();
    mirror([0, 0, 1]) slice_threads();
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

module hollow_connector() {
  difference() {
    connector();
    cylinder(h=CONNECTOR_LENGTH, r=INNER_DIAMETER / 2 - WALL_THICKNESS, center=true);
  }
}


if (PART == "connector") {
  color(BLACK) hollow_connector();
}

if (PART == "cap") {
  color(YELLOW) slice();
}

exploded = 20;

if (PART == "ALL") {
  translate([0, 0, CONNECTOR_LENGTH / 2 + WALL_THICKNESS / 2 + AIR_GAP + exploded])
    color(BLACK) hollow_connector();
  color(YELLOW) threaded_slice();
  mirror([0, 0, 1])
    translate([0, 0, CONNECTOR_LENGTH / 2 + WALL_THICKNESS / 2 + AIR_GAP + exploded])
      color(BLACK) hollow_connector();
}

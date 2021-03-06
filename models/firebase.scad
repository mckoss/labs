// Firebase screw-together logo.
// by Mike Koss (c) 2015

// OpenSCAD /CGAL is asserting on intersection with polygon faces.
// Stubbing out this function temporarily. - v2014.03
// use <threads.scad>
//module metric_thread(diameter=8, pitch=1, length=1, internal=false, n_starts=1) {
//  radius = diameter / 2 + (internal ? 0.5 : 0);
//  cylinder(h=length, r=radius);
//}
use <Thread_Library.scad>;

$fa=3;
$fs=1;
E = 0.1;
PHI = (1 + sqrt(5))/2;

BLACK = [0.3, 0.3, 0.3];
YELLOW = [1.0, 0.85, 0.19];

//
// Build options.
//
PART = "bottom-cap";
// [top-cap, top-connector, middle, bottom-connector, bottom-cap, ALL]

if (PART == "top-connector") {
  color(BLACK) hollow_connector(open=true);
}

if (PART == "bottom-connector") {
  color(BLACK) bottom_connector();
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

if (PART == "tea-light") {
  tea_light();
}

if (PART == "ALL") {
  all();
}

// Rotate part 180 degrees on z axis - but preserve handedness.
module flip_z() {
  rotate(180, v=[0, 1, 0])
    children(0);
}

module all() {
  exploded = 20;
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

// Tea light dimensions.
LIGHT_DIAMETER = 36 + 1;
LIGHT_HEIGHT = 17 + 1;
PIN_DIAMETER = 2.5;
PIN_RADIUS = LIGHT_DIAMETER / 2 - 2.5;
PIN_HEIGHT = 2;
BULB_DIAMETER = 12;
BULB_HEIGHT = 18;
WINDOW_ANGLE = -34;
WINDOW_WIDTH = 6 + 4;
WINDOW_LENGTH = 11 + 1;
WINDOW_HEIGHT = 7;
WINDOW_RADIUS = LIGHT_DIAMETER / 2 - 5.6;

//
// Thread constants
//
PITCH = 2;
AIR_GAP = 0.5;
THREAD_CLEARANCE = 0.2;
THREAD_LENGTH = SLICE_HEIGHT / 2  - WALL_THICKNESS / 2 - AIR_GAP;
CONNECTOR_LENGTH = 2 * THREAD_LENGTH + SLICE_GAP;

module top_cap() {
  flip_z()
  difference() {
    flip_z()
      union() {
        translate([0, 0, SLICE_HEIGHT/2 * 0.8])
          multiRotate(4, 7)
              rotate(-10, v=[0, 1, 0])
                flame();
        slice();
      }
    slice_threads();
  }
  difference() {
    cylinder(h=SLICE_HEIGHT, r=INNER_DIAMETER/2 - WALL_THICKNESS - AIR_GAP, center=true);
    translate([0, 0, -SLICE_HEIGHT/2])
      sphere(r=INNER_DIAMETER/2 - 3 * WALL_THICKNESS);
  }
}

module flame() {
  difference() {
    cylinder(h=SLICE_HEIGHT/2, r=OUTER_DIAMETER/2, center=true);
    translate([OUTER_DIAMETER/4, 0, 0])
      cylinder(h=SLICE_HEIGHT/2 + 2*E, r=OUTER_DIAMETER/2, center=true);
    translate([0, -OUTER_DIAMETER/2, 0])
      cube([OUTER_DIAMETER, OUTER_DIAMETER, SLICE_HEIGHT/2 + 2*E], center=true);
  }
}

module rotate_around(angle, offset) {
  translate(offset)
    rotate(a=angle, v=[0, 0, 1])
      translate(-offset)
        children(0);
}

// Repeats a child element steps times, rotating
// 360/steps degrees about the z axis each time.
module multiRotate(steps=8, from=8) {
  for (i = [0: steps - 1]) {
    rotate(a=360 * i / from, v=[0, 0, 1])
      children(0);
  }
}

module bottom_cap() {
  difference() {
    slice();
    slice_threads();
    translate([0, 0, -SLICE_HEIGHT/2 + WALL_THICKNESS])
      cylinder(h=SLICE_HEIGHT/2 - WALL_THICKNESS, r1=0, r2=INNER_DIAMETER/2);
    translate([0, 0, -SLICE_HEIGHT / 2 + WALL_THICKNESS])
      tea_light();
  }
}

module tea_light() {
  cylinder(h=LIGHT_HEIGHT, r=LIGHT_DIAMETER / 2);
  translate([0, 0, LIGHT_HEIGHT])
    cylinder(h=BULB_HEIGHT, r=BULB_DIAMETER / 2);
  rotate(a=WINDOW_ANGLE, v=[0, 0, 1])
    translate([WINDOW_RADIUS, 0, -WINDOW_HEIGHT / 2 + E])
      cube([WINDOW_WIDTH, WINDOW_LENGTH, WINDOW_HEIGHT], center=true);
  for (i = [0: 3]) {
      rotate(a=360 * i / 3, v=[0, 0, 1])
        translate([PIN_RADIUS, 0, -PIN_HEIGHT])
          cylinder(h=PIN_HEIGHT, r=PIN_DIAMETER / 2, $fs=0.5);
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
    rotate_extrude($fa=3, convexity=3)
      polygon(points=bevel_pts);
}


module slice_threads() {
  translate([0, 0, WALL_THICKNESS / 2 + AIR_GAP])
    trapezoidThreadNegativeSpace(length=THREAD_LENGTH + E,
                                 pitchRadius=INNER_DIAMETER/2,
                                 pitch=PITCH,
                                 clearance=THREAD_CLEARANCE
                                 );
}

module bottom_connector() {
  pos = CONNECTOR_LENGTH / 2 + WALL_THICKNESS / 2 + AIR_GAP +
    SLICE_GAP / 2 + SLICE_HEIGHT / 2;
  difference() {
    connector();
    translate([0, 0, -pos + WALL_THICKNESS])
      tea_light();
  }
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
    trapezoidThread(length=THREAD_LENGTH,
                    pitchRadius=INNER_DIAMETER / 2,
                    pitch=PITCH,
                    clearance=THREAD_CLEARANCE
                    );
}

// This adaptor mates the pump from a Neutrogena bottle to fit
// a smaller dispenser bottle.

E = 0.1;
// $fs = 3;
$fn = 40;

bottom_height = 10;

use <threads.scad>;

module upper_section() {
    outer_d = 23.7;
    pitch = 2.7;
    height = 30;
    thread_height = 10;
    thread_w = 1;

    inner_d = 17;

    difference() {
        union() {
            translate([0, 0, height - thread_height])
                metric_thread(outer_d, pitch, length=thread_height,
                    internal=false, leadin=1);
            cylinder(r=(outer_d-2*thread_w)/2, h=height);
        }
        translate([0, 0, bottom_height])
            cylinder(r=inner_d/2, h=height);
    }
};

module bottom_threads() {
    bottom_d = 21.0;
    pitch = 2.3;
    bottom_shaft_d = 13.6;

    metric_thread(bottom_d, pitch, length=bottom_height, internal=true);
    cylinder(r=bottom_shaft_d/2, h=bottom_height * 2);
}

module adaptor() {
    difference() {
        upper_section();
        translate([0, 0, -E])
            bottom_threads();
    }
};

adaptor();
// upper_section();
// bottom_threads();

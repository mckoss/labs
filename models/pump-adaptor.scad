// This adaptor mates the pump from a Neutrogena bottle to fit
// a smaller dispenser bottle.

E = 0.1;
// $fs = 3;
$fn = 40;

bottom_height = 7;

use <threads.scad>;

module upper_section(height=40) {
    outer_d = 23.5;
    pitch = 2.7;
    thread_height = 10;
    thread_w = 1;

    inner_d = outer_d - 2.9 * 2;

    difference() {
        union() {
            translate([0, 0, height - thread_height])
                metric_thread(outer_d, pitch, length=thread_height,
                    internal=false, leadin=2);
            cylinder(r=(outer_d-2*thread_w)/2, h=height - thread_height + E);
            cylinder(r1=27.4/2, r2=(outer_d-2*thread_w)/2, h=bottom_height - E);
        }
        translate([0, 0, -E])
            cylinder(r=inner_d/2, h=height + 2 * E);
    }
};

module bottom_section() {
    bottom_d = 21.4 + 2;
    pitch = 2.3;
    wall_thickness = 2;

    difference() {
        cylinder(r=bottom_d/2+wall_thickness, h=bottom_height);
        translate([0, 0, -E]) {
            metric_thread(bottom_d, pitch, length=bottom_height + 2*E,
                leadin=2, internal=true);
        }
    }
}

module adaptor() {
    translate([0, 0, bottom_height - E]) {
        upper_section();
    }
    bottom_section();
};

adaptor();
// upper_section(20);
// bottom_section();

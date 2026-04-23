// Dollar Drop Game
// A box with a lid containing 5 slots that catch a $1 coin edge-first,
// and one round hole that lets the coin fall through into the box.

use <chamfered-box.scad>
INCH = 25.4;
E = 0.1; // Epsilon for boolean operations
FIT = 0.25; // Gap for mating parts.

/* [Coin — US $1] */
coin_diameter  = INCH;
coin_thickness =  2;

/* [Slot fit] */
slot_thickness = coin_thickness + 1;

held_slot_y = cos(45) * coin_diameter;
open_slot_y = coin_diameter + 1;

/* [Engraving] */
engrave_depth = 1;
text_size = 6;
label_margin = 2;
label_font = "Arial:style=Bold";

box_interior_x = coin_diameter * 6;
box_interior_y = coin_diameter * 2.5;
box_interior_z = 80 / 6 / 2 * coin_thickness * 2 + coin_diameter;

wall_thickness = 4;
lid_thickness = 6;

box_y = box_interior_y + 2 * wall_thickness;
box_x = box_interior_x + 2 * wall_thickness;
box_z = box_interior_z + wall_thickness;

module slot(y=held_slot_y) {
    translate([y/2, 0, lid_thickness/2])
        cube([y, slot_thickness, lid_thickness + 2 * E], center=true);
}

module lid() {
  difference() {
    chamfered_box(box_x, box_y, lid_thickness, radius=2);
    slots();
    labels();

    translate([0, 0, -E])
        position_on_rect_sides([-box_x/2 + wall_thickness/2, -box_y/2 + wall_thickness/2,
                                box_x/2 - wall_thickness/2, box_y/2 - wall_thickness/2])
            fin_slot();
  }
}

// For box-lid alignment.
module fin() {
    chamfered_box(10, wall_thickness-2, lid_thickness/2, radius=1);
}

module fin_slot() {
    centered_cube([10, wall_thickness-2 + 2 * FIT, lid_thickness/2 + 2 * FIT]);
}

module engrave(s, size=text_size, halign="center", valign="center") {
    translate([0, 0, wall_thickness - engrave_depth])
        linear_extrude(z = engrave_depth + E)
            text(s, size = size, halign = halign, valign = valign,
                 font = label_font);
}

module labels() {
    total_for_gaps = box_x - 5 * held_slot_y;
    gap = total_for_gaps / 6;
    label_offset = slot_thickness/2 + text_size/2 + label_margin;

    // "1" - "5" above the catching slots
    for (i = [0:4]) {
        translate([-box_x/2 + gap + held_slot_y/2 + i * (held_slot_y + gap),
                   box_y/5 + label_offset, 0])
            engrave(str(i + 1));
    }

    // "6" above the drop slot
    translate([0, -box_y/5 + label_offset, 0])
        engrave("6");

    // "$" signs flanking the drop slot at jaunty angles
    dollar_x = open_slot_y/2 + text_size * 1.5;
    dollar_size = text_size * 1.5;
    translate([-dollar_x, -box_y/5, 0])
        rotate([0, 0, 20])
            engrave("$", size=dollar_size);
    translate([dollar_x, -box_y/5, 0])
        rotate([0, 0, -20])
            engrave("$", size=dollar_size);

    // Title in the lower-left, centered in the strip below the drop slot
    title_y = (-box_y/2 + (-box_y/5 - slot_thickness/2)) / 2;
    translate([-box_x/2 + 2 * label_margin, title_y, 0])
        engrave("Dollar Drop!", halign="left");

    // Signature in the lower-right, half the title size
    translate([box_x/2 - 2 * label_margin, title_y, 0])
        engrave("M. Koss - 2026", size=text_size/2, halign="right");
}

module slots() {
    // 5 coins across at top edge of lid
    total_for_gaps = box_x - 5 * held_slot_y;
    gap = total_for_gaps / 6;
    if (gap/2 < wall_thickness) {
        echo("Warning: gap from edge is less than wall thickness.\n");
    }
    for (i = [0:4]) {
        translate([-box_x / 2 + gap + i * (held_slot_y + gap), box_y/5, 0])
            slot();
    }

    // The drop slot is centered at the bottom edge of the lid
    translate([-open_slot_y/2, -box_y/5, 0])
        slot(open_slot_y);
}

module box() {
    difference() {
        centered_cube([box_x, box_y, box_z]);
        translate([0, 0, wall_thickness])
            centered_cube([box_interior_x, box_interior_y, box_interior_z + E]);
    }

    // Center alignment fins on top center of each of the 4 walls of the box.
    translate([0, 0, box_z])
        position_on_rect_sides([-box_x/2 + wall_thickness/2, -box_y/2 + wall_thickness/2,
                                box_x/2 - wall_thickness/2, box_y/2 - wall_thickness/2])
            fin();
}

// Rectangle around origin with base at z=0, centered in X and Y.
module centered_cube(box) {
    translate([0, 0, box.z/2])
        cube([box.x, box.y, box.z], center=true);
}

// Position and orient children at the center of each side of rect [x1, y1, x2, y2].
// rotation is applied to orient the children as bottom (0), right (90), top (180)
// left (270).
module position_on_rect_sides(rect) {
    x1 = rect[0];
    y1 = rect[1];
    x2 = rect[2];
    y2 = rect[3];

    positions = [[(x1 + x2)/2, y1], [x2, (y1 + y2)/2], [(x1 + x2)/2, y2], [x1, (y1 + y2)/2]];
    rotations = [0, 90, 180, 270];
    for (i = [0:3]) {
        translate([positions[i][0], positions[i][1], 0])
            rotate([0, 0, rotations[i]])
                children();
    }
}

lid();

translate([box_x*1.5, 0, 0])
    box();
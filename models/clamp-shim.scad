ANG = atan2(12, 40);

difference() {
    cylinder(h=25, r=22, $fa=4);
    # translate([0, 0, 27])
        rotate([0, ANG, 0])
        cube([100, 100, 25], center=true);
    # cylinder(h=8, r=20.5, $fa=4, center=true);
}
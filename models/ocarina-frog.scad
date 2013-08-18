/*
   Frog Ocarina - by Mike Koss (August, 2013)

   Based on Treefrog model by MorenaP: http://www.thingiverse.com/thing:18479
*/

E = 0.01;

PART = "test"; // [upper, lower, test]

module ocarina() {
  union () {
    difference() {
      frog_part(0);
      translate([0, 0, 8.5])
        rotate(a=-20, v=[1, 0, 0])
          pipes_negative(0);
    }
    //frog_part(1);
  }
}

module test() {
  difference() {
    cube([20, 38, 10], center=true);
    # pipes_negative(0);
  }
}

/* Due to bug in CGAL 4.2, we need to simplify the frog stl file
   before calculating the difference.  This function breaks
   up the frog part into upper and lower halves.

   openscad -o ocarina-frog.stl ocarina-frog.scad
   CGAL error: assertion violation!
   Expression : itl != it->second.end()
   File       : ../libraries/install/include/CGAL/Nef_3/SNC_external_structure.h
   Line       : 1102
   Explanation:
   Refer to the bug-reporting instructions at http://www.cgal.org/bug_report.html
   CGAL error in CGAL_Nef_polyhedron's difference operator: CGAL ERROR: assertion violation!
   Expr: itl != it->second.end()
   File: ../libraries/install/include/CGAL/Nef_3/SNC_external_structure.h
   Line: 1102
*/
SPLIT = 7;

module frog_part(part) {
  difference() {
    import("treefrog.stl");
    if (part == 0) {
      translate([0, 0, SPLIT - 30])
        cube([60, 60, 60], center=true);
    }
    if (part == 1) {
      translate([0, 0, SPLIT + 30 + E])
        cube([60, 60, 60], center=true);
    }
  }
}

module pipes_negative(part) {
  union() {
    scale([0.5, 1.2, 0.30])
       sphere(r=15, $fa=30);
    if (part == 0) {
      for (y = [-10 , -3 , 4, 11]) {
        translate([0, y, 0])
          cylinder(r=2, h=13, $fa=3, $fs=1);
      }
      rotate(a=83, v=[1, 0, 0])
        cylinder(r=1.5, h=30, $fa=3, $fs=1);
    }
  }
}

if (PART == "upper") ocarina();
if (PART == "lower") frog_part(1);
if (PART == "test") test();

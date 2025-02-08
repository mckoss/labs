$fn=10;

// Parameters
extrude_height = 15;   // Cutter height
wall_thickness = 0.5;  // Thickness of the cutting walls
base_thickness = 2;    // Base plate thickness
lattice_spacing = 8;   // Spacing between lattice holes
lattice_size = 6;      // Size of lattice holes

// Cookie Cutter Function
module cookie_cutter() {
    difference() {
        // Outer shape
        linear_extrude(height = extrude_height, convexity=2) {
            offset(delta = wall_thickness/2)  // Expand outline
            heart();
        }
        
        // Inner cutout
        translate([0, 0, -0.1])  // Small offset to prevent zero-thickness issues
        linear_extrude(height = extrude_height + 0.2, convexity=2, scale=1.) {
            offset(delta = -wall_thickness/2)  // Shrink outline
            heart();
        }
    }
}

// Lattice base function
module lattice_base() {
    difference() {
        // Base outline
        linear_extrude(height = base_thickness, convexity=2) {
            offset(delta = wall_thickness/2)  // Expand for stability
            heart();
        }

        // Lattice holes
        for (x = [-50: lattice_spacing : 50], y = [-50: lattice_spacing : 50]) {
            translate([x, y, -0.1])  // Offset slightly for robustness
            cylinder(h = base_thickness + 0.2, r = lattice_size / 2);
        }
    }
}

// Combine the cutter and lattice base
union() {
    cookie_cutter();
    lattice_base();
}

module heart() {
        import("heart-25.svg");
}
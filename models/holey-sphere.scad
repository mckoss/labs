// Parameters
R = 50;            // Outer radius of the sphere
THICKNESS = 2;     // Thickness of the shell
H = 8;            // Diameter of the holes
N = 200;          // Number of holes

SPHERE_RES = 20;
HOLE_RES = 12;

GOLDEN_ANGLE = 137.50776405; // Golden angle in degrees

module hollow_sphere_with_holes() {
    difference() {
        // Outer sphere
        sphere(R, $fn=SPHERE_RES);
        
        // Inner sphere to make it hollow
        sphere(R - THICKNESS, $fn=SPHERE_RES);
        
        // Add N cylindrical holes
        for (i = [0 : N - 1]) {
            // Spherical coordinates using golden angle
            theta = i * GOLDEN_ANGLE; // Azimuthal angle
            phi = acos(1 - 2 * (i + 0.5) / N); // Polar angle
                       
            // Place and orient cylinder perpendicular to the surface
            rotate([0, phi, theta]) // Rotate around Z-axis to match theta
                cylinder(h = R + THICKNESS, d = H, $fn = HOLE_RES);
        }
    }
}

// Render the sphere with holes
hollow_sphere_with_holes();

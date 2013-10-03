/* Experiments with helmholtz resonators.

   Equation for Helmholtz resonator frequency.
   http://en.wikipedia.org/wiki/Helmholtz_resonance

   f = c / (2 * pi) * sqrt(A/V/L)

   where:
      c = 340 m/s (speed of sound)
      A = total area of holes
      V = static volume
      L = length of blow hole

   f = 54,000 * sqrt(A/(VL));   - All units in mm.

   Example:

   A = 50 (mm2)
   V = 50 * 50 * 100 = 25000 mm3;
   L = 10 mm;
   f = 54,000 * sqrt(50 / 250,000) = 54,000 * 0.014 = 764 Hz
*/

// Sphere and cylinder precision
$fa = 3;
$fs = 1;

// Ratio of full sphere to print
TRUNCATE = 0.9;
SKIN = 1.0;

// Constants
PI = 3.141592654;

module helmholtz(p) {
  v = p[0];
  l = p[1];
  a = p[2];
  r = cap_radius(v, TRUNCATE);
  r_outer = r + SKIN;

  difference() {
    trunc_sphere(r_outer);
    translate([0, 0, SKIN])
      trunc_sphere(r);
    cube([200, 200, 200]);
  }
}

module trunc_sphere(r) {
  difference() {
    translate([0, 0, 2 * r * (TRUNCATE - 0.5)])
      sphere(r);
    translate([0, 0, -r])
      cube([2 * r, 2 * r, 2 * r], center=true);
  }
}

module grid_samples(samples, spacing=50) {
  count = len(samples);
  cols = ceil(sqrt(count));
  rows = ceil(count / cols);

  for (r = [0, rows - 1]) {
    for (c = [0, cols - 1]) assign(i = r * cols + c) {
      if (i < count) {
        translate([c * spacing, (rows - r - 1) * spacing, 0])
          helmholtz(samples[i]);
      }
    }
  }
}

/* Calculate radius of spherical cap of volume, v, and
   and percent of sphere, p (0 - 1).

   V = PI H^2 / 3 (3R - H)

   where H = 2R * P:

   V = 4 PI R^2 P^2 / 3 * (3R - 2R P)
     = 4 PI R^3 P^2 /  3 * (3 - 2 P)

   R = cube_root(3 V / (4 PI P^2 (3 - 2P))

   Note full sphere volume is 4/3 PI R^3
*/
function cap_radius(v, p) = pow(3 * v / (4 * PI * pow(p, 2) * (3 - 2 * p)), 1 / 3);

v_base = 20 * 20 * 20;
grid_samples([[v_base, 20, 30], [v_base / 4, 20, 30], [v_base * 4, 20, 30]]);

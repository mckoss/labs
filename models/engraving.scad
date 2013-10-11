/* Engraved letter forms.
   by Mike Koss
*/

E = 0.01;

module letter_a(height=20, line_width=3, width=0, depth=0) {
  real_depth = depth == 0 ? line_width / 2 : depth;
  real_width = width == 0 ? height : width;
  d = [line_width / 2, 0];

  // bottom left
  c1 = [-real_width / 2 + line_width / 2, 0];
  a1 = c1 - d;
  a2 = c1 + d;

  // top
  c2 = [0, height];
  a3 = c2 - d;
  a4 = c2 + d;

  // bottom right
  c3 = [real_width / 2 - line_width / 2, 0];
  a5 = c3 - d;
  a6 = c3 + d;

  // center left
  c_left = (2 * c1 + c2) / 3;
  v_left = line_width / 2 * unit(c2 - c1);
  a7 = c_left + v_left;
  a8 = c_left - v_left;

  // center right
  c_right = (2 * c3 + c2) / 3;
  v_right = line_width / 2 * unit(c2 - c3);
  a9 = c_right + v_right;
  a10 = c_right - v_right;

  cut(real_depth, [a1, a2, a4, a3]);
  cut(real_depth, [a5, a6, a4, a3]);
  cut(real_depth, [a7, a8, a10, a9]);
}

/*
     3---2
    /  5/
   /   /
  0---1
    4
*/
module cut(depth, top) {
  c1 = (top[0] + top[1]) / 2;
  c2 = (top[2] + top[3]) / 2;
  polyhedron(
    points=[level(top[0], E), level(top[1], E), level(top[2], E), level(top[3], E),
             level(c1, -depth), level(c2, -depth)],
    triangles=[
      [0, 1, 4], [2, 3, 5],
      [1, 2, 5], [1, 5, 4],
      [0, 5, 3], [0, 4, 5],
      [0, 3, 2], [0, 2, 1]
    ]
  );
}

function level(p, d) = [p[0], p[1], d];

function unit(v) = v / sqrt((v * v));

trials = [[20, 3, 0], [10, 2, 17],
          [5, 1, 26], [2.5, 0.6, 31]];
difference() {
  translate([-15, -3, -4]) cube([50, 25, 4]);
  for (i = [0: len(trials) - 1]) assign(p = trials[i]) {
    translate([p[2], 0, 0])
      letter_a(p[0], p[1]);
  }
}

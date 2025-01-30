// Inline dovetail joint
E = 0.1;
SLOT_EXTRA_HEIGHT = 0.2;

MIN_TAIL = 10;

// Tail oriented to the left centered at the base
module wedge(tail, base, depth, height) {
  linear_extrude(height)
    polygon([[0, base/2], [-depth, tail/2],
             [-depth, -tail/2], [0, -base/2]]);
}

// Equally spaced tabs fill an edge of length
// edge (vertical from [0, 0, 0]) s.t. E = N(T+B)
// where T is the max width of a tab and B
// is the base (or min width) of the tab.
// Use B = T / 2, so E = N * T * 3/2
// And, T = E / N * 2/3
// We also choose depth of tab equal to T.
module tabs(count, edge, height) {
  tail = edge / count * 2/3;
  base = tail / 2;
  spacing = tail + base;
  echo(tail, base, spacing);
  for (i=[0:count-1]) {
    translate([0, i * spacing + tail/2 + base/2, 0])
      wedge(tail, base, tail, height);
  }
}

// Choose a number of tabs to fill the edge equally,
// with a max tab width is at least min_tail.
// N = floor(E/((T+B)) 
module auto_tabs(min_tail, edge, height) {
  count = floor(edge / (min_tail * 3/2));
  tabs(count, edge, height);
}

module add_tabs_left(edge, height) {
  translate([E, 0, 0])
    auto_tabs(MIN_TAIL, edge, height);
}

module sub_slots_left(edge, height) {
  difference() {
    children();
    translate([E, 0, -E])
      auto_tabs(MIN_TAIL, edge, height + E + SLOT_EXTRA_HEIGHT);
  }
}

// Subtracts tabs from the right edge of a child
// of the given width.
module sub_slots_right(edge, width, height) {
  translate([width, 0, 0])
  difference() {
    translate([-width, 0, 0])
        children();
    translate([E, 0, -E])
      auto_tabs(MIN_TAIL, edge, height + E + SLOT_EXTRA_HEIGHT);
  }
}

translate([20, 0, 0]) {
  add_tabs_left(50, 2);
  sub_slots_right(50, 50, 2)
    cube([50, 50, 3]);
}

sub_slots_left(50, 2) {
  translate([-50, 0, 0])
    cube([50, 50, 3]);
}

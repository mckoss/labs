SEP = 40;
union() {
  for (i = [1 : 25]) {
    translate([SEP * floor((i - 1) / 5), SEP * ((i - 1) % 5), 0]) import(str("m94-", i, ".stl"));
  }
};

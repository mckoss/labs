SEP = 40;
START = 1;
union() {
  for (i = [0 : 15]) {
    if (i + START <= 25) {
      translate([SEP * floor(i / 4), SEP * (i % 4), 0]) import(str("m94-", i + START, ".stl"));
    }
  }
};

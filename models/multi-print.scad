SEP = 40;
ROWS = 3;
COLUMNS = 5;
GROUPSIZE = ROWS * COLUMNS;
GROUP = 1;
START = (GROUP - 1) * GROUPSIZE + 1;
union() {
  for (i = [0 : GROUPSIZE - 1]) {
    if (i + START <= 25) {
      translate([SEP * floor(i / ROWS), SEP * (i % ROWS), 0]) import(str("m94-", i + START, ".stl"));
    }
  }
};

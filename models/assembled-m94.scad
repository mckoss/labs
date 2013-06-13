// Show an assembled m-94 using all the individual parts rendered
// to stl files.
H = 3.53;

ORDER = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
         14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25];

for (i = [0 : len(ORDER) - 1]) {
    translate([(H + 0.1) * i, 0, 0]) rotate(a=-90, v=[0, 1, 0]) import(str("m94-", i, ".stl"));
};

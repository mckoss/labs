use <spiff.scad>;
use <chrome.scad>;

DEPTH = 5;
PART = "yellow"; // [red, yellow, green, blue]

module red() {
  difference() {
    wedge(part=0);
    scale([0.6, 1, 0.6])
      emboss("CHROME", width=40);
  }
}

module yellow() {
  difference() {
    wedge(part=1);
    rotate(a=-120, v=[0, 0, 1])
      translate([2, 0, 0])
        scale([0.6, 1, 0.6])
          emboss("SUMMIT", width=45);
  }
}

module green() {
  difference() {
    wedge(part=2);
    rotate(a=120, v=[0, 0, 1])
       emboss("2013", width=27);
  }
}

module emboss(text, width) {
  translate([14, 15, -width / 2])
  rotate(a=90, v=[0, 0, 1])
    rotate(a=-90, v=[0, 1, 0])
    linear_extrude(DEPTH)
      write(text);
}

if (PART == "red") red();
if (PART == "yellow") yellow();
if (PART == "green") rotate(a=-120, v=[0, 0, 1]) green();
if (PART == "blue") cap();

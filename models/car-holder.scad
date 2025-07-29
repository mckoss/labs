WALL = 1.5;
INCH = 25.4;
E = 0.1;

CAR_LENGTH = 3 * INCH;
CAR_WIDTH = 1.5 * INCH;
CAR_HEIGHT = 1.5 * INCH;

PIN_DIAMETER = 7;
PIN_GAP = 0.5;
PIN_HEIGHT = 7;
PIN_SOCKET_WALL = 2;

USE_KNOCKOUTS = true;

$fn = 30;

ROWS = 5;
COLUMNS = 2;

module car() {
  difference() {
    cube([CAR_LENGTH + 2 * WALL, CAR_WIDTH + 2 * WALL, CAR_HEIGHT + WALL]);
    translate([WALL, WALL, WALL + E])
      car_slot();
  }
}

module car_slot() {
  cube([CAR_LENGTH, CAR_WIDTH, CAR_HEIGHT]);
}

module tray() {
  dx = CAR_LENGTH + WALL;
  dy = CAR_WIDTH + WALL;
  for (y = [0:dy:(ROWS-1)*dy]) {
    for (x = [0:dx:(COLUMNS-1)*dx]) {
      translate([x, y, 0])
        car();
    }
  }
}

module pin(r, h) {
  cylinder(h=h - r, r=r);
  translate([0, 0, h - r])
    sphere(r);
}

module corner() {
  translate([0, 0, CAR_HEIGHT + WALL])
    pin(PIN_DIAMETER / 2, PIN_HEIGHT);
  
  cylinder(h=PIN_HEIGHT + PIN_GAP, r=PIN_DIAMETER/2 + PIN_SOCKET_WALL + PIN_GAP);
  translate([0, 0, PIN_HEIGHT + PIN_GAP])
    cylinder(h=WALL + CAR_HEIGHT - PIN_HEIGHT - PIN_GAP, r1=PIN_DIAMETER/2 + PIN_SOCKET_WALL + PIN_GAP, r2=PIN_DIAMETER/2);
}

module socket() {
  pin(PIN_DIAMETER / 2 + PIN_GAP, PIN_HEIGHT + PIN_GAP);
}

module whole_tray() {
  dx = COLUMNS * (CAR_LENGTH  + WALL);
  dy = ROWS * (CAR_WIDTH + WALL);
  difference() {
    union() {
      tray();
      translate([WALL/2, WALL/2, 0])
        corner();
      translate([dx + WALL/2, WALL/2, 0])
        corner();
      translate([dx + WALL/2, dy + WALL/2, 0])
        corner();
      translate([WALL/2, dy + WALL/2, 0])
        corner();
    }
    union() {
      translate([WALL/2, WALL/2, -E])
        socket();
      translate([dx + WALL/2, WALL/2, -E])
        socket();
      translate([dx + WALL/2, dy + WALL/2, -E])
        socket();
      translate([WALL/2, dy + WALL/2, -E])
        socket();
      if (USE_KNOCKOUTS)
        knock_outs();
    }
  }
}

module knock_outs() {
  dx = CAR_LENGTH + WALL;
  dy = CAR_WIDTH + WALL;
  translate([WALL + CAR_LENGTH/2, WALL, WALL + E])
    car_slot();
  translate([WALL + dx, WALL + dy * 2 + CAR_WIDTH/2, WALL + E])
    car_slot();
  translate([WALL + CAR_LENGTH/2, WALL + 4 * dy, WALL + E])
    car_slot();
}

whole_tray();



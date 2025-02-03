// ZZ's Cupholder

BLOCK_SIZE = 10;
ARM_WIDTH = 40;
ARM_CENTER = 20;
ARM_RADIUS = 11;
WING_ARMS = 30;

WING_WIDTH = (ARM_WIDTH - ARM_CENTER)/2;

CUP_R1 = 93/2;
CUP_R2 = 72/2;
CUP_H = 80;

THICKNESS = 3;

$fn = 50;

E = 0.1;

// rotate([0, 0, 45])

cube([BLOCK_SIZE, BLOCK_SIZE, ARM_WIDTH], center=true);
wing();
translate([0, 0, -ARM_WIDTH+BLOCK_SIZE])
    wing();

module wing() {
    difference() {
        translate([BLOCK_SIZE/2, -BLOCK_SIZE/2, ARM_WIDTH/2-BLOCK_SIZE/2])
            cube([BLOCK_SIZE * 2, BLOCK_SIZE, WING_WIDTH], center=true);
        translate([ARM_RADIUS + BLOCK_SIZE/2, 0, 0])
          cylinder(ARM_WIDTH + E, r=ARM_RADIUS, center=true);
    }
    translate([BLOCK_SIZE, -BLOCK_SIZE, ARM_WIDTH/2-BLOCK_SIZE/2])
        cube([WING_ARMS, 3, WING_WIDTH], center=true);
}

rotate([0, 0, 45])
translate([0, -CUP_H/2+BLOCK_SIZE*1.4/2, ARM_WIDTH/2 + CUP_R1 + BLOCK_SIZE/2])
    cup_holder();

module cup_holder() {
    rotate([90, 0, 0])
    difference() {
        union() {
            cylinder(CUP_H, r1=CUP_R1, r2=CUP_R2, center=true);
            translate([0, -CUP_R1/2, -CUP_H/2+BLOCK_SIZE*1.4/2])
                cube([CUP_R1*2-BLOCK_SIZE, CUP_R1+BLOCK_SIZE, BLOCK_SIZE*1.4], center=true);
        }
        translate([0, 0, -THICKNESS])
            cylinder(CUP_H+E, r1=CUP_R1-THICKNESS, r2=CUP_R2-THICKNESS, center=true);
        cylinder(CUP_H*2, r=20, center=true);
    }
}
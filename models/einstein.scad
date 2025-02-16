// Einstein Tiles

// Which colors to print.
COLOR_FILTER = "all"; // ["all", "blue", "red"]

TGRID = 20;
THICKNESS = 3;

/* [Hidden] */

P0 = [0, 0];
P1 = [TGRID, 0];
P2 = rot(60) * P1;
P3 = (P0 + P1 + P2) / 3;

function rot(a) = [[cos(a), -sin(a)], [sin(a), cos(a)]];
function add(poly, o) = [for (p=poly) p + o];

kite = [P0, P1/2, P3, P2/2];
ks = [for (i=[0:5]) kite*rot(-60*i)];
    
//for (k = ks) polygon(k);
    
parts = [ks[0], ks[1], ks[4], ks[5],
         add(ks[1], P1), add(ks[2], P1),
         add(ks[3], P2), add(ks[4], P2)
        ];

color_part("blue")
    linear_extrude(THICKNESS/2) {
        for (p=parts) polygon(p);
    }
color_part("red")
    translate([0, 0, THICKNESS/2])
    linear_extrude(THICKNESS/2) {
        for (p=parts) polygon(p);   
    }    


// Need to be able to conditionally render parts based on color (for
// export to Bambu Studio for slicing.
module color_part(c) {
    if (COLOR_FILTER == "all" || c == COLOR_FILTER) {
        color(c) children();
    }
}


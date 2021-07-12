// Dodecahedron - https://en.wikipedia.org/wiki/Platonic_solid
// http://dmccooey.com/polyhedra/Dodecahedron.txt

PHI = (1 + sqrt(5))/2;

SCALE = 25;
WIRE_D = 8;


// 12 * 5 / 3 = 20 vertices
VERTICES = [
 for (a = [-1, 1]) for (b = [-1, 1]) for (c = [-1, 1]) [a, b, c],
 for (a = [-1/PHI, 1/PHI]) for (b = [-PHI, PHI])
     each [[0, a, b], [a, b, 0], [b, 0, a]]
];
 
EDGES = [
 [0, 8],
 [0, 9],
 [0, 10],
 [1, 9],
 [1, 11],
 [1, 16],
 [2, 10],
 [2, 12],
 [2, 14],
 [3, 12],
 [3, 16],
 [3, 17],
 [4, 8],
 [4, 13],
 [4, 15],
 [5, 11],
 [5, 15],
 [5, 19],
 [6, 13],
 [6, 14],
 [6, 18],
 [7, 17],
 [7, 18],
 [7, 19],
 [8, 14],
 [9, 15],
 [10, 16],
 [11, 17],
 [12, 18],
 [13, 19]];


module label_plot(v) {
    for (i = [0:19]) {
        let (label = str(floor(i/10), (i % 10))) {
        translate(VERTICES[i] * SCALE)
            rotate([90, 0, 0])
                text(label, 8);
        }
    }
}

// label_plot(VERTICES);

module build_edge(e) {
    v1 = VERTICES[e[0]] * SCALE;
    v2 = VERTICES[e[1]] * SCALE;
    echo(v1, v2);
    cyl_between(v1, v2, WIRE_D / 2);
}

module build_edges() {
    for (e = EDGES) {
        build_edge(e);
    }
    for (v = VERTICES) {
        translate(v * SCALE)
            sphere(d = WIRE_D * 1.5, $fs=1, $fa=5);
    }
}

// https://stackoverflow.com/questions/50869080/openscad-how-to-draw-a-cylinder-from-vector-to-vector
function transpose(A) = [for (j = [0:len(A[0])-1]) [for(i = [0:len(A)-1]) A[i][j]]];

module cyl_between(P, Q, r){
    v = Q - P;    
    L = norm(v);  
    c = v / L;    
    is_c_vertical = ( 1 - abs(c * [0, 0, 1]) < 1e-6); 
    u = is_c_vertical ? [1, 0, 0] : cross([0, 0, 1], c); 
    a = u / norm(u); 
    b = cross(c, a);     
    MT = [a, b, c, P]; 
    M = transpose(MT); 
    multmatrix(M) cylinder(h=L, r=r, $fs=1);
}

rotate([0, 31, 0])
    build_edges();
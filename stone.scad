
use <HexUtils.scad>
use <voronoi/voronoi.scad>

module stones(hex_size) {
    randoms = rands(-3,3,2*2*4*4);
    points = [for (i=[1:4]) for(j=[1:4]) [i*5+randoms[(i*4+j)*2],j*5+randoms[(i*4+j)*2+1]]];
    echo(points=points);
    all_points = concat(points, points+[20,0], points+[20,20], points+[0,20]);
    echo(all_points=all_points);
    _dx = dx(hex_size);
    _dy = dy(hex_size);
    hexagon = [[0,2*_dy],[_dx,_dy],[_dx,-_dy],[0,-2*_dy],[-_dx,-_dy],[-_dx,_dy]];
    spacing = 0.5;

    linear_extrude(height=0.5) {
        voronoi(all_points, L=20, thickness=spacing, round=0.1, nuclei=false);
    }
}

stones(25.4);
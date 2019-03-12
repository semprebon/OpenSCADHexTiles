/*
 An encounter on the edges of a gorge
*/

include <HexTiles.scad>;

use <utils/build_plate.scad>
build_plate(3, 220, 220);uild_plate_selector=3;

P = STONE_PATH;
R = STONE_ROUGH;

module rocky_path_rise() {
    semi_hex_tile(size=3, tile_data=[
              [4,R],[1,P],[0,P],
           [3,P],[2,P],[2,R],[0,P],
        [4,P],[6,R],[4,P],[5,R],[4,R],
        ]);
}

module cliff_path_base() {
    semi_hex_tile(size=3, tile_data=[
              [4,R],[0,P],[4,R],
           [1,P],[1,P],[1,R],[1,P],
        [0,P],[2,R],[0,P],[1,P],[2,R],
        ]);
}

module rocky_stairs() {
    hex_tile(size=2, tile_data=[
              [6,P],[7,P],
           [5,P],[0,P],[1,P],
              [4,P],[2,P],
        ]);
}

module rocky_clearing() {
    hex_tile(size=3, tile_data=[
              [0,P],[0,P],[1,R],
           [1,R],[0,P],[0,P],[0,P],
        [1,R],[1,P],[0,P],[1,P],[1,R],
           [1,P],[0,P],[0,P],[0,P],
              [1,R],[0,P],[1,R],
        ]);
}

module test() {
    semi_hex_tile(size=2, tile_data=[
           [4,P],[3,R],
        [5,P],[6,R],[2,P],
           [0,P],[1,R],
        ]);
}


module cliff_edge() {
}

//cliff_path_base();
//translate([8*dx,6*dy,0]) rotate([0,0,180]) rocky_path_rise();
//translate([7*dx,15*dy,5*dz]) rocky_clearing();
rocky_stairs();
//test();
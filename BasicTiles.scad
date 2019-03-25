/*
 An encounter on the edges of a gorge
*/

include <HexTiles.scad>

use <utils/build_plate.scad>
//build_plate(3, 220, 220);


module cap_piece(texture) {
    intersection() {
        linear_extrude(height=100) hex_shape(hex_size-2*tolerance);
        hex_tile(1, [[1, texture]]);
    }
}

module board(texture) {
    rect_tile([8,4], [[0,texture]]);
//    rect_tile([4,4], texture);
}

arrange_parts(220) {
    board(WATER);
}
//cap_piece(STONE_PATH);
//translate([-2.5*hex_size, -dy*10, 0]) rect_tile([6,8], [[0,GRASS]]);

//hex_tile(1, [[0,BRUSH]]);
//hex_tile(1, [[0,SUPPORT]]);
//translate([1,0,2.4]) scale([1.1,1.1,1.1]) import("textures/vines.stl");

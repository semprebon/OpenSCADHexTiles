/*
 An encounter on the edges of a gorge
*/

include <HexTiles.scad>;

use <utils/build_plate.scad>
build_plate(3, 220, 220);uild_plate_selector=3;

module cap(texture) {
    hex_tile(1, [[1,texture]]);
}

module board(size, texture) {
    hex_tile(size, [[0,texture]]);
}

cap(STONE_PATH);
translate([2.5*hex_size, 0, 0]) hex_tile(2, STONE_PATH);
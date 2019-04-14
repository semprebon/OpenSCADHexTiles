/*
 An encounter on the edges of a gorge
*/

include <HexTiles.scad>
//use <utils/build_plate.scad>
//build_plate(3, 220, 220);

// Type of tile
type = "semi_hex";      // [hex,trapezoid,rectangle,triangle]
x_size = 1;             // [0:6]
y_size = 1;             // [0:6]
terrain = "support";    // [stones,wood,grass,rocks,vines,water,support,flat]
height = 6;             // [0:6]

P = STONE;
R = ROCK;
N = NONE;
S = SUPPORT;

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

function terrain(terrain) =
    (terrain == "support") ? SUPPORT
        : (terrain == "flat") ? FLAT
        : [str(terrain, ".stl")];

arrange_parts(220) {
    echo(height=height, tt=terrain, terrain=terrain(terrain));
    render_tile(type, [x_size, y_size], [[height,terrain(terrain)]]);
}


module h_3x3x6_support() {
    render_tile(TILE_TYPE_HEX, [3,3], [
              [6,S],[6,S],[6,S],
           [6,S],[6,N],[6,N],[6,S],
        [6,S],[6,N],[6,N],[6,N],[6,S],
           [6,S],[6,N],[6,N],[6,S],
              [6,S],[6,S],[6,S]]);
}

module h_3x3x6_support2() {
    render_tile(TILE_TYPE_HEX, [3,3], [
              [6,S],[6,S],[6,S],
           [6,S],[6,S],[6,S],[6,S],
        [6,S],[6,S],[6,S],[6,S],[6,S],
           [6,S],[6,S],[6,S],[6,S],
              [6,S],[6,S],[6,S]]);
}


module xy_rise() {
    semi_hex_tile(size=3, tile_data=[
              [3,P],[2,P],[1,P],
           [4,P],[3,P],[2,P],[1,P],
        [5,P],[5,P],[5,P],[5,P],[5,P]]);
}

module xy_rise_2() {
    semi_hex_tile(size=3, tile_data=[
              [3,P],[2,P],[1,P],
           [4,P],[3,P],[2,P],[1,P],
        [5,P],[4,P],[3,P],[2,P],[1,P]]);
}

module y_rise() {
    semi_hex_tile(size=3, tile_data=[
              [3,P],[3,P],[3,P],
           [2,P],[2,P],[2,P],[2,P],
        [1,P],[1,P],[1,P],[1,P],[1,P]]);
}

module spiral() {
    hex_tile(size=2, tile_data=[
              [6,P],[7,P],
           [5,P],[1,P],[2,P],
              [4,P],[3,P]]);
}

//xy_rise_2();

//cap_piece(STONE_PATH);
//translate([-2.5*hex_size, -dy*10, 0]) rect_tile([6,8], [[0,GRASS]]);

//hex_tile(1, [[1,BRUSH]]);
//hex_tile(1, [[0,SUPPORT]]);
//translate([1,0,2.4]) scale([1.1,1.1,1.1]) import("textures/vines.stl");

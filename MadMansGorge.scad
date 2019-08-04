/*
 An encounter on the edges of a gorge - an example of how to create more complex tiles
*/

include <HexTiles.scad>;

use <utils/build_plate.scad>
build_plate(3, 220, 220);uild_plate_selector=3;

// Part
part = "stairs"; // [rocky_rise,cliff_base,stairs,rocky_clearing,rocky_path,stone_clearing,xy_rise,y_rise]
parts = [part];

P = STONE;
R = ROCKS;

/*
s-3x3-xy_rise x 1
h-1x1x1-rocks x 4
*/
module rocky_rise() {
    semi_hex_tile(size=3, tile_data=[
              [4,R],[1,P],[0,P],
           [3,P],[2,P],[2,R],[0,P],
        [4,P],[6,R],[4,P],[5,R],[4,R]]);
}

module xy_rise() {
    semi_hex_tile(size=3, tile_data=[
              [3,P],[2,P],[1,P],
           [4,P],[3,P],[2,P],[1,P],
        [5,P],[5,P],[5,P],[5,P],[5,P]]);
}

/*
s-3x3-sy-rise x 1
h-1x1x1-stone x 7
r-1x1x1-rocks x 7
*/
module cliff_base() {
    semi_hex_tile(size=3, tile_data=[
              [4,R],[0,P],[4,R],
           [1,P],[1,P],[1,R],[1,P],
        [0,P],[2,R],[0,P],[1,P],[2,R]]);
}
module y_rise() {
    semi_hex_tile(size=3, tile_data=[
              [3,P],[3,P],[3,P],
           [2,P],[2,P],[2,P],[2,P],
        [1,P],[1,P],[1,P],[1,P],[1,P]]);
}

/*
h-2x2-stone-stairs x 1
*/
module stairs() {
    hex_tile(size=2, tile_data=[
              [5,P],[6,P],
           [4,P],[0,NONE],[1,P],
              [3,P],[2,P]]);
}
/*
h-3x3x7-support x 1
h-3x3x1-stone x 1
r-2x1x1-stone x 2
r-2x1x1-rocks x 1
h-1x1x1-rocks x 4
*/
module rocky_clearing() {
    hex_tile(size=3, tile_data=[
              [0,P],[0,P],[1,R],
           [1,R],[0,P],[0,P],[0,P],
        [1,R],[1,P],[0,P],[1,P],[1,R],
           [1,P],[0,P],[0,P],[0,P],
              [1,R],[0,P],[1,R]]);
}

/*
s-3x3x1
*/
module rocky_path() {
    semi_hex_tile(size=3, tile_data=[
              [3,R],[0,P],[3,R],
           [1,P],[0,P],[0,P],[1,P],
        [0,P],[3,R],[2,R],[1,P],[3,R]]);
}

/*
h-3x3x1
*/
module stone_clearing() {
    hex_tile(size=3, tile_data=[
              [0,P],[0,P],[0,P],
           [0,P],[0,P],[0,P],[0,P],
        [0,P],[0,P],[0,P],[0,P],[0,P],
           [0,P],[0,P],[0,P],[0,P],
              [0,P],[0,P],[0,P]]);
}

module render_part(part, height) {
    if (part == "rocky_rise") rocky_rise2();
    if (part == "cliff_base") cliff_base2();
    if (part == "stairs") stairs();
    if (part == "rocky_clearing") rocky_clearing();
    if (part == "rocky_path") rocky_path();
    if (part == "stone_clearing") stone_clearing();
    if (part == "xy_rise") xy_rise();
    if (part == "y_rise") y_rise();

module render_parts(parts) {
    for (part = parts) {
        render_part(part);
    }
}

render_parts(parts);

//cliff_path_base();
//translate([8*dx,6*dy,0]) rotate([0,0,180]) rocky_path_rise();
//translate([7*dx,15*dy,5*dz]) rocky_clearing();
//rocky_stairs();
//test();
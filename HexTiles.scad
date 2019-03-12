// HexTile generator in OpenSCAD
//
// Hexes are referenced by axial coordinates (see https://www.redblobgames.com/grids/hexagons/)
// the x axis gets the pointy ends of the hex, while y is flat

use <MCAD/triangles.scad>
use <HexUtils.scad>

hex_size = 25.4;
base_thickness = 3.0;
level_thickness = 6;

tileShape = "hex";
tileSize = 1;

wall_width = 1.6;
tolerance = 0.4;
grid_line_width = 1.6 + tolerance;
grid_line_depth = 1.2;

pattern_height = 1.0;
pattern_size = 64;

STONE_PATH = ["stones", 64, 0.01];
STONE_ROUGH = ["stones", 64, 0.06];
GRASS_PATH = ["grass_64s", 64, 0.04];
SUPPORT = ["support", 0, 0];

SPECIAL_TEXTURES = [SUPPORT[0]];

dx = dx(hex_size);
dy = dy(hex_size);
dz = level_thickness;

top_size = hex_size-sqrt(3)*grid_line_width/2;


module textureTile(height, tile=[], position) {
    if (tile != []) {
        level = tile[0];
        surface_image = tile[1][0];
        pattern_size = tile[1][1];
        pattern_height = tile[1][2];
        xyScale = 2*hex_size/pattern_size;
        image_offset = [0,0]; //[position.x % pattern_size, position.y % pattern_size];
        translate([0,0,height]) intersection() {
            linear_extrude(height=100) hex_shape(top_size);
            translate(-image_offset/2) scale([xyScale, xyScale, pattern_height])
            surface(file=str("textures/", surface_image, ".png"), center=true);
        }
    }
}

module hex_strut(height) {
    supportLength = hex_size*2 - 2*grid_line_width/sqrt(3)+0.1;
    translate([0,0,height-hex_size/2]) rotate([0,0,0]) cube([grid_line_width, supportLength, hex_size], center=true);
}

module hex_support(height) {
    translate([0,0,height]) {
        for (i = [0:5]) {
            rotate([0,0,60*i]) {
                translate([hex_size*sqrt(3)/2-grid_line_width/2,0,0]) rotate([0,90,90]) translate([0,0,-hex_size/2]) {
                    triangle(grid_line_width, grid_line_width, hex_size);
                }
            }
        }
        difference() {
            linear_extrude(height=grid_line_depth) hex_shape(top_size);
            translate([0,0,-0.1]) linear_extrude(height=grid_line_depth+0.2) hex_shape(top_size-grid_line_width);
        }
    }
}
/*
 Generate a single hex
*/
module hex(grid_position=[0,0], tile=[]) {
    level = tile[0];
    height = base_thickness + level_thickness * level;
    top_size = hex_size-sqrt(3)*grid_line_width/2;
    position = axial_to_xy(grid_position, hex_size);
    translate(position) {
        difference() {
            linear_extrude(height=height-grid_line_depth) hex_shape(hex_size);
            translate([0,0,-0.01]) linear_extrude(height=height-grid_line_depth+0.02) hex_shape(top_size+tolerance);
        }
        if (tile[1] == SUPPORT) {
            hex_support(height-grid_line_depth);
        } else {
             translate([0,0,height-grid_line_depth]) linear_extrude(height=grid_line_depth) hex_shape(top_size);
             textureTile(height=height, tile=tile, top_size=top_size, position=position);
        }
    }
}

function distance(a, b) =
    (abs(a.x -b.x) + abs(a.x + a.y - b.x - b.y) + abs(a.y - b.y)) / 2;

function rangeForCol(size, col) =
    let (
        start = -(size-1),
        end = (size+col)/2)
    [start:end];


module hex_tile(size, tile_data) {
    for (i = range_from(hexes_per_megahex(size))) {
        hex(grid_position=hex_offset_to_axial(size, i), tile=tile_data[i % len(tile_data)]);
    }
}

module semi_hex_tile(size, tile_data) {
    middle_row_count = 2*size - 1;
    hex_count = (hexes_per_megahex(size) + middle_row_count) / 2;
    for (i = range_from(hex_count)) {
        hex(grid_position=hex_offset_to_axial(size, i), tile=tile_data[i % len(tile_data)]);
    }
}

/*
 Generate a rectangular tile of the given size
*/
module rect_tile(size, tile_data) {
    for (i = range_from(size.x * size.y)) {
        hex(grid_position=rectangle_offset_to_axial(size, i), tile=tile_data[i % len(tile_data)]);
    }
}

//textures = [
//    [5, SUPPORT],
//    []
//hex_tile(size=2, tileData=[[1,STONE_PATH]]);
//for (i = [0:(len(textures)-1)]) {
//    echo(texture=textures[i]);
//    translate([i*2*dx,0,0]) hex_tile(size=1, tileData=[textures[i]]);
//}
//rect_tile(size=[3,4], tile_data=[[1,STONE_PATH],[2,STONE_PATH]]);
//    [],[],[3,[]],[3,[]],[3,[]],
//    [], [3,[]],[3,STONE_PATH],[3,[]],[2,[]],
//    [5,[]],[5,[]],[5,[]],[5,[]],[5,[]]]);

//semiHexTile(size=3, tileData=[
//    [],[],[3,STONE_PATH],[3,STONE_ROUGH],[3,STONE_ROUGH],
//    [], [3,STONE_PATH],[3,STONE_PATH],[3,STONE_PATH],[2,STONE_PATH],
//    [5,STONE_ROUGH],[5,STONE_PATH],[5,STONE_PATH],[5,STONE_ROUGH],[5,STONE_ROUGH]]);

//surface(file="stones.png", center=true);
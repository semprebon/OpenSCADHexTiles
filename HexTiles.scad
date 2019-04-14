/*
 HexTile generator in OpenSCAD

 Hexes are referenced by axial coordinates (see https://www.redblobgames.com/grids/hexagons/)
 the x axis gets the pointy ends of the hex, while y is flat

 TODO: option to render parts without texture for fast testing
*/

use <MCAD/triangles.scad>
include <HexUtils.scad>

hex_size = 25.4;
base_thickness = 1.6;
level_thickness = 6;

wall_thickness = 1.6;
tolerance = 0.3;
grid_line_width = wall_thickness;
grid_line_depth = 0.8;

pattern_height = 1.0;
pattern_size = 64;

fudge = 0.003;

GRAVEL = ["gravel.stl", 128, 1];
GRASS = ["grass.stl"];
ROCK = ["rock.stl"];
STONE = ["stone.stl"];
VINE = ["vine.stl"];
WATER = ["water.stl"];
WOOD = ["wood.stl"];

SUPPORT = ["support", 0, 0];
FLAT = [];
NONE = ["none"];

SPECIAL_TEXTURES = [SUPPORT[0]];

dx = dx(hex_size);
dy = dy(hex_size);
dz = level_thickness;

hollow_size = hex_size - 2*wall_thickness;
top_size = hollow_size - 2*tolerance;

function ends_with(s, s2) =
    let(
        offset = len(s2)-len(s),
        suffix = [for (i = [0:(len(s)-1)]) (s2[offset+i] == s[i]) ? 1 : 0])
    min(suffix) == 1;

function is_file_type(type, filename) =
    ends_with(str(".", type), filename);

/* Terrain Offsets */
TERRAIN_FILE = 0;
TERRAIN_IMAGE_CROP = 1;
TERRAIN_IMAGE_Z_HEIGHT = 2;

/* Hex Data Offsets */
HEX_POSITION = 0;   // Axial coordinates of hex
HEX_LEVEL = 1;      // height of hex, in abstract coordinates
HEX_TERRAIN = 2;    // Terrain object

function hex_data(position, descriptor) = [position, descriptor[0], descriptor[1]];

function hex_height(hex_data) = level_thickness * hex_data[HEX_LEVEL];

/* Offsets ino tile object */
TILE_SHAPE = 0; // "hex", "semi_hex", or "rect
TILE_SIZE = 1; // [x,y] size of tile
TILE_HEXES = 2; //

/* Tile geometries */
TILE_SHAPE_HEXAGON = "hexagon";
TILE_SHAPE_TRAPEZOID = "trapezoid";
TILE_SHAPE_RECTANGLE = "rectangle";
// TODO: implement parallelogram tiles

/*
 Create a specified shape and size of tile from texture information
*/
function create_tile(shape, size, data) =
    let(
        positions = (shape == TILE_SHAPE_HEXAGON) ? hex_positions(size)
            : (shape == TILE_SHAPE_TRAPEZOID) ? trapezoid_positions(size)
            : (shape == TILE_SHAPE_RECTANGLE) ? rect_positions(size)
            : (shape == "triangle") ? trapezoid_positions(1, (size.x == undef) ? size: size.x, 1)
            : ["error"],
        hexes = [for (i = range(len(positions)))
                    hex_data(position=positions[i], descriptor = data[i % len(data)])])
    [shape, size,  hexes];

/*
 Return the hex data for a given hex position
*/
function hex_at_position(tile, position) =
    let (
        offset = search([position], tile[TILE_HEXES], 1, HEX_POSITION)[0])
    tile[TILE_HEXES][offset];

function is_hex_inner_wall(tile, hex_data, dir) =
    hex_at_position(tile, hex_data[HEX_POSITION] + STEP_FOR_DIRECTION[dir]) != undef;

function max_level(tile) = max([for (i=range(tile[TILE_HEXES])) tile[TILE_HEXES][i][HEX_LEVEL]]);

function is_empty_hex(tile, i) = tile[TILE_HEXES][i][HEX_TERRAIN] == NONE;

function is_support_tile(tile) =
    let(supports = [ for (hex = tile[TILE_HEXES]) if (hex[HEX_TERRAIN] == SUPPORT) hex[HEX_LEVEL] ])
    (len(supports) == len(tile[TILE_HEXES]) && (max(supports) == min(supports)));
     
/*
 Generate the textured top of a hex from an image
*/
module top_texture(terrain) {
    if (terrain != []) {
        surface_image = terrain[TERRAIN_FILE];
        pattern_size = terrain[TERRAIN_IMAGE_CROP];
        pattern_height = terrain[TERRAIN_IMAGE_Z_HEIGHT];
        xyScale = 2*hex_size/pattern_size;
        image_offset = [0,0]; //[position.x % pattern_size, position.y % pattern_size];
        union() {
            if (surface_image != undef) {
                intersection() {
                    linear_extrude(height=level_thickness) hex_shape(top_size);
                    translate([-image_offset/2,0]) scale([xyScale, xyScale, pattern_height/100])
                        surface(file=str("textures/", surface_image, ".png"), center=true);
                }
            }
        }
    }
}

/*
 Import the textured top of a hex from from an stl file
*/
module surface_geometry(terrain) {
    if (terrain != []) {
        object_file = terrain[TERRAIN_FILE];
        import(str("textures/", object_file), convexity=5);
    }
}

/*
 Create the shape of an opening for using less material on inner walls, while 
 not requiring support.
*/
module opening(tile, hex_data, dir) {
    other_pos = hex_data[HEX_POSITION] + STEP_FOR_DIRECTION[dir];
    height = min(hex_height(hex_data), hex_height(hex_at_position(tile, other_pos)));
    opening_height = height - 2.5*wall_thickness;
    translate([hex_size/2-wall_thickness/2,0,opening_height/2+1*wall_thickness]) {
        cube([wall_thickness+2*fudge, hex_size/2 - 2*wall_thickness, opening_height], center=true);
    }
}

/*
 Create the hollow support for higher hexes.

 This consists of a hollow hexagonal prism of the correct outer size, a hollow
 interior, walls that are wall-width thick. At the top end, the walls widen to
 support the cap and texture in a way that can be printed (usually) without support
 using bridging.

 tile - tile data
 hex_data - hex data
 support_width - extra width provided at top to support cap. This should be less
    than the height (or the wall at the bottom will be too thick to allow stacking),
    but large enough so that the filament can bridge the top.

*/
module render_support(tile, hex_data, support_width=0) {
    height = hex_height(hex_data);

    // support angles in at 45 degree overhang
    if (support_width > 0) {
        translate([0,0,height]) {
            for (dir = range(6)) {
                rotate([0,0,ANGLES_FOR_DIRECTION[dir]]) {
                    translate([dx-wall_thickness/2-support_width/2,0,0]) rotate([0,90,90]) translate([0,0,-dy]) {
                        triangle(support_width, support_width, 2*dy);
                    }
                }
            }
        }
    }
    // outside wall
    difference() {
        linear_extrude(height=height) beveled_hex_shape(hex_size);
        for (dir = range(6)) {
            if (is_hex_inner_wall(tile, hex_data, dir)) {
                rotate(ANGLES_FOR_DIRECTION[dir]) opening(tile, hex_data, dir);
            }
        }
        translate([0,0,-fudge]) linear_extrude(height=height+2*fudge) {
            hex_shape(hollow_size);
        }
    }
}

/*
  Generate the tile cap that joins the texture to the support
*/
module cap(thickness,hollow=false) {
    if (hollow) {
        difference() {
            linear_extrude(height=thickness) beveled_hex_shape(hex_size);
            linear_extrude(height=thickness) hex_shape(top_size);
        }
    } else {
        linear_extrude(height=thickness) beveled_hex_shape(hex_size);
    }
}

/*
 Generate a single hex

 tile - tile data [type,size,hexes]
 index - index of hex to render
*/
module render_hex(tile, index) {
    hex_data = tile[TILE_HEXES][index];
    level = hex_data[HEX_LEVEL];
    terrain = hex_data[HEX_TERRAIN];
    height = level_thickness * level;
    position = axial_to_xy(hex_data[HEX_POSITION], hex_size);

    translate(position) {
        if (level > 0) {
            //render_support(tile, hex_data, support_width=grid_line_width);
            render_support(tile, hex_data, support_width=wall_thickness);
        }

        if (terrain == SUPPORT) {
            translate([0,0,height-fudge]) linear_extrude(height=grid_line_depth+fudge) {
                difference() { hex_shape(top_size); hex_shape(top_size-2*wall_thickness+tolerance); }
            }
        } else {
            translate([0,0,height-fudge]) {
                cap(thickness=base_thickness+2*fudge, hollow=(terrain == SUPPORT));
            }
            translate([0,0,height+base_thickness]) linear_extrude(height=grid_line_depth+fudge) {
                hex_shape(top_size);
            }
            translate([0,0,height+base_thickness+grid_line_depth]) {
                if (is_file_type("stl", terrain[0])) {
                    surface_geometry(hex_data[HEX_TERRAIN]);
                } else {
                    top_texture(hex_data[HEX_TERRAIN]);
                }
            }
        }
    }
}

/*
 Generates a 2d outline of the whole tile
*/
module tile_outline(tile) {
    hexes = tile[TILE_HEXES];
    union() {
        for (i = range(hexes)) {
            if (!is_empty_hex(tile, i)) translate(axial_to_xy(hexes[i][HEX_POSITION], hex_size)) hex_shape(hex_size);
        }
    }
}

/*
 Generates the entire tile
 */
module render_tile(shape, size, tile_data) {
    tile = create_tile(shape=shape, size=size, data=tile_data);
    difference() {
        intersection() {
                for (i = range(tile[TILE_HEXES])) {
                    if (!is_empty_hex(tile, i)) {
                        render_hex(tile, i);
                    }
                }
                max_height = max([for (i=range(tile_data)) tile_data[0]]);
                linear_extrude(max_height) offset(delta=1.5*tolerance) tile_outline(tile);
        }
        if (is_support_tile(tile)) {
            offset = grid_line_width + wall_thickness;
            echo(offset=offset);
            linear_extrude(z = (max_level(tile) + 2)*level_thickness) offset(r=-offset)
                offset(delta=fudge, chamfer=true) tile_outline(tile);
        }
    }
}

module arrange_parts(distance) {
    parts_per_side = ceil(sqrt($children));
    separation = distance / parts_per_side;
    translate(-distance/2, distance/2) {
        for (i = [0:1:$children-1]) {
            translate([(i % parts_per_side)*separation, floor(i/parts_per_side)*separation]) children(i);
        }
    }
}

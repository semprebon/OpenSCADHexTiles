// Basic computations and shapes for working with hexes
// see https://www.redblobgames.com/grids/hexagons/ for detailed description
//
// Hexes are referenced by axial coordinates (row is normal, col is tilted by 60 dergees)
//  /\/\
// | | |
//  \/\/

default_hex_size = 25.4;
default_side = default_hex_size / sqrt(3); // for hexes that fit an inscribed circle (or miniature base) of 1"

q_basis = [0,1]; // horizontal unit vector
r_basis = [1,1]; // diagonal unit vector

function default(value, default) = (value == undef) ? default : value;
function range(v) = [0:(len(v)-1)];
function is_odd(x) = (x % 2) != 0;
function is_even(x) = [x % 2] == 0;

/*
 Convert axial coordinates to cubic
*/
function axial_to_cubic(axial) = [axial.x, -axial.x - axial.y, axial.y];

/*
 Convert cubic to axial
*/
function cubic_to_axial(cubic) = [cubic.x, cubic.z];

/*
 half-step in x and y directions
*/
function dx(size=default_hex_size) = 0.5 * size;
function dy(size=default_hex_size) = 0.5 * size / sqrt(3);

/*
 compute side length for a given hex size
*/
function size_to_side(size) = size / sqrt(3);

/*
 compute hex size or a given side length
*/
function side_to_size(side) = side * sqrt(3);

/*
 Distance between two axial points
 */
function axial_distance(a, b) =
    (abs(a.x -b.x) + abs(a.x + a.y - b.x - b.y) + abs(a.y - b.y)) / 2;

/*
 Convert axial hex coordinates to cartesian coordinates
*/
function axial_to_xy(axial, size) = [dx(size) * (2*axial.x + axial.y), dy(size) * 3 * axial.y, 0];

/*
 Create a 2d hex with center at the origin
*/
module hex_shape(size) {
    _dx = dx(size);
    _dy = dy(size);
    polygon([[0,2*_dy],[_dx,_dy],[_dx,-_dy],[0,-2*_dy],[-_dx,-_dy],[-_dx,_dy]]);
}

/*
 Create a 3d hexagonal prism/truncated pyramid with center at the origin
*/
module hex_prism(height, size, size1, size2, center) {
    _size1 = (size1 != undef) ? size1 : default(size, default_hex_size);
    _size2 = (size2 != undef) ? size2 : default(size, default_hex_size);
    linear_extrude(height=height, center=default(center,false), scale=_size2/_size1) {
        hex_shape(_size1);
    }
}


function hexes_per_megahex(size) = 3*size*size - 3*size + 1;
function tri(n) = n*(n+1) / 2;
function range_from(size) =
    let(
        actual_size = (size[0] == undef) ? size : len(size))
    [0:(actual_size-1)];

/*
 Returns the ordinal value of the start of a row for a hex tile of the specified size
 For a hex of size 2:
    row  2:     16  17  18        offset = 16
    row  1:   12  13  14  15      offset = 12     5 6
    row  0: 07  08  09  10  11    offset =  7    2 3 4
    row -1:   03  04  05  06      offset =  3     0 1
    row -2:     00  01  02        offset =  0
*/
function hex_row_offset(size, row) =
    (row < size)
        ? tri(2*size + row-2) - tri(size-1)
        : hexes_per_megahex(size) - tri(2*size - row) + tri(size-1);

/*
 Returns the row for a given offset, with the center row being row 0
*/
function hex_offset_to_row(size, offset) =
    (offset > hexes_per_megahex(size) / 2)
        ? -hex_offset_to_row(size, hexes_per_megahex(size) - offset - 1)
        : (offset < size)
            ? 1-size
            : 2 + hex_offset_to_row(size + 1, offset - size);

/*
 Returns the column for a given offset, with the center hex as column 0
 size=3 offset=3
    size=4, offset=0 => 0-4+1 => -3
*/
function hex_offset_to_column(size, offset) =
    (offset > hexes_per_megahex(size) / 2)
        ? -hex_offset_to_column(size, hexes_per_megahex(size) - offset - 1)
        : (offset < size)
            ? offset
            : hex_offset_to_column(size + 1, offset - size) - 1;

/*
 Returns the axial coodinates of a given hex offset value, assuming the center hex is 0,0
*/
function hex_offset_to_axial(size, offset) =
    let (
        row = -hex_offset_to_row(size, offset),
        col = hex_offset_to_column(size, offset) - row
    )
    [col, row];


/*
 Returns the axial coordinates of a given rectangular offset value/ Assumes 0,0 is offset 0 at lower left
*/
function rectangle_offset_to_axial(size, offset) =
    let(
        x = offset % size.x,
        y = (offset - x) / size.x)
    [x - (y + (is_odd(y) ? 1 : 0)) / 2, y];

function is_in_rect_tile(size, pos) =
    (0 <= pos.x) && (pos.x < size.x) && (0 <= pos.y) && (pos.y < size.y);

function is_in_hex_tile(size, pos) = axial_distance([0, 0], pos) < size;

function is_in_semi_hex_tile(size, pos) = is_in_hex_tile(size, pos) && pos.y >= 0;

DIRECTIONS = ["NE", "E", "SE", "SW", "W", "NW"];
ANGLES_FOR_DIRECTION = [ 0, 60, 120, 180, 240, 300 ];
STEP_FOR_DIRECTION = [ [1,0], [1,-1], [0,-1], [-1,0], [-1,1], [0,1] ];

// convert a direction symbol into a unit vector
//function step(dir) =
//    (dir == "E") ? [1,0]
//        : (dir == "SE") ? [1,-1]
//        : (dir == "SW") ? [0,-1]
//        : (dir == "W") ? [-1,0]
//        : (dir == "NW") ? [-1,1]
//        : dir == "NE") ? [0,1]
//        : [];


function hex_positions(size) =
    [for (i = range_from(hexes_per_megahex(size))) hex_offset_to_axial(size, i)];

function rect_positions(size) =
    [for (i = range_from(size.x * size.y)) rectangle_offset_to_axial(size, i)];

function semi_hex_positions(size) =
    let(
        middle_row_count = 2*size - 1,
        hex_count = (hexes_per_megahex(size) + middle_row_count) / 2)
    [for (i = range_from(hex_count)) hex_offset_to_axial(size, i)];

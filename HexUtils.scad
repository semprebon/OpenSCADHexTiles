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

module beveled_hex_shape(size) {
    bevel_width = 0.5;
    _dx = dx(size-bevel_width);
    _dy = dy(size-bevel_width);
    offset(r=bevel_width/2, chamfer=true) {
        polygon([[0,2*_dy],[_dx,_dy],[_dx,-_dy],[0,-2*_dy],[-_dx,-_dy],[-_dx,_dy]]);
    }
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


function hexes_per_megahex(size) =
    let(
        _size = (size[0] == undef) ? [size, size] : size,
        small = min(_size), large = max(_size))
    3*small*small - 3*small + 1 + (large-small)*small;

function tri(n) = n*(n+1) / 2;

function range_from(size) =
    let(
        actual_size = (size[0] == undef) ? size : len(size))
    [0:(actual_size-1)];


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

// Direction 
ANGLES_FOR_DIRECTION = [ 0, 60, 120, 180, 240, 300 ];
STEP_FOR_DIRECTION = [ [1,0], [0,1], [-1,1], [-1,0], [0,-1], [1,-1] ];

function shift(positions, offset) =
    [ for (p = positions) p + offset ];

function invert_rows(positions) =
    let(
        ys = [for (p = positions) p.y],
        row_span = max(ys) - min(ys),
        first_row = [for (p = positions) if (p.y == positions[0].y) p],
        remaining_rows = [for (p = positions) if (p.y != positions[0].y) p])
    (len(remaining_rows) == 0)
        ? first_row
        : concat(
            shift(invert_rows(remaining_rows), [0,1]),
            shift(first_row, [row_span, -row_span]));

function hexes_per_row(size) =
    [for (i = [size.y-1:-1:0]) (size.x + size.y - 1) - i];

function x_range(count) =
    let(start = -floor(count/2))
    [start:(start+count-1)];

/*
 Returns an array of axial (row,col) coordinates in a hexagon pattern of the
 given size. For example, hex_position(3,2):
              <--- 3 ---->
      /     0,1   1,1   2,1
    2 -  0,0   1,0   2,0   3,0
            1,-1  2,-1  3,-1
*/
function hex_positions(size) =
    let (_size = (size[0] == undef) ? [size, size] : size)
    concat(trapezoid_positions(_size),
        (_size.y == 1) ? [] : shift(invert_rows(trapezoid_positions([_size.x, _size.y-1])), [1,1-_size.y]));

/*
 Returns an array of axial (row,col) coordinates in a rectangle pattern of the
 given size. For example, rectangle_position(3,2):
              <--- 3 ---->
      /     0,1   1,1   2,1   3,1
    2 -  0,0   1,0   2,0   3,0
*/
function rect_positions(size) =
    let (_size = (size[0] == undef) ? [size, size] : size)
    [for (i = range_from(size.x * size.y)) rectangle_offset_to_axial(size, i)];

/*
 Returns an array of axial (row,col) coordinates in a trapezoid pattern of the
 given size. For example, trapezoid_position(3,2):
              <--- 3 ---->
      /     0,1   1,1   2,1
    2 -  0,0   1,0   2,0   3,0

    Note: size.x=1 will result in a triangle
*/
function trapezoid_positions(size) =
    let (
        _size = (size[0] == undef) ? [size, size] : size,
        y_max = _size.y - 1,
        counts = hexes_per_row(_size))
    [for (j = [0:y_max]) for (i = range_from(counts[j])) [i, y_max-j] ];


function semi_hex_positions(size) = trapezoid_positions(size);

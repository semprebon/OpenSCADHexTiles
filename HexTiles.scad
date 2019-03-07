// HexTile generator in OpenSCAD
//
// Hexes are referenced by axial coordinates (see https://www.redblobgames.com/grids/hexagons/)
// the x axis gets the pointy ends of the hex, while y is flat

hexSize = 25.4 / sqrt(3);
base_thickness = 3.0;
level_thickness = 6;

tileShape = "hex";
tileSize = 1;

tolerance = 0.4;
grid_line_width = 1.2+tolerance;
grid_line_depth = 1.2;

pattern_height = 1.0;
pattern_size = 64;

STONE_PATH = ["stones", 64, 0.01];
STONE_ROUGH = ["stones", 64, 0.06];
GRASS_PATH = ["grass_64s", 64, 0.04];
SUPPORT = ["support", 0, 0];

SPECIAL_TEXTURES = [SUPPORT[0]];

/*     
 for uor purposes, the x axis goes across the short diagonal, and the y axis
 along the long diagonal
*/
dx = 0.5 * sqrt(3) * hexSize;
dy = 0.5 * hexSize;
q_basis = [0,1]; // horizontal unit vector
r_basis = [1,1]; // diagonal unit vector

module hexShape(size=hexSize) {
    _dx = 0.5 * sqrt(3) * size;
    _dy = 0.5 * size;
    polygon([[0,2*_dy],[_dx,_dy],[_dx,-_dy],[0,-2*_dy],[-_dx,-_dy],[-_dx,_dy]]);
}

module textureTile(height, tile=[], position) {
    if (tile != []) {
        level = tile[0];
        surface_image = tile[1][0];
        pattern_size = tile[1][1];
        pattern_height = tile[1][2];
        xyScale = 2*hexSize/pattern_size;
        image_offset = [0,0]; //[position.x % pattern_size, position.y % pattern_size];
        translate([0,0,height]) intersection() {
            linear_extrude(height=100) hexShape(top_size);
            translate(-image_offset/2) scale([xyScale, xyScale, pattern_height])
            surface(file=str(surface_image, ".png"), center=true);
        }
    }
}

/*
 Generate a single hex
*/
module hex(gridPosition=[0,0], tile=[]) {
    level = tile[0];
    height = base_thickness + level_thickness * level;
    top_size = hexSize-sqrt(3)*grid_line_width/2;
    position = axialToXY(gridPosition);
    translate(position) {
        difference() {
            union() {
                linear_extrude(height=height-grid_line_depth) hexShape(hexSize);
                linear_extrude(height=height) hexShape(top_size);
                textureTile(height=height, tile=tile, top_size=top_size, position=position);
            }
            linear_extrude(height=height-2*grid_line_depth) hexShape(top_size+tolerance);
        }
    }
}

function offsetColumn(col) = (col % 2) != 0;

function offsetColumnOffset(col) = offsetColumn(col) ? -dy : 0;

function axialToXY(axial) =
    [dx * (2*axial.y + axial.x), dy * 3 * axial.x, 0];

function axialToCubic(axial) =
    [axial.x, -axial.x - axial.y, axial.y];

function cubicToAxial(cubic) =
    [cubic.x, cubic.z];

function dataOffset(size, axial) = size.x * axial.y + axial.x;

function distance(a, b) =
    (abs(a.x -b.x) + abs(a.x + a.y - b.x - b.y) + abs(a.y - b.y)) / 2;

function rangeForCol(size, col) =
    let (
        start = -(size-1),
        end = (size+col)/2)
    [start:end];


module hexTile(size, tileData) {
    dataSize = [2*size-1, 2*size-1];
    center = [size-1, size-1];
    for (row = [0:(dataSize.y-1)]) {
        for (col = [0:(dataSize.x-1)]) {
            axial = [col,row];
            if  (distance(center, axial) <= size-1) {
                hex(gridPosition=axial, tile=tileData[dataOffset(dataSize, axial) % len(tileData)]);
            }
        }
    }
}

module semiHexTile(size, tileData) {
    dataSize = [2*size-1, size];
    center = [size-1, size-1];
    for (row = [0:(dataSize.y-1)]) {
        for (col = [0:(dataSize.x-1)]) {
            axial = [col,row];
            if  (distance(center, axial) <= size-1) {
                hex(gridPosition=axial, tile=tileData[dataOffset(dataSize, axial) % len(tileData)]);
            }
        }
    }
}

/*
 Generate a rectangular tile of the given size
*/
module rectTile(size, tileData) {
    for (row = [0:size.y-1]) {
        for (col = [0:size.x-1]) {
            translate(positionOnGrid([col, row]))
                hex(level=tileData[row*size.x + col % len(tileData)], surface_image="wood");
        }
    }
}

//textures = [
//    [5, SUPPORT],
//    []
hexTile(size=3, tileData=[[5,STONE_ROUGH]]);
//for (i = [0:(len(textures)-1)]) {
//    echo(texture=textures[i]);
//    translate([i*2*dx,0,0]) hexTile(size=1, tileData=[textures[i]]);
//}
//semiHexTile(size=3, tileData=[
//    [],[],[3,[]],[3,[]],[3,[]],
//    [], [3,[]],[3,STONE_PATH],[3,[]],[2,[]],
//    [5,[]],[5,[]],[5,[]],[5,[]],[5,[]]]);

//semiHexTile(size=3, tileData=[
//    [],[],[3,STONE_PATH],[3,STONE_ROUGH],[3,STONE_ROUGH],
//    [], [3,STONE_PATH],[3,STONE_PATH],[3,STONE_PATH],[2,STONE_PATH],
//    [5,STONE_ROUGH],[5,STONE_PATH],[5,STONE_PATH],[5,STONE_ROUGH],[5,STONE_ROUGH]]);

//surface(file="stones.png", center=true);
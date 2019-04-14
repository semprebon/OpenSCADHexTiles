/*
  Convert images to surfaces for export and simplification for use as hex top textures
*/

include <HexTiles.scad>

module texture(terrain) {
    union() {
        linear_extrude(height=grid_line_depth+fudge) hex_shape(top_size);
        translate([0,0,grid_line_depth]) top_texture(terrain=terrain);
    }
}

texture(["gravel", 200 , 3]);
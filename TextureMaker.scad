/*
  Convert images to surfaces for export and simplification for use as hex top textures
*/

include <HexTiles.scad>

module texture(tile) {
    top_texture(height=0, tile=tile, position=0);
}

texture([0,["grass", 128, 1, 0.005]]);
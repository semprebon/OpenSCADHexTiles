#!/usr/bin/env bash

# Regenerate all the standard tile models (needs more documentation)
# Warning: this can take a long time (hours) to run. Comment out sections to run in smaller batches

# Tile naming convention:
#  <geometry>-<size>-<terrain>.stl
#
# Where:
#  * <geometry> is one of:
#     * h - a hexagon
#     * t - a trapezoid
#     * r - a rectangle
# * <size> is the size of the tile, <length>x<width>x<height>
# * <terrain> is the terrain used, currently this includes stone, wood, gravel, grass, rock, vine, water, and flat

# Smaller 1x1, 1x2, 1x3, and 1x4 tiles you can use to build up terrain features.

for T in stone wood gravel grass rock vine water flat
do
    F=tiles/h-1x1x1-${T}.stl
    echo FILE=$F
    OpenSCAD -o $F -D type=\"hexagon\" -D x_size=1 -D y_size=1 -D terrain=\"$T\" -D height=1 BasicTiles.scad

    for W in 2 3 4
    do
        F=tiles/h-${W}x1x1-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"rectangle\" -D x_size=$W -D y_size=1 -D terrain=\"$T\" -D height=1 BasicTiles.scad

        F=tiles/t-${W}x2x1-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"rectangle\" -D x_size=$W -D y_size=2 -D terrain=\"$T\" -D height=1 BasicTiles.scad
    done

done

# A set of larger tiles of each geometry. These can be used on risers as the base for higher terrain

for T in stone wood flat
do
    #for W in 2 3
    for W in 3
    do
        F=tiles/h-${W}x${W}x1-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"hexagon\" -D x_size=$W -D y_size=$W -D terrain=\"$T\" -D height=1 BasicTiles.scad

        F=tiles/t-${W}x${W}x1-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"trapezoid\" -D x_size=$W -D y_size=$W -D terrain=\"$T\" -D height=1 BasicTiles.scad

        F=tiles/r-${W}x${W}x1-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"rectangle\" -D x_size=$W -D y_size=$W -D terrain=\"$T\" -D height=1 BasicTiles.scad
    done

done

# A set of large (3-5 hexes per side) 0-height hexes suitable as base tiles. If your printer can
# handle bigger tiles than my Ender-3, you might want to do even bigger hexes.

for T in stone wood flat water
do
    for W in 3 4 5
    do
        F=tiles/h-${W}x${W}x0-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"hexagon\" -D x_size=$W -D y_size=$W -D terrain=\"$T\" -D height=0 BasicTiles.scad
    done

done
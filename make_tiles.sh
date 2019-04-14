#bin/bash

# Regenerate all the standard tile models

for T in stone wood gravel grass rock vine water flat support
do
    F=tiles/h-1x1x1-${T}.stl
    echo FILE=$F
    OpenSCAD -o $F -D type=\"hex\" -D x_size=1 -D y_size=1 -D terrain=\"$T\" -D height=1 BasicTiles.scad

    for W in 2 3
    do
        F=tiles/h-${W}x${W}x1-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"hex\" -D x_size=$W -D y_size=$W -D terrain=\"$T\" -D height=1 BasicTiles.scad

        F=tiles/t-${W}x${W}x1-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"trapezoid\" -D x_size=$W -D y_size=$W -D terrain=\"$T\" -D height=1 BasicTiles.scad

        F=tiles/r-${W}x${W}x1-${T}.stl
        echo FILE=$F
        OpenSCAD -o $F -D type=\"rectangle\" -D x_size=$W -D y_size=$W -D terrain=\"$T\" -D height=1 BasicTiles.scad
    done

done
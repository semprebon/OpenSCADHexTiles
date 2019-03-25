include <HexTiles.scad>
use <TestSupport.scad>

// Which test part to print
part = "all"; // [tolerance_test, texture_test, support_test, all]

assert_equals(false, ends_with(".stl", "vine.png"), "ends_with with non-matching");
assert_equals(true, ends_with(".stl", "vine.stl"), "ends_with with matching");
assert_equals(true, is_file_type("stl", "vine.stl"), "is_file_type for matching file");
assert_equals(false, is_file_type("stl", "vine.png"), "is_file_type for nonmatching file");
assert_equals(false, is_file_type("stl", "vstl.png"), "is_file_type for nonmatching file");

test_tile = create_tile(type="hex", size=2, data=[
        [0,FLAT],[1,FLAT],
    [5,FLAT],[6,FLAT],[2,FLAT],
        [4,FLAT],[3,FLAT]]);
assert_equals([[0,0],6,FLAT], hex_at_position(test_tile, [0,0]), "hex_at_position for [0,0]");
assert_equals(undef, hex_at_position(test_tile, [1,1]), "hex_at_position for [1,1]");

module tolerance_test() {
    arrange_parts(70) {
        render_tile("hex", 1, [[1,FLAT]]);
        render_tile("rect", [2,1], [[1,FLAT]]);
        render_tile("semi_hex", 2, [[0,FLAT]]);
    }
}

module texture_test() {
    rect_tile([3,3], [
        [0,WATER],[0,DIRT],[0,STONE],
        [0,GRASS],[0,WOOD],[0,ROCKS],
        [0,DEBRIS],[0,BRUSH],[0,FLAT]]);
}

module support_test() {
    rect_tile([1,2],[[3,SUPPORT]]);
}

module all() {
    arrange_parts(200) {
        tolerance_test();
        texture_test();
        support_test();
    }
}

if (part == "tolerance_test") {
    tolerance_test();
} else if (part == "texture_test") {
    texture_test();
} else if (part == "support_test") {
    support_test();
} else if (part == "all") {
    all();
} else {
    echo("\n*** Unknown part specified!", part, "***\n");
}
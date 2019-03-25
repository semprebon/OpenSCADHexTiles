include <HexUtils.scad>

module assert_equals(expected, actual, tag) {
    if (expected != actual) {
        echo(str("Assert Failed! ", (tag != undef)
            ? str(tag, ": ", actual, " expected to be ", expected)
            : str(actual, " expected to be ", expected)));
    }
}

module test_hex_offset_to_axial() {
    tag = "hex_offset_to_axial";
    assert_equals([0,0], hex_offset_to_axial(1, 0), tag);

    assert_equals([-2,2], hex_offset_to_axial(3, 0), tag);
    assert_equals([0,2], hex_offset_to_axial(3, 2), tag);
    assert_equals([-2,1], hex_offset_to_axial(3,3), tag);
    assert_equals([2,0], hex_offset_to_axial(3,11), tag);
    assert_equals([2,-1], hex_offset_to_axial(3,15), tag);
    assert_equals([2,-2], hex_offset_to_axial(3,18), tag);
}


module test_rectangle_offset_to_axial() {
    tag = "rectangle_offset_to_axial";
    //assert_equals([0,0], rectangle_offset_to_axial([1,1] 0), tag);

    assert_equals([0,0], rectangle_offset_to_axial([3,3], 0), tag);
    assert_equals([2,0], rectangle_offset_to_axial([3,3], 2), tag);
    assert_equals([-1,1], rectangle_offset_to_axial([3,3], 3), tag);
    assert_equals([-1,2], rectangle_offset_to_axial([3,3], 6), tag);
}

module test_is_in_rect_tile() {
    tag = "is_in_rect_tile";
    assert_equals(true, is_in_rect_tile([1,2], [0,0]), tag);
    assert_equals(true, is_in_rect_tile([1,2], [0,1]), tag);
    assert_equals(false, is_in_rect_tile([1,2], [-1,0]), tag);
    assert_equals(false, is_in_rect_tile([1,2], [1,0]), tag);
    assert_equals(false, is_in_rect_tile([1,2], [0,2]), tag);
    assert_equals(false, is_in_rect_tile([1,2], [0,-1]), tag);
}

module test_is_in_hex_tile() {
    tag = "is_in_hex_tile";
    assert_equals(true, is_in_hex_tile(2, [0,0]), tag);
    assert_equals(true, is_in_hex_tile(2, [0,1]), tag);
    assert_equals(true, is_in_hex_tile(2, [-1,1]), tag);
    assert_equals(true, is_in_hex_tile(2, [1,-1]), tag);
    assert_equals(false, is_in_hex_tile(2, [2,-2]), tag);
    assert_equals(false, is_in_hex_tile(2, [1,1]), tag);
    assert_equals(false, is_in_hex_tile(2, [-1,-1]), tag);
}

module test_is_in_semi_hex_tile() {
    tag = "is_in_semi_hex_tile";
    assert_equals(true, is_in_semi_hex_tile(2, [0,0]), tag);
    assert_equals(true, is_in_semi_hex_tile(2, [0,1]), tag);
    assert_equals(true, is_in_semi_hex_tile(2, [-1,1]), tag);
    assert_equals(false, is_in_semi_hex_tile(2, [1,-1]), tag);
    assert_equals(false, is_in_semi_hex_tile(2, [2,-2]), tag);
    assert_equals(false, is_in_semi_hex_tile(2, [1,1]), tag);
    assert_equals(false, is_in_semi_hex_tile(2, [-1,-1]), tag);
}

module test_hex_positions() {
    tag = "hex_positions: ";
    assert_equals([[0,0]], hex_positions(1), tag + "size 1");

}

module test_all() {
    test_hex_offset_to_axial();
    test_rectangle_offset_to_axial();
    test_is_in_rect_tile();
    test_is_in_hex_tile();
    test_is_in_semi_hex_tile();
    test_hex_positions();
}

test_all();


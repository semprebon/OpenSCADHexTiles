include <HexUtils.scad>
include <TestSupport.scad>

module test_hexes_per_row() {
    tag = "hex_per_row";

    assert_equals([1], hexes_per_row([1,1]), tag);
    assert_equals([2,3], hexes_per_row([2,2]), tag);
}

module test_hex_offset_to_axial() {
    tag = "hex_offset_to_axial";
    assert_equals([0,0], hex_offset_to_axial([1,1], 0), tag);

    assert_equals([-2,2], hex_offset_to_axial([3,3], 0), tag);
    assert_equals([0,2], hex_offset_to_axial(3, 2), tag);
    assert_equals([-2,1], hex_offset_to_axial(3,3), tag);
    assert_equals([2,0], hex_offset_to_axial(3,11), tag);
    assert_equals([2,-1], hex_offset_to_axial(3,15), tag);
    assert_equals([2,-2], hex_offset_to_axial(3,18), tag);

    assert_equals([-2,1], hex_offset_to_axial([3,2],0), tag);
    assert_equals([1,1], hex_offset_to_axial([3,2],3), tag);
    assert_equals([-1,-1], hex_offset_to_axial([3,2],9), tag);
    assert_equals([2,-1], hex_offset_to_axial([3,2],12), tag);

    assert_equals([-2,1], hex_offset_to_axial([3,2],0), tag);
    assert_equals([1,1], hex_offset_to_axial([3,2],3), tag);
    assert_equals([-1,-1], hex_offset_to_axial([3,2],9), tag);
    assert_equals([2,-1], hex_offset_to_axial([3,2],12), tag);
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

module test_x_range() {
    tag = "hex_range: ";
    assert_equals([0], [for (i=[0:0]) i], tag, "check");
    assert_equals([0:0], x_range(1), tag, "count=1");
    assert_equals([-1:0], x_range(2), tag, "count=2");
    assert_equals([-1:1], x_range(3), tag, "count=3");
}

module test_hex_positions() {
    tag = "hex_positions: ";
    assert_equals([[0,0]], hex_positions(1), tag, "size=1");
    assert_equals([[0,0]], hex_positions([1,1]), tag, "size=[1,1]");
    assert_equals([[0,1],
                [0,0],[1,0],
                   [1,-1]], hex_positions([1,2]), tag, "size=[1,2]");
    assert_equals([[0,1],[1,1],
                [0,0],[1,0],[2,0],
                   [1,-1],[2,-1]], hex_positions(2), tag, "size=2");
}

module test_invert_rows() {
    tag = "invert_rows: ";
    assert_equals([[0,0],[1,0],[2,0]], invert_rows(trapezoid_positions([3,1])), tag, "single_row");
    assert_equals([[0,1],[1,1], [1,0]], invert_rows(trapezoid_positions([1,2])), tag, "triangle(2)");
    assert_equals([[0,2],[1,2],[2,2], [1,1],[2,1], [2,0]],
            invert_rows(trapezoid_positions([1,3])), tag, "triangle(3)");
}

module test_trapezoid_positions() {
    tag = "trapezoid_positions: ";
    assert_equals([[0,0]], trapezoid_positions(1), tag, "size=1");
    assert_equals([[0,1],[1,1],[2,1], [0,0],[1,0],[2,0],[3,0]], trapezoid_positions([3,2]), tag, "size=[3,2]");
    assert_equals([[0,2], [0,1],[1,1], [0,0],[1,0],[2,0]], trapezoid_positions([1,3]), tag, "size=[1,3]");
}

module test_all() {
    test_hexes_per_row();
    test_rectangle_offset_to_axial();
    test_is_in_rect_tile();
    test_is_in_hex_tile();
    test_is_in_semi_hex_tile();
    test_x_range();
    test_hex_positions();
    test_trapezoid_positions();
    test_invert_rows();
}

test_all();

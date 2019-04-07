function join(s) =
    (len(s) == 0)
        ? ""
        : (len(s) == 1)
            ? str(s[0])
            : str(s[0], join([for (i=[1:len(s)-1]) s[i]]));

module assert_equals(expected, actual, tag, tag2) {
    if (expected != actual) {
        msg = str(actual, " expected to be ", expected);
        tag = join([ for (t=[tag,tag2]) if (t != undef) t]);
        echo(str(tag, ": Assert Failed! ", msg));
    }
}

module assert_range_equals(expected, actual, tag, tag2) {
    _expected = [for (i = expected) i];
    _actual = [for (i = actual) i];
    assert_equals(_expected, _actual, tag, tag2);
}

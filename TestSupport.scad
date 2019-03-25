module assert_equals(expected, actual, tag) {
    if (expected != actual) {
        echo(str("Assert Failed! ", (tag != undef)
            ? str(tag, ": ", actual, " expected to be ", expected)
            : str(actual, " expected to be ", expected)));
    }
}


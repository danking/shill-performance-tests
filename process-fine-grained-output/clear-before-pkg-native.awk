BEGIN { seen_pkg_native == 0 }
{ if (seen_pkg_native == 1 ) { print $0 } }
/^pkg-native:.*/ { seen_pkg_native = 1 }

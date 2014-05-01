# this script collects stats that show up once per run
/^before_everything.*/ { before_everything = $2 / 1000 }
/^vm startup.*/ {
  after_vm_startup = $8
  vm_startup = after_vm_startup - before_everything
}
/^ambient done.*/ {
  after_ambient = $4
  ambient = after_ambient - after_vm_startup
}
/^pkg-native.*/ { pkg_native = $2 }
END { 
  print "vm_startup", "ambient", "pkg_native"
  print vm_startup, ambient, pkg_native
}



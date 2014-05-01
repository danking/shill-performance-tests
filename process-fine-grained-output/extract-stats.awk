BEGIN { shill_sandbox = 0 ; c_sandbox = 0 ; exec = 0 ; grepfun = 0 }
/^shill-sandbox:.*/ { shill_sandbox += $2 }
/^c-sandbox:.*/ { c_sandbox += $2 }
/^exec:.*/ { exec += $2 }
/^grepfun:.*/ { grepfun += $2 }
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
  print vm_startup, ambient, pkg_native, shill_sandbox, c_sandbox, exec, grepfun
}

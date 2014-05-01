# this script collects the grep calls to exec
BEGIN { print "sandbox", "exec", "grepfun" }
/^shill-sandbox:.*/ { sandbox = $2 }
/^exec:.*/ { exec = $2 }
/^grepfun:.*/ {
  grepfun = $2
  print sandbox, exec, grepfun
}


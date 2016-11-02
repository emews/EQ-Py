
package provide task 0.1
package require turbine 0.1

proc task { tuple } {

  if { [ llength $tuple ] != 1 } {
    puts "task: requires 1 tuple string!"
    puts "task: received `$tuple'"
    exit 1
  }

  set params [ split $tuple "," ]
  set x [ lindex $params 0 ]
  set y [ lindex $params 1 ]

  # sin(4*x)+sin(4*y)+-2*x+x^2-2*y+y^2
  set v [ expr sin(4*$x)+sin(4*$y) \
              - 2*$x + 2*$x**2     \
              - 2*$y + 2*$y**2 ]

  set delay [ turbine::randint_impl 0 10]
  # show delay
  after $delay

  puts [ format "TASK: %0.3f %0.3f -> %0.3f" $x $y $v ]

  return $v
}

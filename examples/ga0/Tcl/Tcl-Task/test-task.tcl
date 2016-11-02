
package require task 0.0

set result [ task $argv ]
puts [ format "%0.3f" $result ]


# make-package.tcl
# Creates pkgIndex.tcl

set name     task
set version  0.1

puts [ ::pkg::create -name $name -version $version \
           -source task.tcl ]

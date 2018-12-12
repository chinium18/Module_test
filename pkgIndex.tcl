#!/usr/bin/tclsh
#
puts stderr "the index file is sourced"
set dir /projectnb/scv/shwei/Module_test
package ifneeded scc_module 1.0 [list source [file join $dir scc_module.tcl]]

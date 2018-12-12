#!/usr/bin/tclsh
puts stderr "subfunction called here."
package require scc_module 1.0

puts stderr "scc_module packaged loaded here."

set loaded_modules [scc_module::check]
#set tmp [catch { exec   /usr/local/Modules/3.2.10/bin/modulecmd bash list  -t } loaded_modules]
# Convert to a list and strip the 1st line "Currently Loaded Modulefiles:"
set loaded_modules [lreplace [split $loaded_modules \n] 0 0]
set allowed_pythons [ list python/2.7.* python/3.6.* ]
set py_match_ver 0
foreach ld_mod $loaded_modules {
   foreach ok_py $allowed_pythons {
        if { [ string match $ok_py $ld_mod ] } {
          # Store the match from allowed_pythons so it can be re-used
          # in the info message below.
          set py_match_ver $ok_py
          break
        }
   }
}
 

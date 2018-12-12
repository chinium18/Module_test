#Register the package scc_module.tcl
#
#puts stderr "sourcing this scc_module package"
package provide scc_module 1.0
package require Tcl 8.5

#Create the namespace
#
namespace eval ::scc_module {
	#Export commands
	namespace export check check_conflict check_cuda check_python check_prereq 

	#Set up state
	#variable loaded_modules 
	variable mod_to_load
	variable allowed_pythons
	variable conflict_modules
	variable has_cuda
	variable ld_mod
	variable ok_py
	variable conflict_mod
}

# Check loaded modules
proc ::scc_module::check {} {
	variable ld_mod
	variable ok_py
#	puts stderr "check function is called ..."
#	catch { exec   /usr/local/Modules/3.2.10/bin/modulecmd bash list  -t } loaded_modules
	if {[info exists ::env(LOADEDMODULES)] } {
           set loaded_modules $::env(LOADEDMODULES)
        } else {
          set loaded_modules ""
        }
	set loaded_modules [split $loaded_modules :] 
	#puts stderr $loaded_modules
	#puts stderr "?????????????????"
	set allowed_pythons [ list python2/2.7.* python3/3.6.* ]
	set py_match_ver 0
	foreach ld_mod $loaded_modules {
	  #puts stdeff "loaded "$ld_mod
	  foreach ok_py $allowed_pythons {
	       if { [ string match $ok_py $ld_mod ] } {
	         # Store the match from allowed_pythons so it can be re-used
        	 # in the info message below.
	         set py_match_ver $ok_py
		# puts stderr "Matching ......."
		# puts stderr $ok_py
		# puts stderr $ld_mod
        	 break
        	}
  	   }
	}	
	return [list $allowed_pythons $loaded_modules $py_match_ver]
}

proc ::scc_module::check_conflict {conflict_modules loaded_modules} {
	#puts stderr "CCCCChecking conflict function:"
	variable ld_mod
	variable conflict_mod
	#puts stderr "conflict modules "
	#puts stderr $conflict_modules
	#puts stderr "loaded modules"
	#puts stderr $loaded_modules	
	foreach ld_mod $loaded_modules {
	   foreach conflict_mod $conflict_modules {
	   	#puts stderr $ld_mod
	   	#puts stderr $conflict_mod
		#puts stderr "conflict module "$conflict_mod
        	if { [ string match $conflict_mod $ld_mod ] } {
	          # If there's a match then there is a conflict. 
	        #  	puts stderr "Catch a conflict!" 
        	  	conflict $ld_mod
        	}
   	    }
	}
	return ""
}

proc ::scc_module::check_cuda {} {
	variable has_cuda	
	set has_cuda 0
	if { [ info exists env(CUDA_VISIBLE_DEVICES) ] } {
		set has_cuda 1
	}
	return $has_cuda
}

proc ::scc_module::check_python {} {
	catch {exec python -V} py_match_ver
	set py_match_ver [ lindex [split $py_match_ver " "] 1]
	#puts stderr "Checking python version here:"
	#puts stderr $py_match_ver
	set py_major_ver [ lindex [ split $py_match_ver .] 0]
	set py_major_minor_ver $py_major_ver.[ lindex [ split $py_match_ver .] 1]
	return [list $py_major_ver $py_major_minor_ver]
}

proc ::scc_module::check_prereq {prereq_list prereq_default} {
	puts stderr "check_prereq function is called ..."
	variable mod_to_load	
	set mod_to_load ""

	if {[info exists ::env(LOADEDMODULES)] } {
	   set x $::env(LOADEDMODULES)
	} else {
	  set x ""
	}

	if { [ module-info mode load ] } {
	   foreach p $prereq_list pdef $prereq_default {
	       set y [ regexp $p $x ]
	       if { ( $y == 0)} {
        	  set mod_to_load  "$mod_to_load\n  module load $pdef"
	       }
	   }

	   if {$mod_to_load != ""} {
	   puts stderr "

-------------------------------------------------------------------------------
ERROR: hail/test requires several additional modules. Run the following
commands to load all of the dependencies (including this module):

  $mod_to_load
  module load /share/pkg/hail/test/modulefile.txt
-------------------------------------------------------------------------------

	   "
	   exit
	   }
	return 0
	}

}

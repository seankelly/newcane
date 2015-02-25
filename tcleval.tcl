# safe interpreter
# for evaluating "raw" scripts

bind pub - !tcl     tcleval::safeeval
bind pub o !tclhash tcleval::saferehash

# calc
bind pub - !calc    tcleval::calc
bind pub - !c       tcleval::calc

namespace eval tcleval {
  variable path {tcleval}

  proc evalcreate p {
    interp create -safe $p
    interp recursionlimit $p 100 
    interp eval $p {
      set calcresults [list]
      proc calc_res {n} {
	variable calcresults
        if {[llength $calcresults] > $n} {
	  return [lindex $calcresults $n]
	} else {
	  return 0
	}
      }
      proc calc {func} {
	variable calcresults
        set a [regsub -all {\$(\d)} $func {[calc_res \1]}]
        #set eqn [expr [uplevel 1 subst $a]]
        set eqn [expr [subst $a]]
	set calcresults [linsert [lrange $calcresults 0 18] 0 $eqn]
        return $eqn
      }

      # works magic over |from|
      # TODO: finish^Wstart
      proc unit {from} {
      }
    }
  }

  if {![interp exists $path]} {
    evalcreate $path
  }

  proc safeeval {nick host hand chan text} {
    variable path
    interp limit $path time -seconds [expr {[clock seconds] + 2}]
    if {[catch {set result [interp eval $path $text]} err]} {
      putchan $chan \[interp\] error: $err
    } else {
      if {[string length $result] > 0} { putchan $chan $result }
    }
  }

  proc saferehash {nick host hand chan text} {
    variable path
    if {[interp exists $path]} {
      interp delete $path
      evalcreate $path
    }
  }

  proc calc {nick host hand chan text} {
    variable path
    #set tocalc "{$text}"
    interp limit $path time -seconds [expr {[clock seconds] + 2}]
    if {[catch {set res [interp eval $path calc [list $text]]} err]} {
      putchan $chan \[expr\] error: $err
    } else {
      putchan $chan $res
    }
  }
  proc unit {nick host hand chan text} {
    variable calcresults
    set convert [string map {\" {} \\ {} ; {}} $convert]
    set a [regsub -all {\$(\d)} $convert {[calc_res \1]}]
    set from {}
    if {![regexp {^(.*)>\s*(.*)\s*$} $convert -> from to]} {
      putquick "PRIVMSG $chan :Need a 'from' unit"
      return
    }
    interp limit $path time -seconds [expr {[clock seconds] + 1}]
    if {[catch {set from [interp eval $path {return $a}]}]} {
      putquick "PRIVMSG $chan :Subst error"
      return
    }
    set cmd [list exec units -q "$from" "$to"]
    if {[catch $cmd res]} {
      putquick "PRIVMSG $chan :units error"
    } {
      if {[regexp {^\t\* (.*)\n} $res -> ans]} {
        putquick "PRIVMSG $chan :units: $ans $to"
      } {
        putquick "PRIVMSG $chan :units: [lindex [split $res \n] 0]"
      }
    }
  }
}

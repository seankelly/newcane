# unit conversions

bind pub - !unit  cmd_unit
bind pub - !units cmd_unit
bind pub - !u     cmd_unit

proc cmd_unit {nick host hand chan text} {
  if {![regexp {^(.*)>\s*(.*)\s*$} $text -> from to]} {
    putquick "PRIVMSG $chan :Need a 'from' unit"
    return
  }
  set cmd [list exec units -q $from $to]
  if {[catch $cmd res]} {
    putquick "PRIVMSG $chan :units error"
  } {
    if {[regexp {^\t\* (.*)\n} $res -> ans]} {
      putquick "PRIVMSG $chan :units: $ans $to"
    } {
      putquick "PRIVMSG $chan :units: [string trim [lindex [split $res \n] 0]] $to"
    }
  }
}

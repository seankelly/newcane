# ascii<->number conversion

bind pub - !chr do_chr
bind pub - !asc do_asc

proc chr {d} {
  set lowval [list NUL SOH STX ETX EOT ENQ ACK BEL BS TAB LF VT FF CR SO SI DLE DC1 DC2 DC3 DC4 NAK SYN ETB CAN EM SUB ESC FS GS RS US SPACE]
  set a {}
  if {$d >= 0 && $d <= 32} {
    set a [lindex $lowval $d]
  } elseif {$d > 32 && $d < 127} {
    set a [format %c $d]
  } elseif {$d == 127} {
    set a DEL
  }
  if {[string length $a] > 0} { return $a }
}

# !chr N == converts N to ASCII value
proc do_chr {nick host hand chan text} {
  set diglist [split $text]
  set ascii [list]
  foreach n $diglist {
    if {[regexp {^(\d+)-(\d+)$} $n -> a b]} {
      if {$b != $a} {
	if {$a > $b} {
	  set step -1; set op >=
	} else {
	  set step 1; set op <=
	}
	for {set i $a} {[expr $i $op $b]} {incr i $step} {
	  lappend ascii [chr $i]
	}
      } elseif {$b == $a} {
	lappend ascii [chr $a]
      }
    } elseif {[regexp {^(\d+)$} $n -> a]} {
      lappend ascii [chr $a]
    } elseif {[string is wordchar -strict $n]} {
      lappend ascii $n
    }
  }
  if {[llength $ascii] > 0} {
    putquick "PRIVMSG $chan :Characters: [join $ascii]"
  }
}

proc asc {char} {
  return [scan $char %c]
}

proc asc_spec {spec} {
  set val [string map {
    NUL 0  SOH 1  STX 2  ETX 3  EOT 4  ENQ 5  ACK 6  BEL   7  BS 8
    TAB 9  LF 10  VT  11 FF  12 CR  13 SO  14 SI  15 DLE   16
    DC1 17 DC2 18 DC3 19 DC4 20 NAK 21 SYN 22 ETB 23 CAN   24
    EM  25 SUB 26 ESC 27 FS  28 GS  29 RS  30 US  31 SPACE 32
    DEL 127
  } $spec]
  if {[string is digit -strict $val]} {
    return $val
  } else {
    return -1
  }
}

proc do_asc {nick host hand chan text} {
  set charlist [split $text]
  set asc [list]
  foreach c $charlist {
    if {[string length $c] > 1} {
      if {[set d [asc_spec $c]] != -1} {
	lappend asc $d
      } else {
	foreach d [split $c {}] {
	  lappend asc [asc $d]
	}
      }
    } elseif {[string length $c] > 0} {
      lappend asc [asc $c]
    }
  }
  if {[llength $asc] > 0} {
    putquick "PRIVMSG $chan :ASCII Values: [join $asc]"
  }
}

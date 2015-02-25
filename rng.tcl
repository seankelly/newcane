# !rng functions

bind pub - !rng cmd_rng

proc cmd_rng {nick host hand chan text} {
  set text [split $text]
  set opt [lindex $text 0]
  switch -regexp -- $opt {^@coin$} {
##### @coin
    putchan $chan [lindex [list Heads. Tails.] [expr {int(rand() * 2)}]]
  } {^@cat$} {
##### @cat
    putchan $chan [lindex [list Dead! Alive! Unknown!] [expr {int(rand() * 3)}]]
  } {^\d+d\d+$} {
##### XdY
    regexp {(\d+)d(\d+)} $opt -> num sides
    set sum 0
    set d [if {$num != 1} {list dice roll} {list die rolls}]
    if {$sides == 1} {
      putchan $chan Schroedinger is amazed at the result of $num.
      return
    }
    # limit the number of times in a loop
    if {$num > 10000} { set num 10000 }
    for {set i 0} {$i < $num} {incr i} {
      incr sum [expr {int(rand() * $sides + 1)}]
    }
    putchan $chan ${num}d$sides: $sum
  } default {
##### default
    if {[llength $text] > 1} {
      putchan $chan [lindex $text [expr {int(rand() * [llength $text])}]]
    }
  }
}

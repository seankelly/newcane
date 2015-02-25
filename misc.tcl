# miscellaneous commands

#bind pub - !help   cmd_help
bind pub - !len    cmd_len
bind pub - !length cmd_len
bind pub - !ping   cmd_ping
bind pub - !sort   cmd_sort
bind pub - !uptime cmd_uptime
bind pub - !echo   cmd_echo

proc putchan {chan args} {
  putquick "PRIVMSG $chan :[join $args]"
}

# currently disabled
proc cmd_help {nick host hand chan text} {
  array set help {
    index {This is the index.}
    !calc {C-like calculator. Use $N for previous results (up to ten).}
    !ping {"Ping" the bot.}
    !len {Get the length of an arbitrary string (including whitespace)}
    code {http://katron.org/misc/tcl/}
    me {www.google.com}
  }
  set text [split $text]
  set h [array get help [lindex $text 0]]
  if {[llength $h] > 1} {
    putchan $chan Help: [lindex $h 1]
  }
}

proc cmd_len {nick host hand chan text} {
  if {[string length $text] > 0} {
    putchan $chan [string length $text]
  }
}

proc cmd_ping {nick host hand chan text} {
  set ping [list Ping! !gniP Pong!]
  putchan $chan [lindex $ping [expr {int([::random::mt integer]%[llength $ping])}]]
}

proc cmd_rot13 {nick host hand chan text} {
}

proc cmd_sort {nick host hand chan text} {
  set tosort [split $text]
  if {[llength $tosort] > 1} {
    putchan $chan [lsort -dictionary $tosort]
  }
}

proc cmd_uptime {nick host hand chan text} {
  regexp {up (.*?), \d+ users?} [exec uptime] -> up
  putchan $chan "Up $up"
}

proc cmd_echo {nick host hand chan text} {
    putchan $chan $text
}

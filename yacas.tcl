bind pub - !yacas yacas::yacas
bind pub - !y     yacas::yacas

namespace eval yacas {
    variable server_id
    variable buffer [list]
    variable waiting

    proc yacas {nick host hand chan text} {
        calc $chan $text
        after 50 yacas::yacas_get_result
    }

    proc yacas_get_result {} {
        set result [get_result]
        if {[llength $result] > 0} {
            # we have a result
            set chan   [lindex $result 0]
            set answer [lindex $result 1]
            putchan $chan [string trimright $answer \;]
        } else {
            after 250 yacas_get_result
        }
    }

    proc calc {equation_id equation} {
        variable server_id
        variable buffer
        variable waiting

        lappend buffer [list $equation_id $equation]
        send_equation
    }

    proc send_equation {} {
        variable server_id
        variable buffer
        variable waiting

        if {$waiting == 0 && [llength $buffer] > 0} {
            set eq_list [lindex $buffer 0]
            set eq_id    [lindex $eq_list 0]
            set equation "[lindex $eq_list 1];"
            set buffer [lreplace $buffer 0 0 $eq_id]
            set waiting 1

            puts $server_id $equation
        }
    }

    proc get_result {} {
        variable server_id
        variable buffer
        variable waiting

        if {$waiting == 0} return

        # this will be the first line
        set n [gets $server_id tmp]

        if {$n >= 0} {
            lappend output [string trim $tmp]
            while {[string compare $tmp \]] != 0} {
                gets $server_id tmp
                lappend output [string trim $tmp]
            }

            set output [lrange $output 0 end-1]

            set m [gets $server_id result]

            # need to trim off the ']' on the following line
            gets $server_id b
            while {[string compare $b \]] != 0} {
                gets $server_id b
            }

            set eq_id [lindex $buffer 0]
            set buffer [lrange $buffer 1 end]

            set waiting 0
            send_equation

            if {[llength $output] > 0} {
                set ret [list $eq_id [concat $output \; $result]]
            } else {
                set ret [list $eq_id $result]
            }
            return $ret
        } else {
            return [list]
        }
    }

    proc init {} {
        variable server_id
        variable waiting
        set server_id [socket {127.0.0.1} 9734]
        # disable blocking mode
        # buffer on lines only
        fconfigure $server_id -blocking 0 -buffering line
        set waiting 0
    }

    proc destroy {} {
        variable server_id
        close $server_id
    }

    # initialize
    init
}

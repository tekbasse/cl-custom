ad_library {

    API for presenting choices with qcl-wiki
    @creation-date 1 Aug 2013
    @cs-id $Id:
}


ad_proc -public qwcl_spectype_widget { 
    spec_number
    spec_ref 
    spec_type_w_args
    spec_default
    {spec_value ""}
} {
    Creates a form widget based on spectype
} {
# spec_ref_number is from 1 to 5, is used to build the name attribute in the form input tag
#code
    set return_list [list ]
    if { $spec_value eq "" } {
        set $spec_value $spec_default
    }
    set spec_type_list [split $spec_type_w_args " "]
    set spec_type [lindex $spec_type_list 0]
    if { $spec_type ne "" } {
        set spec_type_args_list [lreplace $spec_type_list 0 0]
        
        switch -exact -- $spec_type {
            colors {
                set return_list [qwcl_colors_widget $spec_number $spec_ref $spec_type_args_list $spec_default $spec_value]
            }
            numbers {
                set return_list [qwcl_numbers_widget $spec_number $spec_ref $spec_type_args_list $spec_default $spec_value]
            }
            select1 {
                set return_list [qwcl_select1_widget $spec_number $spec_ref $spec_type_args_list $spec_default $spec_value]
            }
            selectn {
                set return_list [qwcl_selectn_widget $spec_number $spec_ref $spec_type_args_list $spec_default $spec_value]
            }
            * {
                ns_log Notice "qwcl_spectype_widget: spec#type is not recognized. check input for spec_number ${spec_number} of spec_type."
            }
        }
    }
    return $return_list
}


ad_proc -public qwcl_colors_widget {
    spec_number
    spec_ref 
    spec_type_args_list
    spec_default
    spec_value
} {
    Creates a form widget for choosing colors
} {
ns_log Notice "qwcl_colors_widget: working.."
    ecbw_build_color_chart colors_arr
    set colors_list [list]
    foreach color $colors_arr(rows) {
#        set name  "<img src=\"http://birdswelcome.com/resources/dot.gif\" width=\"20\" height=\"10\" style=\"background-color: $colors_arr($color,hex_color);\" alt=\"$colors_arr($color,pretty_name)\">&nbsp;$colors_arr($color,pretty_name)"
        set name  "$colors_arr($color,color_ref)&nbsp;$colors_arr($color,pretty_name)"
        lappend colors_list [list value $color label $name]
    }

    if { $spec_ref eq "" } {
        set brand_color_spec "Color"
    } else {
        set brand_color_spec $spec_ref
    }
    if { $spec_value eq "" } {
        set spec_value [string tolower $spec_default]
    }
    set this_colors_list [list]
    foreach option_list $colors_list {
        set value_to_check [lindex $option_list 1]
        if { $value_to_check eq $spec_value } {
            lappend this_colors_list [list "value" [lindex $option_list 1] "label" [lindex $option_list 3] "selected" "1"]
        } else {
            lappend this_colors_list $option_list
        }
    }
    return $this_colors_list
}

ad_proc -public qwcl_numbers_widget {
    spec_number
    spec_ref 
    spec_type_args_list
    spec_default
    spec_value
} {
    Creates a form widget for choosing from a range of numbers
} {
ns_log Notice "qwcl_numbers_widget: working.."
    if { $spec_value eq "" } {
        set spec_value $spec_default
    }
    # verify input
    set args_count [llength $spec_type_args_list]
    set arg0 [lindex $spec_type_args_list 0]
    set arg1 [lindex $spec_type_args_list 1]
    set arg2 [lindex $spec_type_args_list 2]
    if { $args_count < 2 } {
        set arg1 $arg0
    } 
    if { $args_count < 3 } {
        set arg2 1
    }
    set values_list [list ]
    if { [ad_var_type_check_number_p $arg0] && [ad_var_type_check_number_p $arg1] && [ad_var_type_check_number_p $arg2] } {
        set number_list [list ]
        if { $arg1 < $arg0 } {
            # count down
            if { $arg2 > 0 } {
                set $arg2 [expr { -1. * $arg2 } ]
            }
            for { set ii $arg0 } { $ii >= $arg1 } { set ii [expr { $ii + $arg2 }]  } {
                # generate list of numbers
                lappend number_list $ii
            }
        } elseif { $arg0 < $arg1 } {
            #count up
            if { $arg2 < 0 } {
                set $arg2 [expr { -1. * $arg2 } ]
            }
            for { set ii $arg0 } { $ii <= $arg1 } { set ii [expr { $ii + $arg2 }]  } {
                # generate list of numbers
                lappend number_list $ii
            }
        } else {
            # no need to count
            ns_log Notice "qwcl_numbers_widget: expected at least two different numbers. Didn't give user a choice on a product specification."
            lappend number_list $arg0
        }
        set dec_pos [string first "." $arg2]
        set spec_value_unquoted [ad_unquotehtml $spec_value]
        regsub -- {%2e} $spec_value_unquoted {.} spec_value_unquoted 
        foreach number $number_list {
            if { $dec_pos > -1 } {
                set decimal_ct [expr { [string length $arg2] - $dec_pos - 1 } ]
                set number2 [string trim [format "%6.${decimal_ct}f" $number]]
            } else {
                set number2 [string trim [format "%d" $number]]
            }
            if { $number2 eq $spec_value_unquoted } { 
                lappend values_list [list label $number2 value $number2 selected 1]
            } else {
                lappend values_list [list label $number2 value $number2]
            }
        }
    } else {
        ns_log Notice "qwcl_numbers_widget: expected numbers, but at least one was not. Ignoring request."
    }
    return $values_list
}

ad_proc -public qwcl_select1_widget {
    spec_number
    spec_ref 
    spec_type_args_list
    spec_default
    {spec_value ""}
} {
    Creates a form widget for choosing one of a set of words
} {
    ns_log Notice "qwcl_select1_widget: working.."
    if { $spec_value eq "" } {
        set spec_value $spec_default
    }
    set spec_prev_value $spec_value
    set select1_list [list]
    set none_selected 1
    foreach option $spec_type_args_list {
        set value_to_check $option
        if { $value_to_check eq $spec_prev_value } {
            if { $none_selected } {
                lappend select1_list [list "value" $option "label" $option "selected" 1]
                set none_selected 0
            } else {
                lappend select1_list [list "value" $option "label" $option]
            }
        }
    }
    return $select1_list
}

ad_proc -public qwcl_selectn_widget {
    spec_number
    spec_ref 
    spec_type_args_list
    spec_default
    spec_value
} {
    Creates a form widget for choosing from a set of words
} {
ns_log Notice "qwcl_selectn_widget: working.."
# spec_default or #spec_value can have more than one value
    set spec_default_list [split $spec_default " "]
    set spec_value_list [split $spec_value " "]
    if { [llength $spec_value_list ] == 0 } {
        set spec_value_list $spec_default_list
    }
    ns_log Notice "qwcl_selectn_widget: spec_type_args_list $spec_type_args_list [llength $spec_type_args_list] items."
    set selectn_list [list]
    foreach option $spec_type_args_list {
        ns_log Notice "qwcl_selectn_widget: option '$option'"
        if { [lsearch -exact $spec_value_list $option] > -1 } {
            lappend selectn_list [list "value" $option "label" $option "checked" 1]
        } else {
            lappend selectn_list [list "value" $option "label" $option]
        }
    } 
    
    return $selectn_list
}

# cl-custom/www/q-wiki.tcl
# part of the cl-custom package based on Q-Wiki package 
# depends on OpenACS website toolkit at OpenACS.org
# copyrigh 2013
# released under GPL license
# this page split into MVC components:
#  inputs/observations (controller), actions (model), and outputs/reports (view) sections

## For consistency, user_id can only make modifications if they have create_p permissions. 
## User_id is not enough, as there would be issues with choosing active revisions
## so, user_id revsion changes are moderated. ie user_id can create a revision, but it takes write_p user to make revision active.


# INPUTS / CONTROLLER

# set defaults
# template_id is first page_id, subsequent revisions have same template_id, but new page_id
# flags are blank -- an unused db column / page attribute for extending the app for use cases
# url has to be a given (not validated), since this page may be fed $url via an index.vuh

set title "cl-custom"
set icons_path1 "/resources/acs-subsite/"
set icons_path2 "/resources/ajaxhelper/icons/"
set delete_icon_url [file join $icons_path2 delete.png]
set trash_icon_url [file join $icons_path2 page_delete.png]
set untrash_icon_url [file join $icons_path2 page_add.png]
set radio_checked_url [file join $icons_path1 radiochecked.gif]
set radio_unchecked_url [file join $icons_path1 radio.gif]
set redirect_before_v_p 0

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set read_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege read]
set create_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege create]
set write_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege write]
set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege admin]
set delete_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege delete]
ns_log Notice "cl-custom/q-wiki.tcl: package_id $package_id user_id $user_id read_p $read_p create_p $create_p write_p $write_p admin_p $admin_p delete_p $delete_p"
array set input_array [list \
                           url ""\
                           page_id ""\
                           page_name ""\
                           page_title ""\
                           page_contents ""\
                           keywords ""\
                           description ""\
                           page_comments ""\
                           page_template_id ""\
                           page_flags ""\
                           page_contents_default ""\
                           submit "" \
                           reset "" \
                           mode "v" \
                           next_mode "" \
                           url_referring "" \
                           model_ref "" \
                           spec1ref "" \
                           spec1type "" \
                           spec1value "" \
                           spec1default "" \
                           spec2ref "" \
                           spec2type "" \
                           spec2value "" \
                           spec2default "" \
                           spec3ref "" \
                           spec3type "" \
                           spec3value "" \
                           spec3default "" \
                           spec4ref "" \
                           spec4type "" \
                           spec4value "" \
                           spec4default "" \
                           spec5ref "" \
                           spec5type "" \
                           spec5value "" \
                           spec5default "" \
                           gallery_folder_id "" \
                           photo_id "" \
                           price "" \
                           dimensions "" \
                           ship_wt "" \
                           actual_wt "" \
                           unit "" \
                           master "" \
                          ]

set user_message_list [list ]
set title $input_array(page_title)

# get previous form inputs if they exist
set form_posted [qf_get_inputs_as_array input_array2]
if { $form_posted && ( $input_array2(mode) eq "w" || $input_array2(mode) eq "d" ) } {
    # do this again for hash_check to avoid irreversable cases.

    array unset input_array2
    set form_posted [qf_get_inputs_as_array input_array hash_check 1]
} else {
    array set input_array [array get input_array2]
}

# these ifs handle cases where q-wiki is included in another acs-templated page
if { ![info exists master] } {
    set master $input_array(master)
} 
if { [info exists mode] && $input_array(mode) eq "" } {
    set input_array(mode) $mode
    set input_array(page_name) "index"
}

set page_id $input_array(page_id)
set page_template_id $input_array(page_template_id)

set page_name $input_array(page_name)
set page_title $input_array(page_title)
set page_flags $input_array(page_flags)
set keywords $input_array(keywords)
set description $input_array(description)
set page_comments $input_array(page_comments)
set page_contents $input_array(page_contents)
set mode $input_array(mode)
set next_mode $input_array(next_mode)

set model_ref $input_array(model_ref)
set spec1ref $input_array(spec1ref)
set spec1type $input_array(spec1type)
set spec1default $input_array(spec1default)
set spec1value $input_array(spec1value)
set spec2ref $input_array(spec2ref)
set spec2type $input_array(spec2type)
set spec2default $input_array(spec2default)
set spec2value $input_array(spec2value)
set spec3ref $input_array(spec3ref)
set spec3type $input_array(spec3type)
set spec3default $input_array(spec3default)
set spec3value $input_array(spec3value)
set spec4ref $input_array(spec4ref)
set spec4type $input_array(spec4type)
set spec4default $input_array(spec4default)
set spec4value $input_array(spec4value)
set spec5ref $input_array(spec5ref)
set spec5type $input_array(spec5type)
set spec5default $input_array(spec5default)
set spec5value $input_array(spec5value)
set gallery_folder_id $input_array(gallery_folder_id)
set photo_id $input_array(photo_id)
set price $input_array(price)
set dimensions $input_array(dimensions)
set ship_wt $input_array(ship_wt)
set actual_wt $input_array(actual_wt)
set unit $input_array(unit)

# Is this a redirect from index.vuh ?
set file_name [file tail [ad_conn file]]
if { [ns_urldecode $input_array(url_referring)] eq "index.vuh" && $file_name eq "q-wiki.adp" } {
    # To do, when write_p == 1: index.vuh value should be replaced with a session continuity key passed via db.

    # If url is internal_redirecting from index.vuh, url should be same as:
    # set url [ad_conn path_info]

    # url_de-encode values
    set url $input_array(url)
    set page_name [ns_urldecode $page_name]
    set page_title [ns_urldecode $page_title]
    set page_flags [ns_urldecode $page_flags]
    set keywords [ns_urldecode $keywords]
    set description [ns_urldecode $description]
    set page_comments [ns_urldecode $page_comments]
    set page_contents [ns_urldecode $page_contents]

set model_ref [ns_urldecode $model_ref]
set spec1ref [ns_urldecode $spec1ref]
set spec1type [ns_urldecode $spec1type]
set spec1default [ns_urldecode $spec1default]
set spec2ref [ns_urldecode $spec2ref]
set spec2type [ns_urldecode $spec2type]
set spec2default [ns_urldecode $spec2default]
set spec3ref [ns_urldecode $spec3ref]
set spec3type [ns_urldecode $spec3type]
set spec3default [ns_urldecode $spec3default]
set spec4ref [ns_urldecode $spec4ref]
set spec4type [ns_urldecode $spec4type]
set spec4default [ns_urldecode $spec4default]
set spec5ref [ns_urldecode $spec5ref]
set spec5type [ns_urldecode $spec5type]
set spec5default [ns_urldecode $spec5default]
set gallery_folder_id [ns_urldecode $gallery_folder_id]
set photo_id [ns_urldecode $photo_id]
set price [ns_urldecode $price]
set dimensions [ns_urldecode $dimensions]
set ship_wt [ns_urldecode $ship_wt]
set actual_wt [ns_urldecode $actual_wt]
set unit [ns_urldecode $unit]

} elseif { $file_name eq "index.vuh" } {
    # is this code executing inside index.vuh?
    set url [ad_conn path_info]
    ns_log Notice "q-wiki.tcl(29): file_name ${file_name}. Setting url to $url"
} elseif { !$form_posted && $input_array(url_referring) eq "" } {
    # this test is for cases where hash_check is required for form posts
    # but no user form has been posted, default values still need to be passed.
    set url [ad_conn path_info]
    set file_name $url
} else {
    # A serious assumption has broken.
    ns_log Warning "q-wiki.tcl(75): quit with referr_url and file_name out of boundary. Check log for request details."
    ns_returnnotfound
    #  rp_internal_redirect /www/global/404.adp
    ad_script_abort
}

if { $url eq "" || $url eq "/" } {
    set url "index"
}


if { $write_p } {
    set page_id_from_url [qw_page_id_from_url $url $package_id]
} else {
    # user can only edit or see it if it is published (not trashed)
    set page_id_from_url [qw_page_from_url $url $package_id]
}


if { $page_id_from_url ne "" && ![qf_is_natural_number $page_id_from_url] } {
    ns_log Notice "q-wiki.tcl(62): page_id_from_url '$page_id_from_url'"
}
ns_log Notice "q-wiki.tcl(63): mode $mode next_mode $next_mode"
# Modes are views, or one of these compound action/views
    # d delete (d x) then view as before (where x = l, r or v)
    # t trash (d x) then view as before (where x = l, r or v)
    # w write (d x) , then view page_id (v)

# Actions
    # d = delete template_id or page_id
    # t = trash template_id or page_id
    # w = write page_id,template_id, make new page_id for template_id
    # a = make page_id the active revision for template_id
# Views
    # e = edit page_url, presents defaults (new) if page doesn't exist
    # v = view page_url
    # l = list pages of instance
    # r = view/edit page_url revisions
    # default = 404 return

    # url has to come from form in order to pass info via index.vuh
    # set conn_package_url [ad_conn package_url]
    # set url [string range $url [string length $conn_package_url] end]
    # get page_id from url, if any

if { $form_posted } {
    if { [info exists input_array(x) ] } {
        unset input_array(x)
    }
    if { [info exists input_array(y) ] } {
        unset input_array(y)
    }
    if { ![qf_is_natural_number $page_id] } {
        set page_id ""
    } 

    set validated_p 0
    # validate input
    # cleanse data, verify values for consistency
    # determine input completeness

    
    if { $page_id_from_url ne "" } {
        # page exists
       

        set page_stats_from_url_list [qw_page_stats $page_id_from_url $package_id $user_id]
        set page_template_id_from_url [lindex $page_stats_from_url_list 5]
        ns_log Notice "q-wiki.tcl(106): page_id_from_url '$page_id_from_url' page_template_id_from_url '$page_template_id_from_url'"

        # page_template_id and page_id gets checked against db for added security
        # check for form/db descrepencies
        set page_stats_from_form_list [qw_page_stats $page_id]
        set page_template_id_from_form_pid [lindex $page_stats_from_form_list 5]

        # if mode is e etc, allow edit of page_id in set of page_id_from_url revisions:
        # verify template_id from page_id and from url are consistent.
        if { $page_id ne ""  && [qf_is_natural_number $page_template_id_from_url ] && $page_template_id_from_url ne $page_template_id_from_form_pid } {
            ns_log Notice "q-wiki/q-wiki.tcl: template_ids don't match. page_id '$page_id' page_id_from_url '$page_id_from_url', page_template_id_from_url '$page_template_id_from_url' page_template_id_from_form_pid '$page_template_id_from_form_pid'"
            set page_id $page_id_from_url
            set  mode ""
            set next_mode ""
            lappend user_message_list "There has been an internal processing error. Try again or report issue to [ad_admin_owner]"
            util_user_message -message [lindex $user_message_list end]
        }
        if { $page_template_id ne ""  && [qf_is_natural_number $page_template_id ] && $page_template_id_from_url ne $page_template_id } {
            ns_log Notice "q-wiki/q-wiki.tcl: template_ids don't match. page_template_id '$page_template_id' page_id_from_url '$page_id_from_url', page_template_id_from_url '$page_template_id_from_url'"
            set page_template_id $page_template_id_from_url
            set  mode ""
            set next_mode ""
            lappend user_message_list "There has been an internal processing error. Try again or report issue to [ad_admin_owner]"
            util_user_message -message [lindex $user_message_list end]
        }
        
        # A blank referrer means a direct request
        # otherwise make sure referrer is from same domain when editing
        set referrer_url [get_referrer]


        ns_log Notice "q-wiki.tcl(124): mode $mode next_mode $next_mode"
        # get info to pass back to write proc

        # This is a place to enforce application specific permissions.
        # If package parameter says each template_id is an object_id, 
        # check user_id against object_id, otherwise check against package_id
        # However, original_page_creation_user_id is in the db, so that instance specific
        # user permissions can be supported.
        # set original_user_id \[lindex $page_stats_list_of_template_id 11\]

    } else {
        # page does not exist
        if { $write_p && $mode ne "l" && $mode ne "w" } {
            # present an edit/new page
            set mode "e"
            set next_mode ""
            set validated_p 1
        }
    } 
    # else should default to 404 at switch in View section.

    # validate input values for specific modes
    # failovers for permissions follow reverse order (skipping ok): admin_p delete_p write_p create_p read_p
    # possibilities are: d, t, w, e, v, l, r, "" where "" is invalid input or unreconcilable error condition.
    # options include    d, l, r, t, e, "", w, v
    set http_header_method [ad_conn method]
    ns_log Notice "q-wiki.tcl(141): initial mode $mode, next_mode $next_mode, http_header_method ${http_header_method}"
    if { ( $next_mode eq "v" || $next_mode eq "l" ) && [string match -nocase GET $http_header_method] } {
        # redirect when viewing, to clean the url
        ns_log Notice "q-wiki.tcl(223): Setting redirect_before_v_p "
        set redirect_before_v_p 1
    } 
    if { $mode eq "d" } {
        if { $delete_p } {
            ns_log Notice "q-wiki.tcl validated for d"
            set validated_p 1
        } elseif { $read_p } {
            set mode "l"
            set next_mode ""
        } else {
            set mode ""
            set next_mode ""
        }
    }
    ns_log Notice "q-wiki.tcl(157): mode $mode next_mode $next_mode"
    if { $mode eq "w" } {
        if { $write_p } {
            set validated_p 1
        } elseif { $read_p } {
            # give the user a chance to save their changes elsewhere instead of erasing the input
            set mode "e"
        } else {
            set mode ""
            set next_mode ""
        }
    }
    ns_log Notice "q-wiki.tcl(169): mode $mode next_mode $next_mode"
    if { $mode eq "r" || $mode eq "a" } {
        if { $write_p } {
            if { [qf_is_natural_number $page_template_id_from_url ] } {
                set validated_p 1
                ns_log Notice "q-wiki.tcl validated for $mode"
            } elseif { $read_p } {
                # This is a 404 return, but we list pages for more convenient UI
                lappend user_message_list "Page not found. Showing a list of pages."
            util_user_message -message [lindex $user_message_list end]
                set mode "l"
            }
        } else {
            set mode ""
            set next_mode ""
        }
    }
    ns_log Notice "q-wiki.tcl(185): mode $mode next_mode $next_mode"
    if { $mode eq "t" } {
        if { ( $write_p || $user_id > 0 ) && ([qw_page_id_exists $page_id $package_id] || [qw_page_id_exists $page_id_from_url $package_id] ) } {
            # complete validation occurs while trashing.
            set validated_p 1
            ns_log Notice "q-wiki.tcl validated for t"
        } elseif { $read_p } {
            set mode "l"
        } else {
            set mode ""
        }
    }

    if { $page_id_from_url eq "" && $write_p && $mode eq "" && $next_mode eq "" } {
        # page is blank
        # switch to edit mode automatically for users with write_p
        set mode "e"
    } 

    ns_log Notice "q-wiki.tcl(197): mode $mode next_mode $next_mode"
    if { $mode eq "e" } {
        # validate for new and existing pages. 
        # For new pages, template_id will be blank (template_exists_p == 0)
        # For revisions, page_id will be blank.
        set template_exists_p [qw_page_id_exists $page_template_id]
        if { !$template_exists_p } {
            set page_template_id ""
        }
        if { $write_p || ( $create_p && !$template_exists_p ) } {
            
            # page_title cannot be blank
            if { $page_title eq "" && $page_template_id eq "" } {
                set page_title "[clock format [clock seconds] -format %Y%m%d-%X]"
            } elseif { $page_title eq "" } {
                set page_title "${page_template_id}"
            } else {
                set page_title_length [parameter::get -package_id $package_id -parameter PageTitleLen -default 80]
                incr page_title_length -1
                set page_title [string range $page_title 0 $page_title_length]
            }
            
            if { $page_template_id eq "" && $page_name ne "" } {
                # this is a new page
                set url [ad_urlencode $page_name]
                set page_id ""
            } elseif { $page_template_id eq "" } {
                if { [regexp -nocase -- {[^a-z0-9\%\_\-\.]} $url] } {
                    # url contains unencoded characters
                    set url [ad_urlencode $url]
                    set page_id ""
                }
                
                # Want to enforce unchangeable urls for pages?
                # If so, set url from db for template_id here.
            }
            ns_log Notice "q-wiki.tcl(226): url $url"
            # page_name is pretty version of url, cannot be blank
            if { $page_name eq "" } {
                set page_name $url
            } else {
                set page_name_length [parameter::get -package_id $package_id -parameter PageNameLen -default 40]
                incr page_name_length -1
                set page_name [string range $page_name 0 $page_name_length]
            }
            set validated_p 1
            ns_log Notice "q-wiki.tcl validated for $mode"
        } elseif { $read_p && $template_exists_p } {
            set mode v
            set next_mode ""
        } else {
            set mode ""
            set next_mode ""
        }
    }
    ns_log Notice "q-wiki.tcl(252): mode $mode next_mode $next_mode"
    if { $mode eq "l" } {
        if { $read_p } {
            set validated_p 1
            ns_log Notice "q-wiki.tcl validated for l"
        } else {
            set mode ""
            set next_mode ""
        }
    }
    ns_log Notice "q-wiki.tcl(262): mode $mode next_mode $next_mode"
    if { $mode eq "v" } {
        if { $read_p } {
            # url vetted previously
            set validated_p 1
            if { $page_id_from_url ne "" } {
                # page exists
            } else {
                set mode "l"
                ns_log Notice "q-wiki.tcl(405): mode = $mode ie. list of pages, index"
            }
        } else {
            set mode ""
            set next_mode ""
        }
    }

    # ACTIONS, PROCESSES / MODEL
    ns_log Notice "q-wiki.tcl(268): mode $mode next_mode $next_mode validated $validated_p"
    if { $validated_p } {
        ns_log Notice "q-wiki.tcl ACTION mode $mode validated_p 1"
        # execute process using validated input
        # IF is used instead of SWITCH, so multiple sub-modes can be processed in a single mode.
        if { $mode eq "d" } {
            #  delete.... removes context     
            ns_log Notice "q-wiki.tcl mode = delete"
            if { $delete_p } {
                qw_page_delete $page_id $page_template_id $package_id $user_id
#                qw_page_delete $page_id $page_template_id_from_url $package_id $user_id
            }
            set mode $next_mode
            set next_mode ""
        }
        ns_log Notice "q-wiki.tcl(358): mode $mode"
        if { $mode eq "a" } {
            # change active revision of page_template_id_from_url to page_id
            if { $write_p } {
                if { [qw_change_page_id_for_url $page_id $url $package_id] } {
                    set mode $next_mode
                    set page_id_from_url $page_id
                } else {
                    lappend user_message_list "Revision could not be made active. Try again or report issue to [ad_admin_owner]"
            util_user_message -message [lindex $user_message_list end]
                    set mode "r"
                }                    
            }
            set next_mode ""
        }
        ns_log Notice "q-wiki.tcl(344): mode $mode"
        if { $mode eq "t" } {
            #  toggle trash
            ns_log Notice "q-wiki.tcl mode = trash"
            # which page to trash page_id or page_id_from_url?
            if { $page_id ne "" } {
                set page_id_stats [qw_page_stats $page_id]
                set trashed_p [lindex $page_id_stats 7]
                set page_user_id [lindex $page_id_stats 11]
            } elseif { $page_template_id ne "" } {
                set page_id_stats [qw_page_stats $page_id_from_url]
                set trashed_p [lindex $page_id_stats 7]
                set page_user_id [lindex $page_id_stats 11]
            }
#            set template_id \[lindex $page_id_stats 5\]
            set trash_done_p 0
            if { $write_p || $page_user_id eq $user_id } {
                if { $trashed_p } {
                    set trash "0"
                } else {
                    set trash "1"
                }
                ns_log Notice "q-wiki.tcl(419): qw_page_trash page_id $page_id trash_p $trash templat_id $page_template_id"
                set trash_done_p [qw_page_trash $page_id $trash $page_template_id]
                set mode $next_mode
            } 
            if { !$trash_done_p } {
                lappend user_message_list "Item could not be trashed. You don't have permission to trash this item."
            util_user_message -message [lindex $user_message_list end]
            }
            set next_mode ""
            # update the page_id
            set page_id_from_url [qw_page_id_from_url $url $package_id]
            if { $page_id_from_url ne "" && $mode eq "" } {
                set mode "v"
            }
        }
        ns_log Notice "q-wiki.tcl(374): mode $mode"
        if { $mode eq "w" } {
            if { $write_p } {
                ns_log Notice "q-wiki.tcl permission to write the write.."
                set page_contents_quoted $page_contents
                set page_contents [ad_unquotehtml $page_contents]
                set allow_adp_tcl_p [parameter::get -package_id $package_id -parameter AllowADPTCL -default 0]
                set flagged_list [list ]
                
                if { $allow_adp_tcl_p } {
                    ns_log Notice "q-wki.tcl(311): adp tags allowed. Fine grain filtering.."
                    # filter page_contents for allowed and banned procs in adp tags
                    set banned_proc_list [split [parameter::get -package_id $package_id -parameter BannedProc]]
                    set allowed_proc_list [split [parameter::get -package_id $package_id -parameter AllowedProc]]
                    
                    set code_block_list [qf_get_contents_from_tags_list "<%" "%>" $page_contents]
                    foreach code_block $code_block_list {
                        # split into lines
                        set code_segments_list [split $code_block \n\r]
                        foreach code_segment $code_segments_list  {
                            # see filters in accounts-finance/tcl/modeling-procs.tcl for inspiration
                            # split at the beginning of each open square bracket
                            set executable_fragment_list [split $code_segment \[]
                            set executable_list [list ]
                            foreach executable_fragment $executable_fragment_list {
                                # right-clip to just the executable for screening purposes
                                set space_idx [string first " " $executable_fragment]
                                if { $space_idx > -1 } {
                                    set end_idx [expr { $space_idx - 1 } ]
                                    set executable [string range $executable_fragment 0 $end_idx]
                                } else {
                                    set executable $executable_fragment
                                }
                                # screen executable
                                if { $executable eq "" } {
                                    # skip an empty executable
                                    # ns_log Notice "q-wiki.tcl(395): executable is empty. Screening incomplete?"
                                } else {
                                    # see if this proc is allowed
                                    set proc_allowed_p 0
                                    foreach allowed_proc $allowed_proc_list {
                                        if { [string match $allowed_proc $executable] } {
                                            set proc_allowed_p 1
                                        }
                                    }
                                    # see if this proc is banned. Banned takes precedence over allowed.
                                    if { $proc_allowed_p } {
                                        foreach banned_proc $banned_proc_list {
                                            if { [string match $banned_proc $executable] } {
                                                # banned executable found
                                                set proc_allowed_p 0
                                                lappend flagged_list $executable
                                                lappend user_message_list "'$executable' is banned from use."
            util_user_message -message [lindex $user_message_list end]
                                            }
                                        }            
                                    } else {
                                        lappend flagged_list $executable
                                        lappend user_message_list "'$executable' is not allowed at this time."
            util_user_message -message [lindex $user_message_list end]
                                    }
                                }
                            }
                        }
                    }
                    if { [llength $flagged_list] == 0 } {
                        # content passed filters
                        set page_contents_filtered $page_contents
                    } else {
                        set page_contents_filtered $page_contents_quoted
                    }
                } else {
                    # filtering out all adp tags (allow_adp_tcl_p == 0)
                    ns_log Notice "q-wiki.tcl(358): filtering out adp tags"
                    # ns_log Notice "q-wiki.tcl(359): range page_contents 0 120: '[string range ${page_contents} 0 120]'"
                    set page_contents_list [qf_remove_tag_contents "<%" "%>" $page_contents]
                    set page_contents_filtered [join $page_contents_list ""]
                    # ns_log Notice "q-wiki.tcl(427): range page_contents_filtered 0 120: '[string range ${page_contents_filtered} 0 120]'"
                }
                # use $page_contents_filtered, was $page_contents
                set page_contents [ad_quotehtml $page_contents_filtered]
                
                if { [llength $flagged_list ] > 0 } {
                    ns_log Notice "q-wiki.tcl(369): content flagged, changing to edit mode."
                    set mode e
                } else {
                    # write the data
                    # a different user_id makes new context based on current context, otherwise modifies same context
                    # or create a new context if no context provided.
                    # given:

                    # create or write page
                    if { $page_id eq "" } {
                        # create page
                        set page_id [qw_page_create $url $page_name $page_title $page_contents_filtered $keywords $description $page_comments $page_template_id $page_flags $package_id $user_id]
                        if { $page_id == 0 } {
                            ns_log Warning "q-wiki/q-wiki.tcl page write error for url '${url}'"
                            lappend user_messag_list "There was an error creating the wiki page at '${url}'."
                        } else {
                            qwcl_page_create $package_id $page_id $model_ref $spec1ref $spec1type $spec1default $spec2ref $spec2type $spec2default $spec3ref $spec3type $spec3default $spec4ref $spec4type $spec4default $spec5ref $spec5type $spec5default $gallery_folder_id $price $dimensions $ship_wt $actual_wt $unit 
                        }
                    } else {
                        # write page
                        set page_id [qw_page_write $page_name $page_title $page_contents_filtered $keywords $description $page_comments $page_id $page_template_id $page_flags $package_id $user_id]
                        if { $page_id eq "" } {
                            ns_log Warning "q-wiki/q-wiki.tcl page write error for url '${url}'"
                            lappend user_messag_list "There was an error creating the wiki page at '${url}'."
                        } else {
                            qwcl_page_write $package_id $page_id $model_ref $spec1ref $spec1type $spec1default $spec2ref $spec2type $spec2default $spec3ref $spec3type $spec3default $spec4ref $spec4type $spec4default $spec5ref $spec5type $spec5default $gallery_folder_id $price $dimensions $ship_wt $actual_wt $unit 
                        }
                    }

                    # rename existing pages?
                    if { $url ne $page_name } {
                        # rename url, but first post the page
                        if { [qw_page_rename $url $page_name $package_id ] } {
                            # if success, update url and redirect
                            set redirect_before_v_p 1
                            set url $page_name
                            set next_mode "v"
                        }
                    }

                    # switch modes..
                    ns_log Notice "q-wiki.tcl(396): activating next mode $next_mode"
                    set mode $next_mode
                }
            } else {
                # does not have permission to write
                lappend user_message_list "Write operation could not be completed. You don't have permission."
            util_user_message -message [lindex $user_message_list end]
                ns_log Notice "q-wiki.tcl(402) User attempting to write content without permission."
                if { $read_p } {
                    set mode "v"
                } else {
                    set mode ""
                }
            }
            # end section of write
            set next_mode ""
        }
    }
} else {
    # form not posted
    ns_log Warning "q-wiki.tcl(451): Form not posted. This shouldn't happen via index.vuh."
}


#set menu_list \[list \[list Q-Wiki index\]\]
set menu_list [list ]

# OUTPUT / VIEW
# using switch, because there's only one view at a time
ns_log Notice "q-wiki.tcl(508): OUTPUT mode $mode"
switch -exact -- $mode {
    l {
        #  list...... presents a list of pages  (Branch this off as a procedure and/or lib page fragment to be called by view action)
        if { $read_p } {
            if { $redirect_before_v_p } {
                ns_log Notice "q-wiki.tcl(587): redirecting to url $url for clean url view"
                ad_returnredirect "$url?mode=l"
                ad_script_abort
            }

            ns_log Notice "q-wiki.tcl(427): mode = $mode ie. list of pages, index"
            if { $write_p } {
                lappend menu_list [list edit "${url}?mode=e" ]
            }

            append title " index" 
            # show page
            # sort by template_id, columns
            
            set page_ids_list [qw_pages $package_id]
            set pages_stats_lists [list ]
            # we get the entire data set, 1 row(list) per page as table pages_stats_lists
            foreach page_id $page_ids_list {
                set stats_mod_list [list $page_id]
                set stats_orig_list [qw_page_stats $page_id]
                #   a list: name, title, comments, keywords, description, template_id, flags, trashed, popularity, time last_modified, time created, user_id
                foreach stat $stats_orig_list {
                    lappend stats_mod_list $stat
                }
                lappend stats_mod_list [qw_page_url_from_id $page_id]
                # new: page_id, name, title, comments, keywords, description, template_id, flags, trashed, popularity, time last_modified, time created, user_id, url
                lappend pages_stats_lists $stats_mod_list
            }
            # new: page_id, name, title, comments, keywords, description, template_id, flags, trashed, popularity, time last_modified, time created, user_id, url
            set pages_stats_lists [lsort -index 1 $pages_stats_lists]
            # build tables (list_of_lists) stats_list and their html filtered versions page_*_lists for display
            set page_scratch_lists [list]
            set page_stats_lists [list ]
            set page_trashed_lists [list ]

            foreach stats_mod_list $pages_stats_lists {
                set stats_list [lrange $stats_mod_list 0 2]
                lappend stats_list [lindex $stats_mod_list 5]
                if { $write_p } {
                    lappend stats_list [lindex $stats_mod_list 3]
                } else {
                    lappend status_list ""
                }
                set page_id [lindex $stats_mod_list 0]
                set name [lindex $stats_mod_list 1]
                set template_id [lindex $stats_mod_list 6]
                set page_user_id [lindex $stats_mod_list 12]
                set trashed_p [lindex $stats_mod_list 8]
                set page_url [lindex $stats_mod_list 13]

                # convert stats_list for use with html

                # change Name to an active link and add actions if available
                set active_link "<a href=\"${page_url}\">$name</a>"
                set active_link_list [list $active_link]
                set active_link2 ""

                if {  $write_p } {
                    # trash the page
                    if { $trashed_p } {
                        set active_link2 " <a href=\"${page_url}?page_template_id=${template_id}&mode=t&next_mode=l\"><img src=\"${untrash_icon_url}\" alt=\"untrash\" title=\"untrash\" width=\"16\" height=\"16\"></a>"
                    } else {
                        set active_link2 " <a href=\"${page_url}?page_template_id=${template_id}&mode=t&next_mode=l\"><img src=\"${trash_icon_url}\" alt=\"trash\" title=\"trash\" width=\"16\" height=\"16\"></a>"
                    }
                } elseif { $page_user_id == $user_id } {
                    # trash the revision
                    if { $trashed_p } {
                        set active_link2 " <a href=\"${page_url}?page_id=${page_id}&mode=t&next_mode=l\"><img src=\"${untrash_icon_url}\" alt=\"untrash\" title=\"untrash\" width=\"16\" height=\"16\"></a>"
                    } else {
                        set active_link2 " <a href=\"${page_url}?page_id=${page_id}&mode=t&next_mode=l\"><img src=\"${trash_icon_url}\" alt=\"trash\" title=\"trash\" width=\"16\" height=\"16\"></a>"
                    }
                } 

                if { $delete_p && $trashed_p } {
                    append active_link2 " &nbsp; &nbsp; <a href=\"${page_url}?page_template_id=${template_id}&mode=d&next_mode=l\"><img src=\"${delete_icon_url}\" alt=\"delete\" title=\"delete\" width=\"16\" height=\"16\"></a> &nbsp; "
                } 
                set stats_list [lreplace $stats_list 0 0 $active_link]
                set stats_list [lreplace $stats_list 1 1 $active_link2]

                # add stats_list to one of the tables for display
                if { $trashed_p && ( $write_p || $page_user_id eq $user_id ) } {
                    lappend page_trashed_lists $stats_list
                } elseif { $trashed_p } {
                    # ignore this row, but track for errors
                } else {
                    lappend page_stats_lists $stats_list
                }
            }

            # convert table (list_of_lists) to html table
            set page_stats_sorted_lists $page_stats_lists
            if { $write_p } {
                set page_stats_sorted_lists [linsert $page_stats_sorted_lists 0 [list Name "&nbsp;" Title Description Comments] ]
            } else {
                set page_stats_sorted_lists [linsert $page_stats_sorted_lists 0 [list Name "&nbsp;" Title Description ""] ]
            }
            set page_tag_atts_list [list border 0 cellspacing 0 cellpadding 3]
            set cell_formating_list [list ]
            set page_stats_html [qss_list_of_lists_to_html_table $page_stats_sorted_lists $page_tag_atts_list $cell_formating_list]
            # trashed table
            if { [llength $page_trashed_lists] > 0 } {
                set page_trashed_sorted_lists $page_trashed_lists
                if { $write_p } {
                    set page_trashed_sorted_lists [linsert $page_trashed_sorted_lists 0 [list Name "&nbsp;" Title Description Comments] ]
                } else {
                    set page_trashed_sorted_lists [linsert $page_trashed_sorted_lists 0 [list Name "&nbsp;" Title Description ""] ]
                }
                set page_tag_atts_list [list border 0 cellspacing 0 cellpadding 3]
                
                set page_trashed_html [qss_list_of_lists_to_html_table $page_trashed_sorted_lists $page_tag_atts_list $cell_formating_list]
            }
        } else {
            # does not have permission to read. This should not happen.
            ns_log Warning "q-wiki.tcl:(465) user did not get expected 404 error when not able to read page."
        }
    }
    r {
        #  revisions...... presents a list of page revisions
            lappend menu_list [list index "index?mode=l"]

        if { $write_p } {
            ns_log Notice "q-wiki.tcl mode = $mode ie. revisions"
            # build menu options
            lappend menu_list [list edit "${url}?mode=e" ]
            
            # show page revisions
            # sort by template_id, columns
            set template_id $page_template_id_from_url
            # these should be sorted by last_modified
            set page_ids_list [qw_pages $package_id $user_id $template_id]

            set pages_stats_lists [list ]
            # we get the entire data set, 1 row(list) per revision as table pages_stats_lists
            # url is same for each
            set page_id_active [qw_page_id_from_url $url $package_id]
            foreach list_page_id $page_ids_list {
                set stats_mod_list [list $list_page_id]
                set stats_orig_list [qw_page_stats $list_page_id]
                set page_list [qw_page_read $list_page_id]
                #   a list: name, title, comments, keywords, description, template_id, flags, trashed, popularity, time last_modified, time created, user_id
                foreach stat $stats_orig_list {
                    lappend stats_mod_list $stat
                }
                lappend stats_mod_list $url
                lappend stats_mod_list [string length [lindex $page_list 11]]
                lappend stats_mod_list [expr { $list_page_id == $page_id_active } ]
                # new: page_id, name, title, comments, keywords, description, template_id, flags, trashed, popularity, time last_modified, time created, user_id, url, content_length, active_revision
                lappend pages_stats_lists $stats_mod_list
            }
            # build tables (list_of_lists) stats_list and their html filtered versions page_*_lists for display
            set page_stats_lists [list ]

            # stats_list should contain page_id, user_id, size (string_length) ,last_modified, comments,flags, live_revision_p, trashed? , actions: untrash delete

            set contributor_nbr 0
            set contributor_last_id ""
            set page_name [lindex [lindex $pages_stats_lists 0] 1]
            append title "${page_name} - page revisions"

            foreach stats_mod_list $pages_stats_lists {
                set stats_list [list]
                # create these vars:
                set index_list [list page_id 0 page_user_id 12 size 14 last_modified 10 created 11 comments 3 flags 7 live_revision_p 15 trashed_p 8]
                foreach {list_item_name list_item_index} $index_list {
                    set list_item_value [lindex $stats_mod_list $list_item_index]
                    set $list_item_name $list_item_value
                    lappend stats_list $list_item_value
                }
                # convert stats_list for use with html

                set active_link "<a href=\"${url}?page_id=$page_id&mode=e\">${page_id}</a>"
                set stats_list [lreplace $stats_list 0 0 $active_link]

                if { $page_user_id ne $contributor_last_id } {
                    set contributor_last_id $page_user_id
                    incr contributor_nbr
                }
                set contributor_title ${contributor_nbr}
                set active_link3 " &nbsp; <a href=\"/shared/community-member?user_id=${page_user_id}\" title=\"page contributor ${contributor_title}\">${contributor_title}</a>"
                set stats_list [lreplace $stats_list 1 1 $active_link3]

                if { $live_revision_p } {
                        # no links or actions. It's live, whatever its status
                    if { $trashed_p } {
                        set stats_list [lreplace $stats_list 7 7 "<img src=\"${radio_unchecked_url}\" alt=\"inactive\" title=\"inactive\" width=\"13\" height=\"13\">"]
                    } else {
                        set stats_list [lreplace $stats_list 7 7 "<img src=\"${radio_checked_url}\" alt=\"active\" title=\"active\" width=\"13\" height=\"13\">"]
                    }
                } else {
                    if { $trashed_p } {
                        set stats_list [lreplace $stats_list 7 7 "&nbsp;"]   
                    } else {
                        # it's untrashed, user can make it live.
                        set stats_list [lreplace $stats_list 7 7 "<a href=\"$url?page_id=${page_id}&mode=a&next_mode=r\"><img src=\"${radio_unchecked_url}\" alt=\"activate\" title=\"activate\" width=\"13\" height=\"13\"></a>"]
                    }
                } 

                set active_link_list [list $active_link]
                set active_link2 ""
                if { ( $write_p || $page_user_id == $user_id ) && $trashed_p } {
                    set active_link2 " <a href=\"${url}?page_id=${page_id}&mode=t&next_mode=r\"><img src=\"${untrash_icon_url}\" alt=\"untrash\" title=\"untrash\" width=\"16\" height=\"16\"></a>"
                } elseif { $page_user_id == $user_id || $write_p } {
                    set active_link2 " <a href=\"${url}?page_id=${page_id}&mode=t&next_mode=r\"><img src=\"${trash_icon_url}\" alt=\"trash\" title=\"trash\" width=\"16\" height=\"16\"></a>"
                } 
                if { ( $delete_p || $page_user_id == $user_id ) && $trashed_p } {
                    append active_link2 " &nbsp; &nbsp; <a href=\"${url}?page_id=${page_id}&mode=d&next_mode=r\"><img src=\"${delete_icon_url}\" alt=\"delete\" title=\"delete\" width=\"16\" height=\"16\"></a> &nbsp; "
                } 
                set stats_list [lreplace $stats_list 8 8 $active_link2]



                # if the user can delete or trash this stats_list, display it.
                if { $write_p || $page_user_id eq $user_id } {
                    lappend page_stats_lists $stats_list
                } 
            }

            # convert table (list_of_lists) to html table
            set page_stats_sorted_lists $page_stats_lists
            set page_stats_sorted_lists [linsert $page_stats_sorted_lists 0 [list "ID" "Contributor" "Length" "Last Modified" "Created" "Comments" "Flags" "Live?" "Trash status"] ]
            set page_tag_atts_list [list border 0 cellspacing 0 cellpadding 3]
            set cell_formating_list [list ]
            set page_stats_html [qss_list_of_lists_to_html_table $page_stats_sorted_lists $page_tag_atts_list $cell_formating_list]
        } else {
            # does not have permission to read. This should not happen.
            ns_log Warning "q-wiki.tcl:(465) user did not get expected 404 error when not able to read page."
        }

    }
    e {


        if { $write_p } {
            #  edit...... edit/form mode of current context

            ns_log Notice "q-wiki.tcl mode = edit"
            set cancel_link_html "<a href=\"list?mode=l\">Cancel</a>"

            # for existing pages, add template_id
            set conn_package_url [ad_conn package_url]
            set post_url [file join $conn_package_url $url]

            ns_log Notice "q-wiki.tcl(636): conn_package_url $conn_package_url post_url $post_url"
            if { $page_id_from_url ne "" && [llength $user_message_list ] == 0 } {

                # get page info
                set page_list [qw_page_read $page_id_from_url $package_id $user_id ]
                set page_name [lindex $page_list 0]
                set page_title [lindex $page_list 1]
                set keywords [lindex $page_list 2]
                set description [lindex $page_list 3]
                set page_template_id [lindex $page_list 4]
                set page_flags [lindex $page_list 5]
                set page_contents [lindex $page_list 11]
                set page_comments [lindex $page_list 12]

                set page_bw_list [qwcl_page_read $page_id_from_url $package_id]
                # model_ref, spec1ref, spec1type, spec1default, spec2ref, spec2type, spec2default, spec3ref, spec3type, spec3default, spec4ref, spec4type, spec4default,  spec5ref, spec5type, spec5default,gallery_folder_id, price, dimensions, ship_wt, actual_wt, unit 
                set model_ref [lindex $page_bw_list 0]
                set spec1ref [lindex $page_bw_list 1]
                set spec1type [lindex $page_bw_list 2]
                set spec1default [lindex $page_bw_list 3]
                set spec2ref [lindex $page_bw_list 4]
                set spec2type [lindex $page_bw_list 5]
                set spec2default [lindex $page_bw_list 6]
                set spec3ref [lindex $page_bw_list 7]
                set spec3type [lindex $page_bw_list 8]
                set spec3default [lindex $page_bw_list 9]
                set spec4ref [lindex $page_bw_list 10]
                set spec4type [lindex $page_bw_list 11]
                set spec4default [lindex $page_bw_list 12]
                set spec5ref [lindex $page_bw_list 13]
                set spec5type [lindex $page_bw_list 14]
                set spec5default [lindex $page_bw_list 15]
                set gallery_folder_id [lindex $page_bw_list 16]
                set price [lindex $page_bw_list 17]
                set dimensions [lindex $page_bw_list 18]
                set ship_wt [lindex $page_bw_list 19]
                set actual_wt [lindex $page_bw_list 20]
                set unit [lindex $page_bw_list 21]

                set cancel_link_html "<a href=\"$page_name\">Cancel</a>"
            } 
           
            append title "${page_name} -  edit"

            set rows_list [split $page_contents "\n\r"]
            set rows_max [llength $rows_list]
            set columns_max 40
            foreach row $rows_list {
                set col_len [string length $row]
                if { $col_len > $columns_max } {
                    set columns_max $col_len
                }
            }
            if { $rows_max > 200 } {
                set rows_max [expr { int( sqrt( hypot( $columns_max, $rows_max ) ) ) } ]
            }
            set columns_max [f::min 200 $columns_max]
            set rows_max [f::min 800 $rows_max]
            set rows_max [f::max $rows_max 6]

            qf_form action $post_url method post id 20130309 hash_check 1
            qf_input type hidden value w name mode
            qf_input type hidden value v name next_mode
            qf_input type hidden value $page_flags name page_flags
            qf_input type hidden value $page_template_id name page_template_id
            #        qf_input type hidden value $page_id name page_id label ""
            qf_append html "<h3>Q-Wiki page edit</h3>"
            qf_append html "<div style=\"width: 70%; text-align: right;\">"
            qf_append html "<p>Name is the page name. It's the last word in a url: http://mywebsite.com/name</p>"
            set page_name_unquoted [ad_unquotehtml $page_name]
            qf_input type text value $page_name_unquoted name page_name label "Page Name:" size 40 maxlength 40
            qf_append html "<br>"
            set page_title_unquoted [ad_unquotehtml $page_title]
            qf_input type text value $page_title_unquoted name page_title label "Page Title:" size 40 maxlength 80
            qf_append html "<br>"
            qf_append html "<p>Description is a short description about the page that is used by search engines and indexes.</p>"
            set description_unquoted [ad_unquotehtml $description]
            qf_textarea value $description_unquoted cols 40 rows 1 name description label "Page Description:"
            qf_append html "<br>"
            qf_append html "<p>Comments is a place to share comments with other page editors. It isn't published.</p>"
            set page_comments_unquoted [ad_unquotehtml $page_comments]
            qf_textarea value $page_comments_unquoted cols 40 rows 3 name page_comments label "Comments:"
            qf_append html "<br>"
            set page_contents_unquoted [ad_unquotehtml $page_contents]
            qf_textarea value $page_contents_unquoted cols $columns_max rows $rows_max name page_contents label "Published page contents:"
            qf_append html "<br>"
            set keywords_unquoted [ad_unquotehtml $keywords]
            qf_input type text value $keywords_unquoted name keywords label "Keywords:" size 40 maxlength 80
            qf_append html "<br>"
            qf_append html "<p>'Model ref' is the unique acronym given each product ie the first part of the sku.</p>"
            set model_ref_unquoted [ad_unquotehtml $model_ref]
            qf_input type text value $model_ref_unquoted name model_ref label "Model ref:" size 40 maxlength 80
            qf_append html "<br>"
            qf_append html "<p>'spec# ref' is the label that shows up with the product option.</p>"
            set spec1ref_unquoted [ad_unquotehtml $spec1ref]
            qf_input type text value $spec1ref_unquoted name spec1ref label "Spec1 ref:" size 40 maxlength 80
            qf_append html "<br>"
            qf_append html "<p>The spec references are added to the Model Reference to become the SKU. Widgets are used to ask buyers for their choice. Available widgets are: <span style=\"background-color: yellow;\">colors</span>, <span style=\"background-color: yellow;\">numbers</span>, <span style=\"background-color: yellow;\">select1</span> (choose 1 of a list of words), "
            qf_append html "<span style=\"background-color: yellow;\">selectn</span> (choose as many of the words as you want). Use the following formats in the 'spec# type' box; Literal examples are in grey:</p> "
            qf_append html "<ul><li><span style=\"background-color: #999999;\">colors</span>, </li><li><span style=\"background-color: #999999;\">numbers 1 10 1</span> {first last (increment)}, </li><li><span style=\"background-color: #999999;\">select1 XS S M L XL XLT XXL cherry pine cedar</span> {list of words with spaces between}, </li>"
            qf_append html "<li><span style=\"background-color: #999999;\">selectn sunflower hulled-sunflower thistle millet safflower cracked-corn nuts</span> {list of words with spaces between}</li>"
            qf_append html "</ul><p>These are examples. The braces show what you are expected to include; colors doesn't use any extra parameters. Numbers assumes that you want to step by 1 if you don't include the increment number. select1 can be used to answer yes/no or other single choice requests, such as selecting wood types:</p>"
            set spec1type_unquoted [ad_unquotehtml $spec1type]
            qf_input type text value $spec1type_unquoted name spec1type label "Spec1 type:" size 40 maxlength 80
            qf_append html "<br>"
            qf_append html "<p>'spec# default value' is the choice made for the customer before they choose. It's the default, unless they choose another option. For colors, choose one of the available color references, such as 'RED'</p>"
            set spec1default_unquoted [ad_unquotehtml $spec1default]
            qf_input type text value $spec1default_unquoted name spec1default label "Spec1 default value:" size 40 maxlength 80
            qf_append html "<br>"
            qf_append html "<p>Spec2 is for a second product option. There are 5 available options per product. Leave blank the extra options. None of the options affect the cart price. We can add this feature, if you want it (Allow a few weeks..)</p>"
            set spec2ref_unquoted [ad_unquotehtml $spec2ref]
            qf_input type text value $spec2ref_unquoted name spec2ref label "Spec2 ref:" size 40 maxlength 80
            qf_append html "<br>"
            set spec2type_unquoted [ad_unquotehtml $spec2type]
            qf_input type text value $spec2type_unquoted name spec2type label "Spec2 type:" size 40 maxlength 80
            qf_append html "<br>"
            set spec2default_unquoted [ad_unquotehtml $spec2default]
            qf_input type text value $spec2default_unquoted name spec2default label "Spec2 default value:" size 40 maxlength 80
            qf_append html "<br>"
            set spec3ref_unquoted [ad_unquotehtml $spec3ref]
            qf_input type text value $spec3ref_unquoted name spec3ref label "Spec3 ref:" size 40 maxlength 80
            qf_append html "<br>"
            set spec3type_unquoted [ad_unquotehtml $spec3type]
            qf_input type text value $spec3type_unquoted name spec3type label "Spec3 type:" size 40 maxlength 80
            qf_append html "<br>"
            set spec3default_unquoted [ad_unquotehtml $spec3default]
            qf_input type text value $spec3default_unquoted name spec3default label "Spec3 default value:" size 40 maxlength 80
            qf_append html "<br>"
            set spec4ref_unquoted [ad_unquotehtml $spec4ref]
            qf_input type text value $spec4ref_unquoted name spec4ref label "Spec4 ref:" size 40 maxlength 80
            qf_append html "<br>"
            set spec4type_unquoted [ad_unquotehtml $spec4type]
            qf_input type text value $spec4type_unquoted name spec4type label "Spec4 type:" size 40 maxlength 80
            qf_append html "<br>"
            set spec4default_unquoted [ad_unquotehtml $spec4default]
            qf_input type text value $spec4default_unquoted name spec4default label "Spec4 default value:" size 40 maxlength 80
            qf_append html "<br>"
            set spec5ref_unquoted [ad_unquotehtml $spec5ref]
            qf_input type text value $spec5ref_unquoted name spec5ref label "Spec5 ref:" size 40 maxlength 80
            qf_append html "<br>"
            set spec5type_unquoted [ad_unquotehtml $spec5type]
            qf_input type text value $spec5type_unquoted name spec5type label "Spec5 type:" size 40 maxlength 80
            qf_append html "<br>"
            set spec5default_unquoted [ad_unquotehtml $spec5default]
            qf_input type text value $spec5default_unquoted name spec5default label "Spec5 default value:" size 40 maxlength 80
            qf_append html "<br>"

            set gallery_package_id [parameter::get -parameter PhotoAlbumPkgId -package_id $package_id]
            if { $gallery_package_id ne "" } {
                set root_folder_id [parameter::get -parameter RootFolderId -package_id $package_id]
                # query can accept these without changes: item_id,name,description,type,ordering_key,iconic,width,height
                set albums_list_of_lists [db_list_of_lists albums_get { select item_id,name,description,type,ordering_key,iconic,width,height
                    from ( select i.item_id,
                           r.title as name,
                           r.description,
                           'Album' as type,
                           1 as ordering_key,
                           ic.image_id as iconic,
                           ic.width as width,
                           ic.height as height
                           from   cr_items i, cr_revisions r,
                           pa_albums a left outer join all_photo_images ic
                           on (ic.item_id = a.iconic and ic.relation_tag='thumb')
                           where i.content_type = 'pa_album'
                           and i.parent_id     = :root_folder_id
                           and i.live_revision = r.revision_id
                           and a.pa_album_id = i.live_revision
                           UNION ALL
                           select i.item_id,
                           f.label as name,
                           f.description,
                           'Folder',
                           0,
                           null as iconic,0,0
                           from cr_items i,
                           cr_folders f
                           where i.parent_id = :root_folder_id      
                           and i.item_id = f.folder_id
                           ) as x 
                    where acs_permission__permission_p(item_id, :user_id, 'read') = 't'
                    order by ordering_key,name } ]
                # build a select bar using item_id, name
                set folder_select_list [list [list value "" label "none"]]
                foreach folder_list $albums_list_of_lists {
                    # folder_list: item_id,name,description,type,ordering_key,iconic,width,height
                    # for qf_choice type select name spec1value value $spec1val_list class input
                    # using:  lappend select1_list \[list "value" $option "label" $option "selected" 1\]
                    set folder_item_id [lindex $folder_list 0]
                    set folder_name [lindex $folder_list 1]
                    set none_selected 1
                    if { $none_selected && $folder_item_id eq $gallery_folder_id } {
                        lappend folder_select_list [list "value" $folder_item_id "label" $folder_name "selected" 1]
                        set none_selected 0
                    } else {
                        lappend folder_select_list [list "value" $folder_item_id "label" $folder_name]
                    }
                }
                qf_append html "<p>Reference the gallery associated with the product:</p>"
                qf_append html "Gallery album:"
                qf_choice type select name gallery_folder_id value $folder_select_list class input

            } else {
                qf_append html "d<p>Reference the gallery album_id associated with the product, or leave blank:</p>"
                set gallery_folder_id_unquoted \[ad_unquotehtml $gallery_folder_id\]
                qf_input type text value $gallery_folder_id_unquoted name gallery_folder_id label "Gallery album_id:" size 40 maxlength 80
            }
            
            qf_append html "<br>"
            set price_unquoted [ad_unquotehtml $price]
            qf_input type text value $price_unquoted name price label "Price:" size 40 maxlength 80
            qf_append html "<br>"
            set dimensions_unquoted [ad_unquotehtml $dimensions]
            qf_input type text value $dimensions_unquoted name dimensions label "Dimensions:" size 40 maxlength 80
            qf_append html "<br>"
            qf_append html "<br>Shipping weight in decimal pounds, 5.5 for example.<br>"
            set ship_wt_unquoted [ad_unquotehtml $ship_wt]
            qf_input type text value $ship_wt_unquoted name ship_wt label "Shipping weight:" size 40 maxlength 80
            qf_append html "<br>"
            qf_append html "<br>Actual weight in human readable pounds, '5 lb 8 oz' for example.<br>"
            set actual_wt_unquoted [ad_unquotehtml $actual_wt]
            qf_input type text value $actual_wt_unquoted name actual_wt label "Actual weight:" size 40 maxlength 80
            qf_append html "<br>"
            set unit_unquoted [ad_unquotehtml $unit]
            qf_input type text value $unit_unquoted name unit label "Unit:" size 40 maxlength 80
#            qf_append html "<br>"

            qf_append html "</div>"
            qf_input type submit value "Save"
            qf_append html " &nbsp; &nbsp; &nbsp; ${cancel_link_html}"
            qf_close

            set form_html [qf_read]
        } else {
            lappend user_message_list "Edit operation could not be completed. You don't have permission."
            util_user_message -message [lindex $user_message_list end]
        }
    }
    v {
        #  view page(s) (standard, html page document/report)
        if { $read_p } {
            # if $url is different than ad_conn url stem, 303/305 redirect to page_id's primary url
            
            if { $redirect_before_v_p } {
                ns_log Notice "q-wiki.tcl(835): redirecting to url $url for clean url view"
                ad_returnredirect $url
                ad_script_abort
            }
            ns_log Notice "q-wiki.tcl(667): mode = $mode ie. view"

            lappend menu_list [list index "index?mode=l"]

            # get page info
            set conn_package_url [ad_conn package_url]
            set post_url [file join $conn_package_url $url]
            set cancel_link_html "<a href=\"${page_name}\">Reset</a>"

            if { $page_id eq "" } {
                # cannot use previous $page_id_from_url, because it might be modified from an ACTION
                # Get it again.
                set page_id_from_url [qw_page_id_from_url $url $package_id]
                set page_list [qw_page_read $page_id_from_url $package_id $user_id ]
                set page_bw_list [qwcl_page_read $page_id_from_url $package_id]
            } else {
                set page_list [qw_page_read $page_id $package_id $user_id ]
                set page_bw_list [qwcl_page_read $page_id $package_id]
            }

            if { $create_p } {
                if { $page_id_from_url ne "" || $page_id ne "" } {
                    lappend menu_list [list revisions "${url}?mode=r"]
                } 
                lappend menu_list [list edit "${url}?mode=e" ]
            }


            if { [llength $page_list] > 1 } {
                set page_title [lindex $page_list 1]
                set keywords [lindex $page_list 2]
                set description [lindex $page_list 3]
                set page_contents [lindex $page_list 11]
                set trashed_p [lindex $page_list 6]
                set template_id [lindex $page_list 4]
       

                # model_ref, spec1ref, spec1type, spec1default, spec2ref, spec2type, spec2default, spec3ref, spec3type, spec3default, spec4ref, spec4type, spec4default,  spec5ref, spec5type, spec5default,gallery_folder_id, price, dimensions, ship_wt, actual_wt, unit 
                set model_ref [lindex $page_bw_list 0]
                set spec1ref [lindex $page_bw_list 1]
                set spec1type [lindex $page_bw_list 2]
                set spec1default [lindex $page_bw_list 3]
                set spec2ref [lindex $page_bw_list 4]
                set spec2type [lindex $page_bw_list 5]
                set spec2default [lindex $page_bw_list 6]
                set spec3ref [lindex $page_bw_list 7]
                set spec3type [lindex $page_bw_list 8]
                set spec3default [lindex $page_bw_list 9]
                set spec4ref [lindex $page_bw_list 10]
                set spec4type [lindex $page_bw_list 11]
                set spec4default [lindex $page_bw_list 12]
                set spec5ref [lindex $page_bw_list 13]
                set spec5type [lindex $page_bw_list 14]
                set spec5default [lindex $page_bw_list 15]
                set gallery_folder_id [lindex $page_bw_list 16]
                set price [lindex $page_bw_list 17]
                set dimensions [lindex $page_bw_list 18]
                set ship_wt [lindex $page_bw_list 19]
                set actual_wt [lindex $page_bw_list 20]
                set unit [lindex $page_bw_list 21]

         # trashed pages cannot be viewed by public, but can be viewed with permission
                if { $delete_p && $trashed_p } {
                    lappend menu_list [list delete "${url}?mode=d&next_mode=l&page_template_id=${template_id}" ]
                } elseif { $delete_p && !$trashed_p } {
                    lappend menu_list [list trash "${url}?mode=t&next_mode=v&page_template_id=${template_id}" ]
                }
                
                if { $keywords ne "" } {
                template::head::add_meta -name keywords -content $keywords
                }
                if { $description ne "" } {
                    template::head::add_meta -name description -content $description
                }
                set title $page_title

                # page_contents_filtered
                set page_contents_unquoted [ad_unquotehtml $page_contents]

                if { $gallery_folder_id ne "" && $gallery_package_id ne "" } {
                    set album_id $gallery_folder_id
#                    set album_id 2452
                    if { $photo_id eq "" } {
                        set nav_album_photo_list [pa_all_photos_in_album $album_id]
                        set photo_id [lindex $nav_album_photo_list 0]
                    }
                    set form_id_html "test"

                }
#---- insert extended view
#  When extending, you can insert values here, or reference with an include via q-wiki.adp
# such as this included example: <include src=/www/product model=${model_ref}>
# alternately, one could treat the extended fields similar to the wiki ones.
# for this example, uncomment these lines:

                if { $model_ref eq "" } {
                    set model_ref [lindex $page_list 0]
                }
#                set spec1ref [lindex $page_bw_list 1]
#                set spec1default [lindex $page_bw_list 2]



# product customization form
                set currency_code "USD"
                set weight_unit "lbs"
                set paypal_business_ref "Your-paypal-biz-ref-here"
                set thankyou_url [ad_url]
                if { [string range $thankyou_url end end] ne "/" } {
                    append thankyou_url "/"
                }
                append thankyou_url "paypal-thank-you"
                set sku $model_ref
                set sku_name $title
                set form_html ""

                if { $spec1ref ne "" } {
                    qf_form action $post_url method post id 20130808
                    qf_input type hidden value v name mode
                    qf_input type hidden value v name next_mode
                    qf_input type hidden value $page_template_id name page_template_id
                    ### if spec1ref ne "" , qf_append spec1html..
                    
                    set spec1val_list [qwcl_spectype_widget 1 $spec1ref $spec1type $spec1default [ad_unquotehtml $spec1value]]
                    if { [llength $spec1val_list] > 0 } {
                        if { $spec1value eq "" } {
                            set spec1value $spec1default
                        }
                        regsub { } $spec1value {,} spec1skuval
                        append sku "-$spec1skuval"
                        append sku_name ", $spec1ref $spec1value"
                        qf_append html "<p>$spec1ref: "
                        if { [string range $spec1type 0 6] eq "selectn" } {
                            qf_choices type checkbox name spec1value value $spec1val_list class input
                        } else {
                            qf_choice type select name spec1value value $spec1val_list class input
                        }
                        qf_append html "</p>"
                    }
                    #                set spec2ref [lindex $page_bw_list 3]
                    #                set spec2default [lindex $page_bw_list 4]
                    set spec2val_list [qwcl_spectype_widget 2 $spec2ref $spec2type $spec2default [ad_unquotehtml $spec2value]]
                    if { [llength $spec2val_list] > 0 } {
                        if { $spec2value eq "" } {
                            set spec2value $spec2default
                        }
                        regsub { } $spec2value {,} spec2skuval
                        append sku "-$spec2skuval"
                        append sku_name ", $spec2ref $spec2value"
                        qf_append html "<p>$spec2ref: "
                        if { $spec2type eq "selectn" } {
                            qf_choices type checkbox name spec2value value $spec2val_list class input
                        } else {
                            qf_choice type select name spec2value value $spec2val_list class input
                        }
                        qf_append html "</p>"
                    }
                    #                set spec3ref [lindex $page_bw_list 5]
                    #                set spec3default [lindex $page_bw_list 6]
                    set spec3val_list [qwcl_spectype_widget 3 $spec3ref $spec3type $spec3default [ad_unquotehtml $spec3value]]
                    if { [llength $spec3val_list] > 0 } {
                        if { $spec3value eq "" } {
                            set spec3value $spec3default
                        }
                        regsub { } $spec3value {,} spec3skuval
                        append sku "-$spec3skuval"
                        append sku_name ", $spec3ref $spec3value"
                        qf_append html "<p>$spec3ref: "
                        if { [string range $spec3type 0 6] eq "selectn" } {
                            qf_choices type checkbox name spec3value value $spec3val_list class input
                        } else {
                            qf_choice type select name spec3value value $spec3val_list class input
                        }
                        qf_append html "</p>"
                    }
                    
                    set spec4val_list [qwcl_spectype_widget 4 $spec4ref $spec4type $spec4default [ad_unquotehtml $spec4value]]
                    if { [llength $spec4val_list] > 0 } {
                        if { $spec4value eq "" } {
                            set spec4value $spec4default
                        }
                        regsub { } $spec4value {,} spec4skuval
                        append sku "-$spec4skuval"
                        append sku_name ", $spec4ref $spec4value"
                        qf_append html "<p>$spec4ref: "
                        if { [string range $spec4type 0 6] eq "selectn" } {
                            qf_choices type select checkbox spec4value value $spec4val_list class input
                        } else {
                            qf_choice type select name spec4value value $spec4val_list class input
                        }
                        qf_append html "</p>"
                    }
                    
                    set spec5val_list [qwcl_spectype_widget 5 $spec5ref $spec5type $spec5default [ad_unquotehtml $spec5value]]
                    if { [llength $spec5val_list] > 0 } {
                        if { $spec5value eq "" } {
                            set spec5value $spec5default
                        }
                        regsub { } $spec5value {,} spec5skuval
                        append sku "-$spec5skuval"
                        append sku_name ", $spec5ref $spec5value"
                        qf_append html "<p>$spec5ref: "
                        if {  [string range $spec5type 0 6] eq "selectn" } {
                            qf_choices type checkbox name spec5value value $spec5val_list class input
                        } else {
                            qf_choice type select name spec5value value $spec5val_list class input
                        }
                        qf_append html "</p>"
                    }
                    
                    qf_input type image value "Submit" src "http://birdswelcome.com/resources/update-button.png" alt "Click UPDATE to refresh the page with your choice(s)"
                    #qf_input type submit value "Save"
                    qf_append html " &nbsp; &nbsp; &nbsp; ${cancel_link_html} <br>"
                    qf_close
                    append form_html [qf_read]
                } 

                if { $price ne "" && $price > 0 } {
                    append form_html "<p>Product: <br>&nbsp;${sku_name}</p>"
                    append form_html "<p>sku#: <br>&nbsp;$sku</p>"
                    set price_pretty [format %6.2f $price]
                    append form_html "<p>price: $ ${price_pretty}</p>"
                    append form_html "<p>dimensions: <br>&nbsp;$dimensions"
                    append form_html "<br>weight: ${actual_wt}</p>"
                    append form_html [ecbw_paypal_checkout_button $sku $sku_name $price_pretty 0 $ship_wt $paypal_business_ref $thankyou_url]
                }
#                set image_name [lindex $page_bw_list 7]
#                set image_width [lindex $page_bw_list 8]
#                set image_height [lindex $page_bw_list 9]
#                set thumbnail_name [lindex $page_bw_list 10]
#                set thumbnail_width [lindex $page_bw_list 11]
#                set thumbnail_height [lindex $page_bw_list 12]
#                set price [lindex $page_bw_list 13]
#                set dimensions [lindex $page_bw_list 14]
#                set ship_wt [lindex $page_bw_list 15]
#                set actual_wt [lindex $page_bw_list 16]
#                set unit [lindex $page_bw_list 17]

#                append page_contents_unquoted "<br>Model ref: $model_ref <br>"
#                append page_contents_unquoted "Spec1 ref: $spec1ref <br>"
#                append page_contents_unquoted "Spec1 default $spec1default <br>" 
#                append page_contents_unquoted "Spec2 ref: $spec2ref <br>"
#                append page_contents_unquoted "Spec2 default: $spec2default <br>"
#                append page_contents_unquoted "Spec3 ref: $spec3ref <br>"
#                append page_contents_unquoted "Spec3 default $spec3default <br>"
#                append page_contents_unquoted "Image name: $image_name <br>"
#                append page_contents_unquoted "Image width: $image_width <br>"
#                append page_contents_unquoted "Image height: $image_height <br>"
#                append page_contents_unquoted "Thumbnail name: $thumbnail_name <br>"
#                append page_contents_unquoted "Thumbnail width: $thumbnail_width <br>"
#                append page_contents_unquoted "Thumbnail height: $thumbnail_height <br>"
#                append page_contents_unquoted "Price: $price <br>"
#                append page_contents_unquoted "Dimensions: $dimensions <br>"
#                append page_contents_unquoted "Ship wt: $ship_wt <br>"
#                append page_contents_unquoted "Actual wt: $actual_wt <br>"
#                append page_contents_unquoted "Unit: $unit <br>"

#---- end of extended view




                set page_main_code [template::adp_compile -string $page_contents_unquoted]
                set page_main_code_html [template::adp_eval page_main_code]
                
            }
        } else {
            # no permission to read page. This should not happen.
            ns_log Warning "q-wiki.tcl:(619) user did not get expected 404 error when not able to read page."
        }
    }
    w {
        #  save.....  (write) page_id 
        # should already have been handled above
        ns_log Warning "q-wiki.tcl(575): mode = save/write THIS SHOULD NOT BE CALLED."
        # it's called in validation section.
    }
    default {
        # return 404 not found or not validated (permission or other issue)
        # this should use the base from the config.tcl file
        if { [llength $user_message_list ] == 0 } {
            ns_returnnotfound
            #  rp_internal_redirect /www/global/404.adp
            ad_script_abort
        }
    }
}
# end of switches

# using OpenACS built-in util_get_user_messages feature
#set user_message_html ""
#foreach user_message $user_message_list {
#    append user_message_html "<li>${user_message}</li>"
#}

set menu_html ""
set validated_p_exists [info exists validated_p]
if { $validated_p_exists && $validated_p || !$validated_p_exists } {
    foreach item_list $menu_list {
        set menu_label [lindex $item_list 0]
        set menu_url [lindex $item_list 1]
        append menu_html "<a href=\"${menu_url}\" title=\"${menu_label}\">${menu_label}</a> &nbsp; "
    }
} 
set doc(title) $title
set context [list $title]

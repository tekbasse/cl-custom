ad_library {

    Example procs to be customized for any application
    License: gnu gpl v2. See package README.md file
    Some parts associated with paypal basket integration may be copyright PayPal
   @creation-date  March 2011
}

ad_proc -public ecbw_build_color_chart {
    {color_chart_name "colors_arr"}
} {
    builds color matrix for dynamic calls that are too small to require a db table
} {
upvar $color_chart_name colors_arr
    
    set data_list_of_lists [list \
        [list "color_ref" "name" "hex_color" "pretty_name" "sort_order"] \
        [list "RED" "Red" "\#ff0000" "Red" "100"] \
        [list "CRIMSON" "Crimson Red" "\#dc143c" "Crimson Red" "200"] \
        [list "FIREBRICK" "FireBrick Red" "\#b22222" "FireBrick Red" "300"] \
        [list "ORANGE" "Orange" "\#ff4500" "Orange Red" "400"] \
        [list "YELLOW" "Yellow" "\#ffff00" "Yellow" "500"] \
        [list "GOLD" "Gold" "\#ffd700" "Golden Yellow" "600"] \
        [list "GREEN" "Green" "\#008000" "Green" "700"] \
        [list "NAVY" "Navy" "\#000080" "Navy Blue" "800"] \
        [list "TEAL" "Teal" "\#008080" "Teal Blue" "900"] \
        [list "BLUE" "Blue" "\#0000ff" "Blue" "1000"] \
        [list "PURPLE" "Purple" "\#800080" "Purple" "1100"] \
        [list "BROWN" "Brown" "\#a52a2a" "Brown" "1200"] \
        [list "ROSYBROWN" "RosyBrown" "\#bc8f8f" "Rosy Brown" "1250"] \
        [list "BURLYWOOD" "Burlywood" "\#deb887" "Burlywood" "1300"] \
        [list "SILVER" "Silver" "\#c0c0c0" "Silver" "1400"] \
        [list "GRAY" "Gray" "\#808080" "Gray" "1500"] \
        [list "BLACK" "Black" "\#000000" "Black" "1700"] \
        [list "WHITE" "White" "\#ffffff" "White" "1800"] \
   ]
    set count 1
    set  colors_arr(rows) [list]
    foreach data_list $data_list_of_lists {
        if { $count == 1 } {
            set colors_arr(columns) $data_list
        } else {
#            set row($count) $data_list
            set column_num 0
            set index1 [string tolower [lindex $data_list 0]]
            lappend colors_arr(rows) $index1
            set colors_arr($index1) $data_list
            foreach data_point $data_list {
                set colors_arr(${index1},[lindex $colors_arr(columns) $column_num]) $data_point
                incr column_num
            }
        }
        incr count
    }
    return 1
}

ad_proc -public ecbw_build_catalog {
    {catalog_array_name "catalog_arr"}
} {
    builds matrix for dynamic catalog calls for catalogs that are too small to require a db.
} {
upvar $catalog_array_name catalog_arr
# images fit 576 x 576 (was 650x576) , thumbnails fit 120x72
    set data_list_of_lists [list \
        [list "model" "description" "spec1ref" "spec1default" "spec2ref" "spec2default" "spec3ref" "spec3default" "image_name" "image_width" "image_height" "thumbnail_name" "thumbnail_width" "thumbnail_height" "price" "dimensions" "ship_wt" "actual_wt" "unit" "long_description_html"]\
        [list "AFBH" "A-Frame Birdhouse" "body" "BURLYWOOD" "roof" "BROWN" "trim" "GRAY" "afbh-example.jpg" "397" "541" "thumbnail-afbh.jpg" "53" "72" "39.95" "10.5H x 7W x 8D" "4" "2 lb 10 oz" "one" "<p>This handcrafted, all wood birdhouse comes with a 1-1/8inch entrance that attracts small Chickadee's, Wren's and others. It features a shingled roof and a removable floor with angled corners for drainage. This house can be mounted to a metal pole by attaching a plumbing flange to the bottom; or mounted to a surface with a screw inserted through the opening and thread to the opposite wall. This bird home features cleats on the inside to provide a good foothold for younger birds.</p>" ]\
        [list "BH1" "Birdhouse One" "body" "YELLOW" "roof" "ROSYBROWN" "" "" "bh1-example.jpg" "356" "501" "thumbnail-bh1.jpg" "51" "72" "39.95" "16H x 7.5W x 8.25D" "5" "3 lb 8 oz" "one" "<p>This all wood, handcrafted birdhouse has a small 1-1/8inch entrance hole --perfect for small songbirds such as wrens, chickadees and nuthatches. It opens on the side and has cleats on the inside to give birds a good foothold. This house features:</p> <ul><li>a removable floor for easy cleaning and drainage; and </li><li>air flow has been maximized to keep birds comfortable with the use of angled corners.</li></ul><p>This house can be mounted with two screws in the lower back of the house.</p>" ]\
        [list "BH2" "Birdhouse Two" "body" "RED" "roof" "GRAY" "" "" "bh2-example.jpg" "345" "517" "thumbnail-bh2.jpg" "48" "72" "39.95" "15H x 7.5W x 8.25D" "5" "3 lb 11 oz" "one" "<p>This all wood, handcrafted birdhouse has a medium-sized 1-1/4inch entrance hole. The interior features cleats to help young birds gain a good foothold. Its roof is secured with a brass plated hinge with a hook &amp; eye. It opens from the top and has a removable floor with angled corners for easy cleaning, ventilation and drainage. The back extends below the house so it can be mounted to a surface with two screws.</p>" ]\
        [list "BH3" "Birdhouse Three" "body" "BLACK" "roof" "TEAL" "" "" "bh3-example.jpg" "370" "504" "thumbnail-bh3.jpg" "53" "72" "39.95" "11H x 5.5W x 9D" "5" "3 lb 5 oz" "one" "<p>This all wood, handcrafted birdhouse has a 1-1/2inch entrance hole. Its roof is secured with a hook &amp; eye. This model opens from the top and has angled corners for improved ventilation as well as a removable floor for easy cleaning and drainage. Cleats are mounted on the interior to help birds gain a good foothold. The back extends below the house so it can be mounted to a surface with two screws.</p>" ]\
                                ]

    set count 1
    set  catalog_arr(rows) [list]
    foreach data_list $data_list_of_lists {
        if { $count == 1 } {
            set catalog_arr(columns) $data_list
        } else {
#            set row($count) $data_list
            set column_num 0
            set index1 [string tolower [lindex $data_list 0]]
            lappend catalog_arr(rows) $index1
            set catalog_arr($index1) $data_list
            foreach data_point $data_list {
                set index2 [lindex $catalog_arr(columns) $column_num]
                if { $index2 eq "spec1default" || $index2 eq "spec2default" || $index2 eq "spec3default" } {
                    set data_point [string tolower $data_point]
                }
                set catalog_arr(${index1},${index2}) $data_point
                incr column_num
            }
        }
        incr count
    }
    return 1
}


ad_proc -public ecbw_paypal_checkout_button {
    item_number
    item_name
    amount
    tax
    weight
    {business "paypal_busines_ref"}
    {thankyou_url "[ns_conn url]"}
    {currency_code "USD"}
    {weight_unit "lbs"}
    {quantity "1"}
    {shipping ""}
    {shipping_additional ""}
} {
    returns html fragment for checking out via PayPal standard "checkout update" process
} {
# paypal variable notes at: https://cms.paypal.com/us/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_html_Appx_websitestandard_htmlvariables
# var 'rm' has special meaning on return:
#
#Return method. The FORM METHOD used to send data to the URL specified by the return variable after payment completion. Allowable values:
#      0 - all shopping cart transactions use the GET method
#      1 - the payer's browser is redirected to the return URL by the GET method, and no transaction variables are sent
#      2 - the payer's browser is redirected to the return URL by the POST method, and all transaction variables are also posted
# The default is 0.
#Note: The rm variable takes effect only if the return variable is also set.
  
#by using rm = 2, can numbers be verified automatically?  exploring this.
# paypal example for Birdswelcome:
#<form target="paypal" action="https://www.paypal.com/cgi-bin/webscr" method="post">
#<input type="hidden" name="cmd" value="_cart">
#<input type="hidden" name="business" value="SEQ8ESMLZP7UG">
#<input type="hidden" name="lc" value="US">
#<input type="hidden" name="item_name" value="abf-red-red">
#<input type="hidden" name="amount" value="34.95">
#<input type="hidden" name="currency_code" value="USD">
#<input type="hidden" name="button_subtype" value="products">
#<input type="hidden" name="add" value="1">
#<input type="hidden" name="bn" value="PP-ShopCartBF:btn_cart_LG.gif:NonHosted">
#<input type="image" src="https://www.paypalobjects.com/WEBSCR-640-20110401-1/en_US/i/btn/btn_cart_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
#<img alt="" border="0" src="https://www.paypalobjects.com/WEBSCR-640-20110401-1/en_US/i/scr/pixel.gif" width="1" height="1">
#</form>


    set price [format %.2f $amount]
            # actual example from paypal.com:
            set r "<form target=\"paypal\" action=\"https://www.paypal.com/cgi-bin/webscr\" method=\"post\">
<input type=\"hidden\" name=\"cmd\" value=\"_cart\">
<input type=\"hidden\" name=\"business\" value=\"${business}\">
<input type=\"hidden\" name=\"lc\" value=\"US\">
<input type=\"hidden\" name=\"item_name\" value=\"${item_name}\">
<input type=\"hidden\" name=\"item_number\" value=\"${item_number}\">
<input type=\"hidden\" name=\"weight\" value=\"$weight\">
<input type=\"hidden\" name=\"weight_unit\" value=\"${weight_unit}\">
<input type=\"hidden\" name=\"amount\" value=\"$price\">
<input type=\"hidden\" name=\"currency_code\" value=\"${currency_code}\">
<input type=\"hidden\" name=\"button_subtype\" value=\"products\">
<input type=\"hidden\" name=\"no_note\" value=\"0\">
<input type=\"hidden\" name=\"cn\" value=\"Add special instructions to the seller\">
<input type=\"hidden\" name=\"no_shipping\" value=\"2\">
<input type=\"hidden\" name=\"add\" value=\"1\">"
        if { $shipping > 0 } {
                append r "
<input type=\"hidden\" name=\"shipping\" value=\"$shipping\">
<input type=\"hidden\" name=\"shipping2\" value=\"${shipping_additional}\">"
        }
            append r "
<input type=\"hidden\" name=\"bn\" value=\"PP-ShopCartBF:btn_cart_LG.gif:NonHosted\">
<input type=\"image\" src=\"https://www.paypal.com/en_US/i/btn/btn_cart_LG.gif\" border=\"0\" name=\"submit\" alt=\"PayPal - The safer, easier way to pay online!\">
<img alt=\"\" border=\"0\" src=\"https://www.paypal.com/en_US/i/scr/pixel.gif\" width=\"1\" height=\"1\">
 </form>"
return $r
}

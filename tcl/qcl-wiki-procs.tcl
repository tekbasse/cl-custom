ad_library {

    API for integrating bw with q-wiki
    License: gnu gpl v2. See package README.md file
    @creation-date 17 Jul 2012
    @cs-id $Id:
}


ad_proc -public qwcl_page_create { 
    instance_id
    page_id
    model_ref
    spec1ref
    spec1type
    spec1default
    spec2ref
    spec2type
    spec2default
    spec3ref
    spec3type
    spec3default
    spec4ref
    spec4type
    spec4default
    spec5ref
    spec5type
    spec5default
    gallery_folder_id
    price
    dimensions
    ship_wt
    actual_wt
    unit 
} {
    Creates extension to wiki page. returns page_id, or 0 if error. instance_id is usually package_id
} {
# $template_id $page_id $model_ref $spec1ref $spec1default $spec2ref $spec2default $spec3ref $spec3default $image_name $image_width $image_height $thumbnail_name $thumbnail_width $thumbnail_height $price $dimensions $ship_wt $actual_wt $unit 
    if { $instance_id eq "" } {
        # set instance_id package_id
        set instance_id [ad_conn package_id]
    }
    set page_id_exists [db_0or1row qwcl_get_page_id "select page_id as page_id_fra_db from qwcl_catalog where instance_id = :instance_id and page_id = :page_id" ]
    if { $page_id_exists } {
        db_dml qwcl_wiki_page_update { update qwcl_catalog
            set model_ref = :model_ref, 
            spec1ref =:spec1ref, 
            spec1default=:spec1default, 
            spec2ref =:spec2ref, 
            spec2default=:spec2default, 
            spec3ref =:spec3ref, 
            spec3default =:spec3default, 
            spec4ref =:spec4ref, 
            spec4type =:spec4type,
            spec4default=:spec4default, 
            spec5ref =:spec5ref, 
            spec5type =:spec5type,
            spec5default=:spec5default, 
            gallery_folder_id =:gallery_folder_id,
            price=:price, 
            dimensions=:dimensions, 
            ship_wt=:ship_wt, 
            actual_wt=:actual_wt, 
            unit=:unit 
            where instance_id = :instance_id and page_id = :page_id }

    } else {
        db_dml qwcl_wiki_page_create { insert into qwcl_catalog
            (instance_id, page_id, model_ref, spec1ref, spec1type, spec1default, spec2ref, spec2type, spec2default, spec3ref, spec3type, spec3default, spec4ref, spec4type, spec4default, spec5ref, spec5type, spec5default, gallery_folder_id, price, dimensions, ship_wt, actual_wt, unit)
            values (:instance_id,:page_id,:model_ref,:spec1ref,:spec1type,:spec1default,:spec2ref,:spec2type,:spec2default,:spec3ref,:spec3type,:spec3default,:spec4ref,:spec4type,:spec4default,:spec5ref,:spec5type,:spec5default,:gallery_folder_id,:price,:dimensions,:ship_wt,:actual_wt,:unit ) }
    }
    return 1
}


ad_proc -public qwcl_page_read { 
    page_id
    {instance_id ""}
} {
    Returns page contents of page_id. Returns page as list of attribute values: model_ref, spec1ref, spec1type, spec1default, spec2ref, spec2type, spec2default, spec3ref, spec3type, spec3default, spec4ref, spec4type, spec4default,  spec5ref, spec5type, spec5default,gallery_folder_id, price, dimensions, ship_wt, actual_wt, unit 
} {
    #set page_bw_list \[qwcl_page_read $page_id \]
# $model_ref $spec1ref $spec1default $spec2ref $spec2default $spec3ref $spec3default $image_name $image_width $image_height $thumbnail_name $thumbnail_width $thumbnail_height $price $dimensions $ship_wt $actual_wt $unit 
    if { $instance_id eq "" } {
        # set instance_id package_id
        set instance_id [ad_conn package_id]
    }
    set return_list_of_lists [db_list_of_lists qwcl_wiki_page_get { select  model_ref, spec1ref, spec1type, spec1default, spec2ref,spec2type, spec2default, spec3ref,spec3type, spec3default,  spec4ref,spec4type, spec4default, spec5ref,spec5type, spec5default,gallery_folder_id, price, dimensions, ship_wt, actual_wt, unit from qwcl_catalog where page_id = :page_id and instance_id = :instance_id } ]
    # convert return_lists_of_lists to return_list
    set return_list [lindex $return_list_of_lists 0]
    return $return_list
}

ad_proc -public qwcl_page_write {
    instance_id
    page_id
    model_ref
    spec1ref
    spec1type
    spec1default
    spec2ref
    spec2type
    spec2default
    spec3ref
    spec3type
    spec3default
    spec4ref
    spec4type
    spec4default
    spec5ref
    spec5type
    spec5default
    gallery_folder_id
    price
    dimensions
    ship_wt
    actual_wt
    unit 
} {
    Creates extension to wiki page. returns page_id, or 0 if error. instance_id is usually package_id
} {
# $template_id $page_id $model_ref $spec1ref $spec1default $spec2ref $spec2default $spec3ref $spec3default $image_name $image_width $image_height $thumbnail_name $thumbnail_width $thumbnail_height $price $dimensions $ship_wt $actual_wt $unit 
    if { $instance_id eq "" } {
        # set instance_id package_id
        set instance_id [ad_conn package_id]
    }
    set page_id_exists [db_0or1row qwcl_get_page_id "select page_id as page_id_fra_db from qwcl_catalog where instance_id = :instance_id and page_id = :page_id" ]
    if { $page_id_exists } {
        db_dml qwcl_wiki_page_update { update qwcl_catalog
            set model_ref = :model_ref, 
            spec1ref =:spec1ref, 
            spec1type =:spec1type,
            spec1default=:spec1default, 
            spec2ref =:spec2ref, 
            spec2type =:spec2type,
            spec2default=:spec2default, 
            spec3ref =:spec3ref, 
            spec3type =:spec3type,
            spec3default =:spec3default, 
            spec4ref =:spec4ref, 
            spec4type =:spec4type,
            spec4default=:spec4default, 
            spec5ref =:spec5ref, 
            spec5type =:spec5type,
            spec5default=:spec5default, 
            gallery_folder_id =:gallery_folder_id,
            price=:price, 
            dimensions=:dimensions, 
            ship_wt=:ship_wt, 
            actual_wt=:actual_wt, 
            unit=:unit 
            where instance_id = :instance_id and page_id = :page_id }

    } else {
        db_dml qwcl_wiki_page_create { insert into qwcl_catalog
            (instance_id, page_id, model_ref, spec1ref, spec1type, spec1default, spec2ref,spec2type, spec2default, spec3ref,spec3type, spec3default,spec4ref, spec4type, spec4default, spec5ref, spec5type,spec5default, gallery_folder_id, price, dimensions, ship_wt, actual_wt, unit)
            values (:instance_id,:page_id,:model_ref,:spec1ref,:spec1type,:spec1default,:spec2ref,:spec2type,:spec2default,:spec3ref,:spect3type,:spec3default,:spec4ref,:spec4type,:spec4default,:spec5ref,:spec5type,:spec5default,:gallery_folder_id,:price,:dimensions,:ship_wt,:actual_wt,:unit ) }
    }
    return 1
}



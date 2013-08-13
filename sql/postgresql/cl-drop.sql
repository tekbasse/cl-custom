-- bw2-drop.sql
--
-- @author Benjamin Brink
-- @for OpenACS
-- @cvs-id
--
-- Version 2 of the Birdswelcome data model (using q-wiki)

drop index qwcl_inventory_page_id_idx;
drop index qwcl_inventory_instance_id_idx;
drop table qwcl_inventory;

drop index qwcl_catalog_instance_id_idx;
drop index qwcl_catalog_page_id_idx;
drop index qwcl_catalog_model_ref_idx;
drop table qwcl_catalog;

drop index qwcl_color_chart_ref_idx;
drop table qwcl_color_chart;


-- lc-create.sql
--
-- @author Benjamin Brink
-- @for OpenACS
-- @cvs-id
--
-- Version 1 of the CraftsmanLarry

CREATE TABLE qwcl_catalog (
    instance_id integer not null,
       -- 1:1 with qw_wiki_page.id
    page_id integer not null,
    -- uniqueness enforced in tcl
    model_ref varchar(32),
    -- same as page_title
    -- title varchar(100),
    spec1ref varchar(32),
    spec1type varchar(320),
    spec1default varchar(320),
    spec2ref varchar(32),
    spec2type varchar(320),
    spec2default varchar(320),
    spec3ref varchar(32),
    spec3type varchar(320),
    spec3default varchar(320),
    spec4ref varchar(32),
    spec4type varchar(320),
    spec4default varchar(320),
    spec5ref varchar(32),
    spec5type varchar(320),
    spec5default varchar(320),
    gallery_folder_id varchar(12),
    price varchar(10),
    dimensions varchar(40),
    ship_wt varchar(20),
    actual_wt varchar(20),
    unit varchar(10)
    -- same as page_contents
    -- long_descripton_html varchar(4000)
);

CREATE INDEX qwcl_catalog_model_ref_idx ON qwcl_catalog (model_ref);
CREATE INDEX qwcl_catalog_page_id_idx ON qwcl_catalog (page_id);
CREATE INDEX qwcl_catalog_instance_id_idx ON qwcl_catalog (instance_id);

CREATE TABLE qwcl_inventory (
 instance_id integer not null,
  -- 1:1 with qw_wiki_page.id
 page_id integer not null,
  -- same as name
 sku  varchar(72),
  -- same as description
  -- description varchar(200),
 price       varchar(10),
 stock_qty  numeric
  -- same as contents
  -- comments   varchar(200)
);

CREATE INDEX qwcl_inventory_page_id_idx on qwcl_inventory (page_id);
CREATE INDEX qwcl_inventory_instance_id_idx on qwcl_inventory (instance_id);

CREATE TABLE qwcl_color_chart (
    ref         varchar(16) unique,
    name        varchar(20),
    color_hex   varchar(10),
    pretty_name varchar(100),
    sort_id     integer,
    trashed_p   varchar(1) DEFAULT '0'
);

CREATE INDEX qwcl_color_chart_ref_idx ON qwcl_color_chart (ref);

-- example data
insert into qwcl_color_chart (ref,name,color_hex,pretty_name,sort_id,trashed_p) values ('2f3338','Black','#2f3338','India Ink Black','1500','0');
insert into qwcl_color_chart (ref,name,color_hex,pretty_name,sort_id,trashed_p) values ('80868d','Gray','#80868d','Shipping Gray','1600','0');
insert into qwcl_color_chart (ref,name,color_hex,pretty_name,sort_id,trashed_p) values ('eff0ec','White','#eff0ec','Light White','1800','0');

<master>
  <property name="doc(title)">@title@</property>
  <property name="title">@title@</property>
  <property name="context">@context;noquote@</property>


<if @menu_html@ not nil>
  <div class="action-list" style="float: right; border: 1px dotted;">@menu_html;noquote@</div>
</if>
<h1>@title@</h1>
<if @user_message_html@ not nil>
<ul>
  @user_message_html;noquote@
</ul>
</if>

<if @form_id_html@ not nil>
<div style="width: 25%; float: right; margin: 1%;">
 <include src="/packages/photo-album/lib/album-insert" package_id="@gallery_package_id@" album_id="@album_id@" photo_id="@photo_id@" link_url="@model_ref@">
<if @form_html@ not nil>
 @form_html;noquote@
</if>
</div>

 <include src="/packages/photo-album/lib/photo-insert" package_id="@gallery_package_id@" photo_id="@photo_id@" album_id="@album_id@">
<br>

</if><else>

<if @form_html@ not nil>
 @form_html;noquote@
</if>

</else>


<if @page_stats_html@ not nil>
 <h3>pages</h3>
 @page_stats_html;noquote@
</if>

<if @page_trashed_html@ not nil>
<h3>trashed</h3>
 @page_trashed_html;noquote@
</if>

<if @page_main_code_html@ not nil>
 @page_main_code_html;noquote@
</if>

<if 0 true>
<if @mode@ eq "v">
<include src="product" model=@model_ref@>
</if>
</if>


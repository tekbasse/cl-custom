CL-Custom
=========

For the latest updates to this readme file, see: http://github.com/tekbasse/cl-custom

The lastest version of the code is available at the development site:
 http://github.com/tekbasse/cl-custom

introduction
------------

CL-Custom is an extension of Q-Wiki, an OpenACS wiki using a templating system.
It allows tcl procedures to be used in a web-based publishing environment.
It is not tied to vertical web applications, such as OpenACS ecommerce package.

This package is for managing custom products of up to 5 different specifications per product. 
Specifications can be unique to each product.

Development of cl-custom was sponsored by CraftsmanLarry.com in 2012-3.

license
-------
Copyright (c) 2013 Benjamin Brink
po box 20, Marylhurst, OR 97036-0020 usa
email: kappa@dekka.com

CL-Custom is open source and published under the GNU General Public License, consistent with the OpenACS system: http://www.gnu.org/licenses/gpl.html
A local copy is available at cl-custom/www/doc/LICENSE.html

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

features
--------

Each product can be linked to a gallery of images in the photo-album package.

Pages automatically have revisioning.

Pages must be trashed before being deleted. Trashed pages can be untrashed. 

Trashed pages are not published.

Users with create permission can also trash their own creations.

No UI javascript is used, so technologies with limited UI can use it.

Tcl procedures pass through two filters: 
1. a list of glob expressions stating which procedures are allowed to be used
2. a list of specifically banned procedures

A package parameter can switch the TCL/ADP rendering of content on or off.

This web-app is easily modifiable for custom specifications.
It consists of a single q-wiki tcl/adp page pair and
 an extra unused "flags" field.

This app is ready for web-based publishing SEO optimization.
Besides content, pages include comments, keywords, page description fields,
and 5 sets of fields for configuring up to 5 different product-based choices,
where each product can have completely different sets of choices.


Weblocks Google-map widget 
==========================

This is a map widget made for the Weblocks framework.

Approach
---------

Google API v3 (no developer-key required). Pop-up layer for actual
map. Map javascript in external file, connected to relevant field with
`rel="map"` attribute.

Older approaches
----------------

Using send-script and having the js-code inside lisp. Deprecated for
the following reasons:

1. Recurrent load/unload of JS when widgets on page change.
2. Cannot be cached by browsers.

Advantages:

1. Change in lisp-code immediately reflected in page UI.

Background
------------

Despite terrible embarrassment at the state of this code, I'm going to put 
it up on github. The idea was to build a demo app, but I'm a bit short on time, so the 
important parts've all been chucked into misc:

Misc dir:
---------------------------
file:   geochecker.lisp       (contains a claims-geochecker widget)

file:   maps.js

file:   older-geochecker.lisp (older-geochecker shows a previous, failed 
approach)


maps.js is loaded as a dependency of the geochecker widget which is called 
claims-geochecker and is defined in geochecker.lisp

Any field which has a rel="map" attribute will trigger the map when its 
text changes.

There was a version earlier that would show the map-dialog after clicking 
a button, but this way is better, imho.

There was also a version that built an accordion to categorize the various 
place-names that geonames returns (eg Place, Country etc)

I also investigated cl-geonames, but it was more user-friendly to build 
the UI in JS, and so ended up using the ajax option for the query.

Dependencies
-----------------

Dialogs, and on-change events etc. are monitored thru YUI, the accordion library used is also based on YUI.

Download & Installation 
-----------------------

Downloads and the source repository can be found on GitHub:

http://github.com/nunb/map.widget

Once this directory is made (with git, or unzipping) use
weblocks-installer to get the current weblocks.

Edit map.widget/script/server to set ports and run `sh script/server`

Open a browser to localhost:port

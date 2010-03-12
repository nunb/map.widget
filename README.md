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


Download & Installation
-----------------------

Downloads and the source repository can be found on GitHub:

http://github.com/nunb/map.widget

Once this directory is made (with git, or unzipping) use
weblocks-installer to get the current weblocks.

Edit map.widget/script/server to set ports and run `sh script/server`

Open a browser to localhost:port

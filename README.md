Just a personal overlay for Gentoo.

Add https://raw.github.com/sdfg2/sdfg-overlay/master/repositories.xml to overlays in /etc/layman/layman.cfg.

Additions:

media-sound/beets

Updated ebuild for beets, currently 1.3.15.  My previous ebuild was taken into portage, so I'm hoping it might become more regular.  1.3.15 has been tightened up considerably from previous versions, adding more constrictions on plugins that require outside dependencies.  I made the decision to stick to gstreamer for almost all plugin needs, as it seems to be the easiest to maintain, especially for the convert plugin.  The one plugin that WILL DEFINITELY NOT WORK is ipfs - I'm still trying to figure out the best way to write a go-ipfs ebuild to support it.

media-tv/emby-server

The megacoffee overlay has sandbox violations (I think the ebuilds are automatically generated and not tested), so this is a fixed ebuild.


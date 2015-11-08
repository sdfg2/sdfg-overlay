Just a personal overlay for Gentoo.

Add https://raw.github.com/sdfg2/sdfg-overlay/master/repositories.xml to overlays in /etc/layman/layman.cfg.

Additions:

media-sound/beets

Updated ebuild for beets, currently 1.3.15.  My previous ebuild was taken into portage, so I'm hoping it might become more regular.  1.3.15 has been tightened up considerably from previous versions, adding more constrictions on plugins that require outside dependencies.  I made the decision to stick to gstreamer for almost all plugin needs, as it seems to be the easiest to maintain, especially for the convert plugin.  The one plugin that WILL DEFINITELY NOT WORK is ipfs - I'm still trying to figure out the best way to write a go-ipfs ebuild to support it.

dev-python/pyechonest

8.0.1 was a required dep for beets.  I see that there is ~9.0.0 in portage now, so I'll be testing that shortly, if it works then 8.0.1 will disappear.

dev-python/jellyfish

I wrote the first ebuild for jellyfish to support beets - again, there seems to be an update from 0.5.0 to 0.5.1 in portage, so this will probably disappear in the future.

media-tv/emby-server

The megacoffee overlay version didn't work previously, so I made my own to cover that.  I haven't tested the newer versions of the megacoffee one, if they work as intended now then this will be gone too in the future.


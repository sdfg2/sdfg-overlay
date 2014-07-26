Just a personal overlay for Gentoo.

Add https://raw.github.com/sdfg2/sdfg-overlay/master/repositories.xml to overlays in /etc/layman/layman.cfg.

Additions:

net-im/ejabberd-9999

ejabberd moved to a new build system, a new config language, and a new versioning system late in 2013.  One of the problems with this is that, at present, the build script (rebar) pulls components for ejabberd from the master branches of remote repositories.  Obviously, this isn't good for debugging purposes, especially on a source distro like Gentoo.  So, at the moment, there are no >=net-im/ejabberd-13.x stable builds.  This is a known issue, but until the ejabberd devs use tagged branches for rebar to ensure consistent builds, we're stuck with a -9999 'live' ebuild.  This was my attempt to create one.  It's based mainly on rion's -9999 ebuild (thank you!) but updated for the new build system and config language (moving from erlang to yaml - much better in my opinion).

This is also my first 'public' ebuild, so be gentle.  Please flag any issues on github.

www-servers/nginx-x-r999

Despite the fact that nginx can quite happily support passenger - both runtime and as a compile-time flag - and that passenger is, in my experience, the easiest way of providing ruby applications, there isn't support for building it in in the main www-servers/nginx branch.  This is very much a personal bugbear, and all I do is apply simple changes to add passenger support.  (Another bug-bear is passenger having apache as an RDEP, but I'll get to that eventually. ;-) )  This has NOT been cleaned and tested as thoroughly as the others.

x11-plugins/pidgin-opensteamworks-1.4-r1

The current available source code tarball for this relies on NSS, which has some problems encrypting Steam passwords on Gentoo.  
I patched 1.4 up to the current svn trunk, which contains PolarSSL instead, tweaked the Makefile to link to the correct 
libraries, plus merged the extraneous Makefile in with the patch for the rest of the source files.  Confirmed working on 
spectrum2 transport service on the ejabberd XMPP server.

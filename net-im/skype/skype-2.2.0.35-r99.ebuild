# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/skype/skype-2.2.0.35-r99.ebuild,v 1.7 2012/09/24 00:47:04 vapier Exp $

EAPI=4
inherit eutils gnome2-utils qt4-r2 pax-utils

SVERSION=2.2.0.99
SFILENAME=${PN}_static-${SVERSION}.tar.bz2
DVERSION=${PV}
DFILENAME=${PN}-${DVERSION}.tar.bz2

DESCRIPTION="An P2P Internet Telephony (VoiceIP) client"
HOMEPAGE="http://www.skype.com/"
SRC_URI="qt-static? ( http://download.skype.com/linux/${SFILENAME} )
	!qt-static? ( http://download.skype.com/linux/${DFILENAME} )"

LICENSE="skype-eula"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pax_kernel selinux qt-static"

RESTRICT="mirror strip" #299368
EMUL_VER=20120520

RDEPEND="
	amd64? (
		>=app-emulation/emul-linux-x86-baselibs-${EMUL_VER}
		>=app-emulation/emul-linux-x86-soundlibs-${EMUL_VER}
		>=app-emulation/emul-linux-x86-xlibs-${EMUL_VER}
		!qt-static? ( >=app-emulation/emul-linux-x86-qtlibs-${EMUL_VER} )
		)
	x86? (
		>=media-libs/alsa-lib-1.0.24.1
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXScrnSaver
		x11-libs/libXv
		qt-static? (
			=dev-libs/glib-2*
			media-libs/fontconfig
			>=media-libs/freetype-2
			>=media-libs/tiff-3.9.5-r3:3
			sys-libs/zlib
			x11-libs/libICE
			x11-libs/libSM
			x11-libs/libXrender
			)
		!qt-static? (
			x11-libs/qtcore:4
			x11-libs/qtdbus:4
			x11-libs/qtgui:4[accessibility,dbus]
			)
		)
	virtual/ttf-fonts
	selinux? ( sec-policy/selinux-skype )"

# Required to get `lrelease` command for src_install()
DEPEND="!qt-static? ( x11-libs/qt-core:4 )
	selinux? ( sec-policy/selinux-skype )"

QA_EXECSTACK="opt/skype/skype"
QA_WX_LOAD="opt/skype/skype"
QA_FLAGS_IGNORED="opt/skype/skype"

pkg_setup() { :; }

src_unpack() {
	unpack ${A}
	[[ -d ${S} ]] || { mv skype* "${S}" || die; }
}

src_install() {
	exeinto /opt/skype
	doexe skype
	fowners root:audio /opt/skype/skype
	make_wrapper skype ./skype /opt/skype /opt/skype

	insinto /opt/skype/sounds
	doins sounds/*.wav

	if ! use qt-static; then
		insinto /etc/dbus-1/system.d
		doins skype.conf
	fi

	if ! use qt-static; then
		lrelease lang/*.ts
	fi

	insinto /opt/skype/lang
	doins lang/*.qm

	insinto /opt/skype/avatars
	doins avatars/*.png

	local res
	for res in 16 32 48; do
		insinto /usr/share/icons/hicolor/${res}x${res}/apps
		newins icons/SkypeBlue_${res}x${res}.png skype.png
	done

	dodoc README

	make_desktop_entry skype "Skype VoIP" skype "Network;InstantMessaging;Telephony"

	dosym /opt/skype /usr/share/skype # Fix for disabled sound notification

	if use pax_kernel; then
		pax-mark Cm "${ED}"/opt/skype/skype || die
		eqawarn "You have set USE=pax_kernel meaning that you intend to run"
		eqawarn "skype under a PaX enabled kernel.  To do so, we must modify"
		eqawarn "the skype binary itself and this *may* lead to breakage!  If"
		eqawarn "you suspect that skype is being broken by this modification,"
		eqawarn "please open a bug."
	fi
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }

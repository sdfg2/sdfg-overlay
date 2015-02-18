# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

[[ ${PV} = *9999* ]] && VCS_ECLASS="git-r3" || VCS_ECLASS=""

inherit cmake-utils ${VCS_ECLASS}

DESCRIPTION="Spectrum is an XMPP transport/gateway"
HOMEPAGE="http://spectrum.im"

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="git://github.com/hanzz/libtransport.git"
else
	MY_PV="${PV/_/-}"
	SRC_URI="http://spectrum.im/attachments/download/57/${PN}-${MY_PV}.tar.gz"
	S="${WORKDIR}/${PN}-${MY_PV}"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE_PLUGINS="frotz irc purple skype smstools"
IUSE="debug doc libev log mysql postgres sqlite staticport symlinks test tools ${IUSE_PLUGINS}"

RDEPEND="net-im/jabber-base
	net-im/swiften
	dev-libs/popt
	dev-libs/openssl
	log? ( dev-libs/log4cxx )
	mysql? ( virtual/mysql )
	postgres? ( dev-libs/libpqxx )
	sqlite? ( dev-db/sqlite:3 )
	frotz? ( dev-libs/protobuf )
	irc? ( net-im/communi dev-libs/protobuf )
	purple? ( >=net-im/pidgin-2.6.0 dev-libs/protobuf )
	skype? ( dev-libs/dbus-glib x11-base/xorg-server[xvfb] dev-libs/protobuf )
	libev? ( dev-libs/libev dev-libs/protobuf )"

DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/cmake
	doc? ( app-doc/doxygen )
	test? ( dev-util/cppunit )
	"

REQUIRED_USE="|| ( sqlite mysql postgres )"

PROTOCOL_LIST="aim facebook gg icq irc msn msn_pecan myspace qq simple sipe twitter xmpp yahoo"

pkg_setup() {
	CMAKE_IN_SOURCE_BUILD=1
	use debug && CMAKE_BUILD_TYPE=Debug
	MYCMAKEARGS="-DLIB_INSTALL_DIR=$(get_libdir)"
}

src_prepare() {
  use sqlite   || { sed -i -re 's/(ENABLE_SQLITE3.*)ON/\1OFF/' CMakeLists.txt || die; }
  use mysql    || { sed -i -re 's/(ENABLE_MYSQL.*)ON/\1OFF/' CMakeLists.txt || die; }
  use postgres || { sed -i -re 's/(ENABLE_PQXX.*)ON/\1OFF/' CMakeLists.txt || die; }
                    sed -i -re 's/(ENABLE_FROTZ.*)ON/\1OFF/' CMakeLists.txt || die;
  use irc      || { sed -i -re 's/(ENABLE_IRC.*)ON/\1OFF/' CMakeLists.txt || die; }
  use purple   || { sed -i -re 's/(ENABLE_PURPLE.*)ON/\1OFF/' CMakeLists.txt || die; }
                    sed -i -re 's/(ENABLE_SMSTOOLS3.*)ON/\1OFF/' CMakeLists.txt || die;
                    sed -i -re 's/(ENABLE_SKYPE.*)ON/\1OFF/' CMakeLists.txt || die;
#                   sed -i -e 's/(ENABLE_SWIFTEN.*)ON/\1OFF/' CMakeLists.txt || die;
                    sed -i -re 's/(ENABLE_TWITTER.*)ON/\1OFF/' CMakeLists.txt || die;
                    sed -i -re 's/(ENABLE_YAHOO2.*)ON/\1OFF/' CMakeLists.txt || die
  use doc      || { sed -i -re 's/(ENABLE_DOCS.*)ON/\1OFF/' CMakeLists.txt || die; }
  use log      || { sed -i -re 's/(ENABLE_LOG.*)ON/\1OFF/' CMakeLists.txt || die; }
  use test     || { sed -i -re 's/(ENABLE_TESTS.*)ON/\1OFF/' CMakeLists.txt || die; }
  default_src_prepare
}

src_install() {
	cmake-utils_src_install
	sed -e "s:EPREFIX:${EPREFIX}:" "${FILESDIR}"/spectrum2.initdi > \
	"${WORKDIR}/initd"
	newinitd "${WORKDIR}"/initd spectrum
	keepdir "${EPREFIX}"/var/lib/spectrum2
	keepdir "${EPREFIX}"/var/log/spectrum2
	keepdir "${EPREFIX}"/run/spectrum2
}

pkg_postinst() {
	# Set correct rights
	chown jabber:jabber -R "/etc/spectrum2"
	chown jabber:jabber "${EPREFIX}"/var/lib/spectrum2
	chown jabber:jabber "${EPREFIX}"/var/log/spectrum2
	chown jabber:jabber "${EPREFIX}"/run/spectrum2
}

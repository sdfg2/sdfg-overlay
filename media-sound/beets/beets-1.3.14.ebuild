# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/beets/beets-1.3.14.ebuild,v 1.1 2015/09/02 16:48:35 sochotnicky Exp $

EAPI="5"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"

inherit distutils-r1 eutils

MY_PV=${PV/_beta/-beta.}
MY_P=${PN}-${MY_PV}

DESCRIPTION="A media library management system for obsessive-compulsive music geeks"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
HOMEPAGE="http://beets.radbox.org/ http://pypi.python.org/pypi/beets"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="MIT"
IUSE="bpd chroma convert doc discogs echonest gstreamer lastgenre mpdstats replaygain test web ogg opus flac"

RDEPEND="
	>=dev-python/enum34-1.0.4
	dev-python/jellyfish
	dev-python/munkres[${PYTHON_USEDEP}]
	>=dev-python/python-musicbrainz-ngs-0.4[${PYTHON_USEDEP}]
	dev-python/unidecode[${PYTHON_USEDEP}]
	>=media-libs/mutagen-1.27[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	bpd? ( dev-python/bluelet[${PYTHON_USEDEP}] )
	chroma? ( dev-python/pyacoustid[${PYTHON_USEDEP}] )
	convert? ( media-video/ffmpeg:0[encode] )
	discogs? ( dev-python/discogs-client[${PYTHON_USEDEP}] )
	doc? ( dev-python/sphinx )
	echonest? ( >=dev-python/pyechonest-8.0.1[${PYTHON_USEDEP}] )
	mpdstats? ( dev-python/python-mpd[${PYTHON_USEDEP}] )
	lastgenre? ( dev-python/pylast[${PYTHON_USEDEP}] )
	replaygain? ( gstreamer? ( media-libs/gstreamer:1.0[introspection] media-libs/gst-plugins-good:1.0 dev-python/pygobject:3 ogg? ( media-plugins/gst-plugins-ogg ) flac? ( media-plugins/gst-plugins-flac:1.0 ) opus? ( media-plugins/gst-plugins-opus:1.0 ) ) gstreamer? ( || ( media-sound/mp3gain media-sound/aacgain ) ) )
	web? ( dev-python/flask[${PYTHON_USEDEP}] )
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"

S=${WORKDIR}/${MY_P}

src_prepare() {
	# remove plugins that do not have appropriate dependencies installed
	for flag in bpd chroma convert discogs echonest echonest_tempo lastgenre \
				mpdstats replaygain web;do
		if ! use $flag ; then
			rm -r beetsplug/${flag}.py || \
			rm -r beetsplug/${flag}/ ||
				die "Unable to remove $flag plugin"
		fi
	done

	for flag in bpd lastgenre web;do
		if ! use $flag ; then
			sed -i "s:'beetsplug.$flag',::" setup.py || \
				die "Unable to disable $flag plugin "
		fi
	done

	use bpd || rm -f test/test_player.py

}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	cd test
	if ! use web;then
		rm test_web.py || die "Failed to remove test_web.py"
	fi
	"${PYTHON}" testall.py || die "Testsuite failed"
}

python_install_all() {
	doman man/beet.1 man/beetsconfig.5

	use doc && dohtml -r docs/_build/html/
}

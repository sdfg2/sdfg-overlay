# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils multilib pam ssl-cert autotools git-2

DESCRIPTION="The Erlang Jabber Daemon"
HOMEPAGE="http://www.ejabberd.im/"
EGIT_REPO_URI="https://github.com/processone/ejabberd.git"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="amd64"
IUSE="captcha debug hipe roster-gateway-workaround transient-supervisors full-xml mssql tools nif odbc mysql postgres pam +zlib json +iconv +lager"

DEPEND=">=dev-libs/expat-1.95
	>=dev-lang/erlang-15
	>=dev-libs/libyaml-0.1.4
	>=dev-libs/openssl-0.9.8e
	>=net-im/jabber-base-0.01
	zlib? ( >=sys-libs/zlib-1.2.3 )
	dev-lang/erlang[odbc?]
	virtual/latex-base
	captcha? ( media-gfx/imagemagick[truetype,png] )"
REQUIRED_USE="mssql? ( odbc )
	mysql? ( odbc )
	postgres? ( odbc )"

RDEPEND="${DEPEND}
	>=sys-apps/shadow-4.1.4.2-r3
	 pam? ( virtual/pam )"

# paths in net-im/jabber-base
JABBER_ETC="${EPREFIX}/etc/jabber"
#JABBER_RUN="/var/run/jabber"
JABBER_SPOOL="${EPREFIX}/var/spool/jabber"
JABBER_LOG="${EPREFIX}/var/log/jabber"
JABBER_DOC="${EPREFIX}/usr/share/doc/${PF}"
RNOTES_VER="3.0.0"

src_prepare() {
#	git-2_src_prepare
	S=${WORKDIR}/${P}
	cd "${S}"
	AT_M4DIR="m4" eautoreconf

	# don't install release notes (we'll do this manually)
	sed '/install .* [.][.]\/doc\/[*][.]txt $(DOCDIR)/d' -i Makefile.in || die
	# Set correct paths
	sed -e "/^EJABBERDDIR[[:space:]]*=/{s:ejabberd:${PF}:}" \
		-e "/^ETCDIR[[:space:]]*=/{s:@sysconfdir@/ejabberd:${JABBER_ETC}:}" \
		-e "/^LOGDIR[[:space:]]*=/{s:@localstatedir@/log/ejabberd:${JABBER_LOG}:}" \
		-e "/^SPOOLDIR[[:space:]]*=/{s:@localstatedir@/lib/ejabberd:${JABBER_SPOOL}:}" \
			-i Makefile.in || die
	sed -e "/EJABBERDDIR=/{s:ejabberd:${PF}:}" \
		-e "s|\(ETCDIR=\){{sysconfdir}}.*|\1${JABBER_ETC}|" \
		-e "s|\(LOGS_DIR=\){{localstatedir}}.*|\1${JABBER_LOG}|" \
		-e "s|\(SPOOLDIR=\){{localstatedir}}.*|\1${JABBER_SPOOL}|" \
			-i ejabberdctl.template || die

	# Set shell, so it'll work even in case jabber user have no shell
	# This is gentoo specific I guess since other distributions may have
	# ejabberd user with reall shell, while we share this user among different
	# jabberd implementations.
	sed '/^HOME/aSHELL=/bin/sh' -i ejabberdctl.template || die
	sed '/^export HOME/aexport SHELL' -i ejabberdctl.template || die

	# fix up the ssl cert paths in ejabberd.cfg to use our cert
	sed -e "s:/path/to/ssl.pem:/etc/ssl/ejabberd/server.pem:g" \
		-i ejabberd.yml.example || die "Failed sed ejabberd.yml.example"

	# correct path to captcha script in default ejabberd.cfg
	sed -e 's|.*\(captcha_cmd: \).*|\1/usr/'$(get_libdir)'/erlang/lib/'${P}'/priv/bin/captcha.sh"|' \
			-i ejabberd.yml.example || die "Failed sed ejabberd.yml.example"
	eaclocal
	eautoconf
}

src_configure() {
	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}/html" \
		--libdir="${EPREFIX}/usr/$(get_libdir)/erlang/lib/" \
		$(use_enable hipe) \
		$(use_enable roster-gateway-workaround) \
		$(use_enable transient_supervisors transient-supervisors) \
		$(use_enable full-xml) \
		$(use_enable mssql) \
		$(use_enable tools) \
		$(use_enable nif) \
		$(use_enable odbc) \
		$(use_enable mysql) \
		$(use_enable pgsql postgres ) \
		$(use_enable pam) \
		$(use_enable zlib) \
		$(use_enable json) \
		$(use_enable iconv) \
		$(use_enable lager) \
		--enable-user=jabber
}

src_compile() {
	emake $(use debug && echo debug=true ejabberd_debug=true)
}

src_install() {
	emake DESTDIR="${ED}" doc
	emake DESTDIR="${ED}" install

	# Pam helper module permissions
	# http://www.process-one.net/docs/ejabberd/guide_en.html
	if use pam; then
		pamd_mimic_system xmpp auth account || die "Cannot create pam.d file"
		fowners root:jabber "/usr/$(get_libdir)/erlang/lib/${PF}/priv/bin/epam"
		fperms 4750 "/usr/$(get_libdir)/erlang/lib/${PF}/priv/bin/epam"
	fi

	cd "${WORKDIR}/${P}/doc"
	dodoc release_notes_*.txt

	cp -R "${WORKDIR}/${P}/sql" "${ROOT}/usr/share/ejabberd"

	#dodir /var/lib/ejabberd
	newinitd "${FILESDIR}/${PN}-3.initd" ${PN}
	newconfd "${FILESDIR}/${PN}-3.confd" ${PN}
}

pkg_postinst() {
	elog "For configuration instructions, please see"
	elog "/usr/share/doc/${PF}/html/guide.html, or the online version at"
	elog "http://www.process-one.net/en/ejabberd/docs/guide_en/"

	elog
	elog '===================================================================='
	elog 'Quick Start Guide:'
	elog '1) Add output of `hostname -f` to /etc/jabber/ejabberd.yml line 62'
	elog '   hosts:'
	elog '     - "hostname"'
	elog '2) Add an admin user to /etc/jabber/ejabberd.yml line 355'
	elog '   acl:'
	elog '     admin:'
	elog '       - "admin": "hostname"'
	elog '3) Start the server'
	elog '   # /etc/init.d/ejabberd start'
	elog '4) Register the admin user'
	elog '   # /usr/sbin/ejabberdctl register admin hostname password'
	elog '5) Log in with your favourite jabber client or using the web admin'

    if grep -E '^[^#]*EJABBERD_NODE=' "${EROOT}/etc/conf.d/ejabberd" >/dev/null 2>&1; then
        source "${EROOT}/etc/conf.d/ejabberd"
        ewarn
        ewarn "!!! WARNING !!!  WARNING !!!  WARNING !!!  WARNING !!!"
        ewarn "Starting with 2.1.x some paths and configuration files were"
        ewarn "changed to reflect upstream intentions better. Notable changes are:"
        ewarn
        ewarn "1. Everything (even init scripts) is now handled with ejabberdctl script."
        ewarn "Thus main configuration file became /etc/jabberd/ejabberdctl.cfg"
        ewarn "You must update ERLANG_NODE there with the value of EJABBERD_NODE"
        ewarn "from /etc/conf.d/ejebberd or ejabberd will refuse to start."
        ewarn
        ewarn "2. SSL certificate is now generated with ssl-cert eclass and resides"
        ewarn "at standard location: /etc/ssl/ejabberd/server.pem."
        ewarn
        ewarn "3. Cookie now resides at /var/spool/jabber/.erlang.cookie"
        ewarn
        ewarn "4. /var/log/jabber/sasl.log is now /var/log/jabber/erlang.log"
        ewarn
        ewarn "5. Crash dumps (if any) will be located at /var/log/jabber"

		local i ctlcfg new_ctlcfg
		i=0
		ctlcfg=${EROOT}/etc/jabber/ejabberdctl.cfg
		while :; do
			new_ctlcfg=$(printf "${EROOT}/etc/jabber/._cfg%04d_ejabberdctl.cfg" ${i})
			[[ ! -e ${new_ctlcfg} ]] && break
			ctlcfg=${new_ctlcfg}
			((i++))
		done

		ewarn
		ewarn "Updating ${ctlcfg} (debug: ${new_ctlcfg})"
		sed -e "/#ERLANG_NODE=/aERLANG_NODE=$EJABBERD_NODE" "${ctlcfg}" > "${new_ctlcfg}" || die

		if [[ -e ${EROOT}/var/run/jabber/.erlang.cookie ]]; then
			ewarn "Moving .erlang.cookie..."
			if [[ -e ${EROOT}/var/spool/jabber/.erlang.cookie ]]; then
				mv -v "${EROOT}"/var/spool/jabber/.erlang.cookie{,bak}
			fi
			mv -v "${EROOT}"/var/{run/jabber,spool/jabber}/.erlang.cookie
		fi
		ewarn
		ewarn "We'll try to handle upgrade automagically but, please, do your"
		ewarn "own checks and do not forget to run 'etc-update'!"
		ewarn "PLEASE! Run 'etc-update' now!"
	fi

	SSL_ORGANIZATION="${SSL_ORGANIZATION:-Ejabberd XMPP Server}"
	install_cert /etc/ssl/ejabberd/server
	# Fix ssl cert permissions bug #369809
	chown root:jabber "${EROOT}/etc/ssl/ejabberd/server.pem"
	chmod 0440 "${EROOT}/etc/ssl/ejabberd/server.pem"
	if [[ -e ${EROOT}/etc/jabber/ssl.pem ]]; then
		ewarn
		ewarn "The location of SSL certificates has changed. If you are"
		ewarn "upgrading from ${CATEGORY}/${PN}-2.0.5* or earlier  you might"
		ewarn "want to move your old certificates from /etc/jabber into"
		ewarn "/etc/ssl/ejabberd/, update config files and"
		ewarn "rm /etc/jabber/ssl.pem to avoid this message."
	fi

	if [[ -e ${EROOT}/etc/jabber/ejabberd.cfg ]]; then
		ewarn
		ewarn "The configuration file format has changed.  If you are"
		ewarn "upgrading from ${CATEGORY}/${PN}-2.1* or earlier you might"
		ewarn "want to convert your old configuration file to the new"
		ewarn "format.  To do this run"
		ewarn
		ewarn "# convert_to_yaml /etc/jabber/ejabberd.cfg /etc/jabber/ejabberd.yml"
		ewarn
		ewarn "and ensure the conversion was successful."
	fi

}

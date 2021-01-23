#!/bin/sh
# Copyright (c) 2020 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

pkgtoolp_info() {
	local	_pkg_name="${1}" _group_name="" _pkg_name_uc="$(rtl_toupper "${1}")" _fname="" _pkg_names=""\
		_rc=0 EX_PKG_BUILD_GROUPS="" EX_PKG_DISABLED="" EX_PKG_FINISHED="" EX_PKG_NAMES=""; _status="";
	if ! ex_pkg_load_groups; then
		_rc=1; _status="Error: failed to load build groups.";
	elif ! _group_name="$(ex_pkg_find_package "${EX_PKG_BUILD_GROUPS}" "${_pkg_name}")"; then
		_rc=1; _status="Error: unknown package \`${_pkg_name}'.";
	elif ! _pkg_names="$(ex_pkg_get_packages "${_group_name}")"; then
		_rc=1; _status="Error: failed to expand package list of build group \`${_group_name}'.";
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"\
			"${_group_name}" 1 "${_pkg_name}" "" "${BUILD_WORKDIR}"; then
		_rc=1; _status="Error: failed to set package environment for \`${_pkg_name}'.";
	else	_pkg_version="$(rtl_get_var_unsafe -u "PKG_"${_pkg_name}"_VERSION")";
		rtl_log_env_vars "package" $(rtl_get_vars_fast "^PKG_${_pkg_name_uc}");
		rtl_log_msg info "Build group: %s" "${_group_name}";
		if [ -z "${PKG_DEPENDS:-}" ]; then
			rtl_log_msg info "Package \`%s' has no dependencies." "${_pkg_name}";
		else	rtl_log_msg info "Direct dependencies of \`%s': %s" "${_pkg_name}" "${PKG_DEPENDS}";
			if ! ex_pkg_unfold_depends 1 1 "${_group_name}" "${_pkg_names}" "${_pkg_name}" 0; then
				rtl_log_msg warning "Warning: failed to unfold dependency-expanded package name list for \`%s'." "${_pkg_name}";
			else	EX_PKG_NAMES="$(rtl_lfilter "${EX_PKG_NAMES}" "${_pkg_name}")";
				if [ -n "${EX_PKG_NAMES}" ]; then
					rtl_log_msg info "Full dependencies of \`%s': %s"\
							"${_pkg_name}" "$(rtl_lsort "${EX_PKG_NAMES}")";
				fi;
				if [ -n "${EX_PKG_DISABLED}" ]; then
					rtl_log_msg info "Full dependencies of \`%s' (disabled packages:) %s"\
							"${_pkg_name}" "$(rtl_lsort "${EX_PKG_DISABLED}")";
				fi;
			fi;
		fi;
		set +o noglob;
		for _fname in	\
				"vars/${_pkg_name}.vars"								\
				"patches/${_pkg_name}/"*.patch								\
				"patches/${_pkg_name}${_pkg_version:+-${_pkg_version}}.local.patch"			\
				"patches/${_pkg_name}${_pkg_version:+-${_pkg_version}}.local@${BUILD_HNAME}.patch"	\
				"patches/${_pkg_name}${_pkg_version:+-${_pkg_version}}_pre.local.patch"			\
				"patches/${_pkg_name}${_pkg_version:+-${_pkg_version}}_pre.local@${BUILD_HNAME}.patch"	\
				"${BUILD_WORKDIR}/chainport/patches/${_pkg_name%%_*}/${_pkg_name%%_*}-${_pkg_version}.midipix.patch"; do
			if [ -e "${_fname}" ]; then
				sha256sum "${_fname}";
			fi;
		done;
		set -o noglob;
	fi; return "${_rc}";
};

pkgtoolp_mirror() {
	local _mirror_dname="${1}" _group_name="" _pkg_name="" _pkg_parent="" _rc=0;
	umask 022;
	if ! ex_pkg_load_groups; then
		_rc=1; _status="Error: failed to load build groups.";
	else	for _group_name in ${EX_PKG_BUILD_GROUPS}; do
			for _pkg_name in $(ex_pkg_get_packages "${_group_name}"); do
				_pkg_parent="$(rtl_get_var_unsafe -u "PKG_${_pkg_name}_INHERIT_FROM")";
				pkgtoolp_mirror_fetch "${_mirror_dname}" "${_pkg_name}" "${_pkg_parent:-${_pkg_name}}"; _rc="${?}";
			done;
		done;
	fi; return "${_rc}";
};

pkgtoolp_mirror_fetch() {
	local _mirror_dname="${1}" _pkg_name="${2}" _pkg_name_real="${3}" _pkg_sha256sum="" _pkg_url="";
	if _pkg_url="$(rtl_get_var_unsafe -u "PKG_${_pkg_name_real}_URL")"\
	&& _pkg_sha256sum="$(rtl_get_var_unsafe -u "PKG_${_pkg_name_real}_SHA256SUM")"; then
		if [ "${_pkg_name}" != "${_pkg_name_real}" ]; then
			rtl_log_msg info "Mirroring package \`%s' (parent package: \`%s'), archive URL(s): \`%s'..." "${_pkg_name}" "${_pkg_name_real}" "${_pkg_url}";
		else
			rtl_log_msg info "Mirroring package \`%s', archive URL(s): \`%s'..." "${_pkg_name}" "${_pkg_url}";
		fi;
		if ! rtl_fileop mkdir "${_mirror_dname}/${_pkg_name}"\
		|| ! rtl_fetch_url_wget "${_pkg_url}" "${_pkg_sha256sum}" "${_mirror_dname}/${_pkg_name}" "${_pkg_url##*/}" "${_pkg_name_real}" ""; then
			_rc="${?}"; rtl_log_msg warning "Failed to mirror package \`%s', skipping." "${_pkg_name}";
		fi;
	elif _pkg_url="$(rtl_get_var_unsafe -u "PKG_${_pkg_name_real}_URLS_GIT")"; then
		if [ "${_pkg_name}" != "${_pkg_name_real}" ]; then
			rtl_log_msg info "Mirroring package \`%s' (parent package: \`%s'), Git URL(s): \`%s'..." "${_pkg_name}" "${_pkg_name_real}" "${_pkg_url}";
		else
			rtl_log_msg info "Mirroring package \`%s', Git URL(s): \`%s'..." "${_pkg_name}" "${_pkg_url}";
		fi;
		if ! rtl_fileop mkdir "${_mirror_dname}/${_pkg_name}"\
		|| ! rtl_fetch_urls_git "${_mirror_dname}/${_pkg_name}" "${_mirror_dname}/${_pkg_name}" "" ${_pkg_url}; then
			_rc="${?}"; rtl_log_msg warning "Failed to mirror package \`%s', skipping." "${_pkg_name}";
		fi;
	else
		rtl_log_msg warning "Package \`%s' has neither archive nor Git URL(s), skipping." "${_pkg_name}";
	fi;
};

pkgtoolp_restart_at() {
	local _pkg_name="${1}" _rc=0; _status="";
	if ! ex_pkg_load_dump "${_pkg_name}" "${BUILD_WORKDIR}"; then
		_rc=1; _status="${_status}";
	else	case "${ARG_RESTART_AT}" in
		ALL)	if ! "${MIDIPIX_BUILD_PWD}/build.sh" -P -r "${_pkg_name}" -v; then
				_rc=1; _status="Error: failed to run command line ${MIDIPIX_BUILD_PWD}/build.sh -P -r ${_pkg_name} -v";
			fi; ;;
		*)	if ! "${MIDIPIX_BUILD_PWD}/build.sh" -P -r "${_pkg_name}:${ARG_RESTART_AT}" -v; then
				_rc=1; _status="Error: failed to run command line ${MIDIPIX_BUILD_PWD}/build.sh -P -r ${_pkg_name}:${ARG_RESTART_AT} -v";
			fi; ;;
		esac;
	fi; return "${_rc}";
};

pkgtoolp_rdepends() {
	local	_pkg_name="${1}" _group_name="" _pkg_depends="" _pkg_name_rdepend="" _pkg_names=""\
		_pkg_rdepends="" _rc=0 EX_PKG_BUILD_GROUPS="" EX_PKG_DISABLED="" EX_PKG_RDEPENDS_DIRECT=""; _status="";
	if ! ex_pkg_load_groups; then
		_rc=1; _status="Error: failed to load build groups.";
	elif ! _group_name="$(ex_pkg_find_package "${EX_PKG_BUILD_GROUPS}" "${_pkg_name}")"; then
		_rc=1; _status="Error: unknown package \`${_pkg_name}'.";
	elif ! _pkg_names="$(ex_pkg_get_packages "${_group_name}")"; then
		_rc=1; _status="Error: failed to expand package list of build group \`${_group_name}'.";
	elif ! ex_pkg_unfold_rdepends_direct "${_group_name}" "${_pkg_names}" "${_pkg_name}"; then
		_rc=1; _status="Error: failed to unfold reverse dependency-expanded package name list for \`${_pkg_name}'.";
	elif [ -z "${EX_PKG_DISABLED}" ] && [ -z "${EX_PKG_RDEPENDS_DIRECT}" ]; then
		rtl_log_msg info "Package \`%s' has no reverse dependencies." "${_pkg_name}";
	else	for _pkg_name_rdepend in $(rtl_lsort "${EX_PKG_RDEPENDS_DIRECT}"); do
			_pkg_rdepends="$(rtl_lconcat "${_pkg_rdepends}" "${_pkg_name_rdepend}")";
			if _pkg_depends="$(rtl_lunfold_depends 'PKG_${_name}_DEPENDS' $(rtl_get_var_unsafe -u "PKG_"${_pkg_name}"_DEPENDS"))"\
			&& [ -n "${_pkg_depends}" ]; then
				_pkg_rdepends="$(rtl_lconcat "${_pkg_rdepends}" "[33m${_pkg_depends}[93m")";
			fi;
		done;
		if [ -n "${_pkg_rdepends}" ]; then
			rtl_log_msg info "Reverse dependencies of \`%s': %s" "${_pkg_name}" "${_pkg_rdepends}";
		fi;
		if [ -n "${EX_PKG_DISABLED}" ]; then
			rtl_log_msg info "Reverse dependencies of \`%s' (disabled packages:) %s"\
					"${_pkg_name}" "$(rtl_lsort "${EX_PKG_DISABLED}")";
		fi;
	fi; return "${_rc}";
};

pkgtoolp_shell() {
	local _pkg_name="${1}" _rc=0; _status="";
	if ! ex_pkg_load_dump "${_pkg_name}" "${BUILD_WORKDIR}"; then
		_rc=1; _status="${_status}";
	else	rtl_log_env_vars "package" $(rtl_get_vars_fast "^PKG_");
		rtl_log_msg info "Launching shell \`%s' within package environment and \`%s'." "${SHELL}" "${PKG_BUILD_DIR}";
		rtl_log_msg info "Run \$R to rebuild \`%s'." "${_pkg_name}";
		rtl_log_msg info "Run \$RS <step> to restart the specified build step of \`%s'" "${_pkg_name}";
		rtl_log_msg info "Run \$D to automatically regenerate the patch for \`%s'." "${_pkg_name}";
		export	ARCH BUILD_KIND						\
			BUILD_DLCACHEDIR BUILD_WORKDIR				\
			MAKE="make LIBTOOL=${PKG_LIBTOOL:-slibtool}"		\
			MIDIPIX_BUILD_PWD					\
			PKG_NAME						\
			PREFIX PREFIX_CROSS PREFIX_MINGW32 PREFIX_MINIPIX	\
			PREFIX_NATIVE PREFIX_ROOT PREFIX_RPM;
		D="${MIDIPIX_BUILD_PWD}/${0##*/} --update-diff"			\
		R="${MIDIPIX_BUILD_PWD}/${0##*/} --restart-at ALL"		\
		RS="${MIDIPIX_BUILD_PWD}/${0##*/} --restart-at "		\
		"${SHELL}";
	fi; return "${_rc}";
};

pkgtoolp_tarball() {
	local	_pkg_name="${1}" _date="" _group_name="" _hname="" _pkg_name_full=""\
		_pkg_version="" _rc=0 _tarball_fname="" EX_PKG_BUILD_GROUPS=""; _status="";
	if ! ex_pkg_load_groups; then
		_rc=1; _status="Error: failed to load build groups.";
	elif ! _group_name="$(ex_pkg_find_package "${EX_PKG_BUILD_GROUPS}" "${_pkg_name}")"; then
		_rc=1; _status="Error: unknown package \`${_pkg_name}'.";
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"	\
			"${_group_name}" 0 "${_pkg_name}" "" "${BUILD_WORKDIR}"; then
		_rc=1; _status="Error: failed to set package environment for \`${_pkg_name}'.";
	elif ! _date="$(date +%Y%m%d_%H%M%S)"; then
		_rc=1; _status="Error: failed to call date(1).";
	elif ! _hname="$(hostname -f)"; then
		_rc=1; _status="Error: failed to call hostname(1).";
	else	if [ -n "${PKG_VERSION}" ]; then
			_pkg_name_full="${_pkg_name}-${PKG_VERSION}";
		else
			_pkg_name_full="${_pkg_name}";
		fi;
		_tarball_fname="${_pkg_name_full}@${_hname}-${_date}.tbz2";
		rtl_log_msg info "Creating compressed tarball of \`%s' and \`%s_stderrout.log'..."\
				"${PKG_BASE_DIR}" "${_pkg_name}";
		if ! tar -C "${BUILD_WORKDIR}" -cpf -				\
				"${PKG_BASE_DIR#${BUILD_WORKDIR%/}/}"		\
				"${_pkg_name}_stderrout.log"			|\
					bzip2 -c -9 - > "${_tarball_fname}"; then
			_rc=1; _status="Error: failed to create compressed tarball of \`${PKG_BASE_DIR}' and \`${_pkg_name}_stderrout.log'.";
		else
			rtl_log_msg info "Created compressed tarball of \`%s' and \`%s_stderrout.log'."\
					"${PKG_BASE_DIR}" "${_pkg_name}";
		fi;
	fi; return "${_rc}";
};

pkgtoolp_update_diff() {
	local	_pkg_name="${1}" _diff_fname_dst="" _diff_fname_src="" _fname=""\
		_fname_base="" _rc=0; _status="";
	if ! ex_pkg_load_dump "${_pkg_name}" "${BUILD_WORKDIR}"; then
		_rc=1; _status="${_status}";
	else	if [ -n "${PKG_VERSION}" ]; then
			_diff_fname_dst="${_pkg_name}-${PKG_VERSION}.local.patch";
		else
			_diff_fname_dst="${_pkg_name}.local.patch";
		fi;
		if ! _diff_fname_src="$(mktemp)"; then
			_rc=1; _status="Error: failed to create temporary target diff(1) file.";
		else	trap "rm -f \"${_diff_fname_src}\" >/dev/null 2>&1" EXIT HUP INT TERM USR1 USR2;
			(cd "${PKG_BASE_DIR}" && printf "" > "${_diff_fname_src}";
			 for _fname in $(find "${PKG_SUBDIR}" -iname \*.orig); do
				_fname_base="${_fname##*/}"; _fname_base="${_fname_base%.orig}";
				case "${_fname_base}" in
				config.sub)
					continue; ;;
				*)	diff -u "${_fname}" "${_fname%.orig}" >> "${_diff_fname_src}"; ;;
				esac;
			done);
			if [ "${?}" -ne 0 ]; then
				_rc=1; _status="Error: failed to create diff(1).";
			elif ! rtl_fileop mv "${_diff_fname_src}" "${MIDIPIX_BUILD_PWD}/patches/${_diff_fname_dst}"; then
				_rc=1; _status="Error: failed to rename diff(1) to \`${MIDIPIX_BUILD_PWD}/patches/${_diff_fname_dst}'.";
			else	trap - EXIT HUP INT TERM USR1 USR2;
				rtl_log_msg info "Updated \`%s/patches/%s'."\
						"${MIDIPIX_BUILD_PWD}" "${_diff_fname_dst}";
			fi;
		fi;
	fi; return "${_rc}";
};

pkgtool() {
	local _rc=0 _status="" BUILD_GROUPS="" ARCH BUILD_KIND BUILD_WORKDIR PKGTOOL_PKGNAME PREFIX;
	if ! . "${0%/*}/subr/pkgtool_init.subr"; then
		_rc=1; printf "Error: failed to source \`${0%/*}/subr/pkgtool_init.subr'." >&2;
	elif ! pkgtool_init "${@}"; then
		_rc=1; _status="${_status}";
	else	case "1" in
		"${ARG_INFO:-0}")		pkgtoolp_info "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_MIRROR:-0}")		pkgtoolp_mirror "${ARG_MIRROR_DNAME}"; ;;
		"${ARG_RDEPENDS:-0}")		pkgtoolp_rdepends "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_RESTART_AT:+1}")		pkgtoolp_restart_at "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_SHELL:-0}")		pkgtoolp_shell "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_TARBALL:-0}")		pkgtoolp_tarball "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_UPDATE_DIFF:-0}")	pkgtoolp_update_diff "${PKGTOOL_PKG_NAME}"; ;;
		esac; _rc="${?}";
	fi;
	if [ "${_rc}" -ne 0 ]; then
		rtl_log_msg fatalexit "${_status}";
	elif [ -n "${_status}" ]; then
		rtl_log_msg info "${_status}";
	fi;
};

set +o errexit -o noglob -o nounset; pkgtool "${@}";

# vim:filetype=sh textwidth=0

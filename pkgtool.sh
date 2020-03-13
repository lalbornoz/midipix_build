#!/bin/sh
# Copyright (c) 2020 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

pkgtoolp_info() {
	local	_group_name="" _pkg_name_uc="$(rtl_toupper "${PKG_NAME}")" _pkg_names=""	\
		EX_PKG_DISABLED=""; EX_PKG_FINISHED=""; EX_PKG_NAMES="";
	if ! _group_name="$(ex_pkg_find_package "${BUILD_GROUPS}" "${PKG_NAME}")"; then
		rtl_log_msg failexit "Error: unknown package \`${PKG_NAME}'.";
	elif ! _pkg_names="$(ex_pkg_get_packages "${_group_name}")"; then
		rtl_log_msg failexit "Error: failed to expand package list of build group \`${_group_name}'.";
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"	\
			"${_group_name}" 1 "${PKG_NAME}" "" "${BUILD_WORKDIR}"; then
		rtl_log_msg failexit "Error: failed to set package environment for \`${PKG_NAME}'.";
	else	rtl_log_env_vars "package" $(set | awk -F= '/^PKG_'"${_pkg_name_uc}"'_/{print $1}' | sort);
		if [ -z "${PKG_DEPENDS}" ]; then
			rtl_log_msg info "Package \`${PKG_NAME}' has no dependencies.";
		else	rtl_log_msg info "Direct dependencies of \`${PKG_NAME}': ${PKG_DEPENDS}";
			if ! ex_pkg_unfold_depends "${_group_name}" "${_pkg_names}" "${PKG_NAME}" 2 0; then
				rtl_log_msg warn "Warning: failed to unfold dependency-expanded package name list for \`${PKG_NAME}'.";
			else	EX_PKG_NAMES="$(rtl_lfilter "${EX_PKG_NAMES}" "${PKG_NAME}")";
				if [ -n "${EX_PKG_NAMES}" ]; then
					rtl_log_msg info "Full dependencies of \`${PKG_NAME}': $(rtl_lsort "${EX_PKG_NAMES}")";
				fi;
				if [ -n "${EX_PKG_DISABLED}" ]; then
					rtl_log_msg info "Full dependencies of \`${PKG_NAME}' (disabled packages:) $(rtl_lsort "${EX_PKG_DISABLED}")";
				fi;
			fi;
		fi;
	fi;
};

pkgtoolp_restart_at() {
	case "${ARG_RESTART_AT}" in
	ALL)	"${MIDIPIX_BUILD_PWD}/build.sh" -P -r "${PKG_NAME}" -v; ;;
	*)	"${MIDIPIX_BUILD_PWD}/build.sh" -P -r "${PKG_NAME}:${ARG_RESTART_AT}" -v; ;;
	esac;
};

pkgtoolp_rdepends() {
	local _group_name="" _pkg_names="" EX_PKG_DISABLED=""; EX_PKG_FINISHED=""; EX_PKG_NAMES="";
	if ! _group_name="$(ex_pkg_find_package "${BUILD_GROUPS}" "${PKG_NAME}")"; then
		rtl_log_msg failexit "Error: unknown package \`${PKG_NAME}'.";
	elif ! _pkg_names="$(ex_pkg_get_packages "${_group_name}")"; then
		rtl_log_msg failexit "Error: failed to expand package list of build group \`${_group_name}'.";
	elif ! ex_pkg_unfold_rdepends "${_group_name}" "${_pkg_names}" "${PKG_NAME}" 0; then
		rtl_log_msg failexit "Error: failed to unfold reverse dependency-expanded package name list for \`${PKG_NAME}'.";
	elif [ -z "${EX_PKG_NAMES}" ] && [ -z "${EX_PKG_DISABLED}" ]; then
		rtl_log_msg info "Package \`${PKG_NAME}' has no reverse dependencies.";
	else	if [ -n "${EX_PKG_NAMES}" ]; then
			rtl_log_msg info "Reverse dependencies of \`${PKG_NAME}': $(rtl_lsort "${EX_PKG_NAMES}")";
		fi;
		if [ -n "${EX_PKG_DISABLED}" ]; then
			rtl_log_msg info "Reverse dependencies of \`${PKG_NAME}' (disabled packages:) $(rtl_lsort "${EX_PKG_DISABLED}")";
		fi;
	fi;
};

pkgtoolp_shell() {
	rtl_log_env_vars "build" $(set | awk -F= '/^PKG_/{print $1}' | sort);
	rtl_log_msg info "Launching shell \`${SHELL}' within package environment and \`${PKG_BUILD_DIR}'.";
	rtl_log_msg info "Run \$R to rebuild \`${PKG_NAME}'.";
	rtl_log_msg info "Run \$RS <step> to restart the specified build step of \`${PKG_NAME}'";
	rtl_log_msg info "Run \$D to automatically regenerate the patch for \`${PKG_NAME}'.";
	export	ARCH BUILD							\
		BUILD_DLCACHEDIR BUILD_WORKDIR					\
		MAKE="make LIBTOOL=${PKG_LIBTOOL:-slibtool}"			\
		MIDIPIX_BUILD_PWD						\
		PKG_NAME							\
		PREFIX PREFIX_CROSS PREFIX_MINGW32 PREFIX_MINIPIX		\
		PREFIX_NATIVE PREFIX_ROOT PREFIX_RPM;
	D="${MIDIPIX_BUILD_PWD}/${0##*/} --update-diff"				\
	R="${MIDIPIX_BUILD_PWD}/${0##*/} --restart-at ALL"			\
	RS="${MIDIPIX_BUILD_PWD}/${0##*/} --restart-at "			\
	"${SHELL}";
};

pkgtoolp_tarball() {
	local _date="" _group_name="" _hname="" _pkg_name_full="" _pkg_version="" _tarball_fname="";
	if ! _group_name="$(ex_pkg_find_package "${BUILD_GROUPS}" "${PKG_NAME}")"; then
		rtl_log_msg failexit "Error: unknown package \`${PKG_NAME}'.";
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"	\
			"${_group_name}" "${PKG_NAME}" "" "${BUILD_WORKDIR}"; then
		rtl_log_msg failexit "Error: failed to set package environment for \`${PKG_NAME}'.";
	elif ! _date="$(date +%Y%m%d_%H%M%S)"; then
		rtl_log_msg failexit "Error: failed to call date(1).";
	elif ! _hname="$(hostname -f)"; then
		rtl_log_msg failexit "Error: failed to call hostname(1).";
	else	if [ -n "${PKG_VERSION}" ]; then
			_pkg_name_full="${PKG_NAME}-${PKG_VERSION}";
		else
			_pkg_name_full="${PKG_NAME}";
		fi;
		_tarball_fname="${_pkg_name_full}@${_hname}-${_date}.tbz2";
		rtl_log_msg info "Creating compressed tarball of \`${PKG_BASE_DIR}' and \`${PKG_NAME}_stderrout.log'...";
		if ! tar -C "${BUILD_WORKDIR}" -cpf -				\
				"${PKG_BASE_DIR#${BUILD_WORKDIR%/}/}"		\
				"${PKG_NAME}_stderrout.log"			|\
					bzip2 -c -9 - > "${_tarball_fname}"; then
			rtl_log_msg failexit "Error: failed to create compressed tarball of \`${PKG_BASE_DIR}' and \`${PKG_NAME}_stderrout.log'.";
		else
			rtl_log_msg info "Created compressed tarball of \`${PKG_BASE_DIR}' and \`${PKG_NAME}_stderrout.log'.";
		fi;
	fi;
};

pkgtoolp_update_diff() {
	local _diff_fname_dst="" _diff_fname_src="" _fname="" _fname_base="";
	if [ -n "${PKG_VERSION}" ]; then
		_diff_fname_dst="${PKG_NAME}-${PKG_VERSION}.local.patch";
	else
		_diff_fname_dst="${PKG_NAME}.local.patch";
	fi;
	if ! _diff_fname_src="$(mktemp)"; then
		rtl_log_msg failexit "Error: failed to create temporary target diff(1) file.";
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
			rtl_log_msg failexit "Error: failed to create diff(1).";
		elif ! rtl_fileop mv "${_diff_fname_src}" "${MIDIPIX_BUILD_PWD}/patches/${_diff_fname_dst}"; then
			rtl_log_msg failexit "Error: failed to rename diff(1) to \`${MIDIPIX_BUILD_PWD}/patches/${_diff_fname_dst}'.";
		else	trap - EXIT HUP INT TERM USR1 USR2;
			rtl_log_msg info "Updated \`${MIDIPIX_BUILD_PWD}/patches/${_diff_fname_dst}'.";
		fi;
	fi;
};

pkgtool() {
	local _status="";
	if ! cd "$(dirname "${0}")"\
	|| ! . ./subr/pkgtool_init.subr\
	|| ! pkgtool_init "${@}"; then
		printf "Error: failed to setup environment.\n"; exit 1;
	elif [ -n "${ARG_RESTART_AT}" ]; then
		pkgtoolp_restart_at;
	elif [ "${ARG_UPDATE_DIFF:-0}" -eq 1 ]; then
		pkgtoolp_update_diff;
	elif [ "${ARG_INFO:-0}" -eq 1 ]; then
		pkgtoolp_info;
	elif [ "${ARG_RDEPENDS:-0}" -eq 1 ]; then
		pkgtoolp_rdepends;
	elif [ "${ARG_SHELL:-0}" -eq 1 ]; then
		pkgtoolp_shell;
	elif [ "${ARG_TARBALL:-0}" -eq 1 ]; then
		pkgtoolp_tarball;
	fi;
};

set +o errexit -o noglob; pkgtool "${@}";

# vim:filetype=sh textwidth=0

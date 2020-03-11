#!/bin/sh
# Copyright (c) 2019 Lucio Andrés Illanes Albornoz <lucio@lucioillanes.de>
#

pkgtoolp_restart_at() {
	case "${ARG_RESTART_AT}" in
	ALL)	"${MIDIPIX_BUILD_PWD}/build.sh" -P -r "${PKG_NAME}" -v; ;;
	*)	"${MIDIPIX_BUILD_PWD}/build.sh" -P -r "${PKG_NAME}:${ARG_RESTART_AT}" -v; ;;
	esac;
};

pkgtoolp_shell() {
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

pkgtoolp_env() {
	local _rc=0; _status="";
	if [ ! -e "${BUILD_WORKDIR}/${PKG_NAME}.dump" ]; then
		rtl_log_msg fail "Warning: failed to locate environment dump for package \`${PKG_NAME}' in \`${BUILD_WORKDIR}'.";
		rtl_log_msg info "Rebuilding package \`${PKG_NAME}' w/ --dump-in build...";
		(export	ARCH BUILD						\
			BUILD_DLCACHEDIR BUILD_WORKDIR				\
			PREFIX PREFIX_CROSS PREFIX_MINGW32 PREFIX_MINIPIX	\
			PREFIX_NATIVE PREFIX_ROOT PREFIX_RPM;
		./build.sh -a "${ARCH}" -b "${BUILD}" --dump-in build -P -r "${PKG_NAME}" -v);
		if [ ! -e "${BUILD_WORKDIR}/${PKG_NAME}.dump" ]; then
			_rc=1; _status="Error: failed to locate environment dump for package \`${PKG_NAME}' in \`${BUILD_WORKDIR}'.";
		fi;
	else
		_rc=0;
	fi;
	if [ "${_rc:-0}" -eq 0 ]\
	&& ! . "${BUILD_WORKDIR}/${PKG_NAME}.dump"; then
		_rc=1; _status="Error: failed to source environment dump for package \`${PKG_NAME}' from \`${BUILD_WORKDIR}'.";
	fi; return "${_rc}";
};
	
pkgtool() {
	local _status="";
	if ! cd "$(dirname "${0}")"\
	|| ! . ./subr/pkgtool_init.subr\
	|| ! pkgtool_init "${@}"; then
		printf "Error: failed to setup environment.\n"; exit 1;
	elif ! pkgtoolp_env; then
		rtl_log_msg failexit "${_status}";
	elif ! rtl_fileop cd "${PKG_BUILD_DIR}"; then
		rtl_log_msg failexit "Error: failed to change working directory to \`${PKG_BUILD_DIR}'.";
	elif [ -n "${ARG_RESTART_AT}" ]; then
		pkgtoolp_restart_at;
	elif [ "${ARG_UPDATE_DIFF:-0}" -eq 1 ]; then
		pkgtoolp_update_diff;
	else	pkgtoolp_shell;
	fi;
};

set +o errexit -o noglob; pkgtool "${@}";

# vim:filetype=sh textwidth=0

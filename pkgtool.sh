#!/bin/sh
# Copyright (c) 2020, 2021, 2022, 2023 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

# {{{ pkgtoolp_init($_rstatus)
pkgtoolp_init() {
	local	_pi_rstatus="${1#\$}"						\
		_pi_args_long=""						\
		_pi_name_base="pkgtool"						\
		_pi_optstring="a:b:him:M:rRtv"					\
		_pi_prereqs="
			awk bzip2 cat chmod cp date find grep hostname mkdir
			mktemp mv paste printf readlink rm sed sort tar test
			touch tr uniq"						\
		_pi_fname="" _pi_rc=0;
	shift;

	if [ -e "${HOME}/pkgtool.vars" ]; then
		. "${HOME}/pkgtool.vars" || exit 1;
	fi;

	if ! . "${0%/*}/subr.ex/ex_init.subr"; then
		_pi_rc=1;
		_pi_status='failed to source \`'"${0%/*}/subr/ex_init.subr"\';
		eval ${_pi_rstatus}=\"${_pi_status}\";
	elif ! ex_init_help						\
			"${_pi_rstatus}" "${_pi_args_long}"		\
			"${_pi_name_base}" "${_pi_optstring}" "${@}"	\
	  || ! ex_init_env						\
	  		"${_pi_rstatus}" \$BUILD_HNAME \$BUILD_USER	\
			"${_pi_name_base}"				\
	  || ! ex_init_getopts						\
	  		"${_pi_rstatus}" "pkgtoolp_init_getopts_fn"	\
			"${_pi_optstring}" "${@}"			\
	  || ! ex_init_prereqs "${_pi_rstatus}" "${_pi_prereqs}"	\
	  || ! ex_pkg_load_vars						\
	  		"${_pi_rstatus}" \$ARCH \$BUILD_KIND		\
	  || ! pkgtoolp_init_args "${_pi_rstatus}";
	then
		_pi_rc=1;
	fi;
	return "${_pi_rc}";
};
# }}}
# {{{ pkgtoolp_init_args($_rstatus)
pkgtoolp_init_args() {
	local	_ppia_rstatus="${1#\$}"	\
		_ppia_rc=0;

	if [ "$((${ARG_INFO:-0}
	   + ${ARG_MIRROR:-0}
	   + ${ARG_RDEPENDS:-0}
	   + ${ARG_RDEPENDS_FULL:-0}
	   + ${ARG_TARBALL:-0}))" -gt 1 ];
	then
		cat etc/pkgtool.usage;
		_ppia_rc=1;
		rtl_setrstatus "${_ppia_rstatus}" 'only one of -i, -m and/or -M, -r, -R, -s, or -t must be specified.';
	elif [ "$((${ARG_INFO:-0}
	     + ${ARG_MIRROR:-0}
	     + ${ARG_RDEPENDS:-0}
	     + ${ARG_RDEPENDS_FULL:-0}
	     + ${ARG_TARBALL:-0}))" -eq 0 ];
	then
		cat etc/pkgtool.usage;
		_ppia_rc=1;
		rtl_setrstatus "${_ppia_rstatus}" 'one of -i, -m and/or -M, -r, -R, -s, or -t must be specified.';
	else
		_ppia_rc=0;
		export TMP="${BUILD_WORKDIR}" TMPDIR="${BUILD_WORKDIR}";
	fi;

	return "${_ppia_rc}";
};
# }}}
# {{{ pkgtoolp_init_getopts_fn(...)
pkgtoolp_init_getopts_fn() {
	local _ppigf_rc=0 _ppigf_shiftfl=0;

	case "${1}" in
	init)
		local	_ppigf_verb="${1}" _ppigf_rstatus="${2#\$}";

		: ${ARCH:="nt64"};
		: ${BUILD_KIND:="debug"};

		ARG_INFO=0; ARG_MIRROR=0; ARG_RDEPENDS=0;
		ARG_RDEPENDS_FULL=0; ARG_TARBALL=0; ARG_VERBOSE=0;
		;;

	longopt)
		_ppigf_rc=1;
		;;

	opt)
		local	_ppigf_verb="${1}" _ppigf_rstatus="${2#\$}"	\
			_ppigf_opt="${3}" _ppigf_optarg="${4:-}";
		shift 4;

		case "${_ppigf_opt}" in
		a)	ARCH="${OPTARG}"; _ppigf_shiftfl=2; ;;
		b)	BUILD_KIND="${OPTARG}"; _ppigf_shiftfl=2; ;;
		h)	cat etc/pkgtool.usage; exit 0; ;;
		i)	ARG_INFO=1; _ppigf_shiftfl=1; ;;
		m)	ARG_MIRROR=1;
			if [ "${OPTARG:+1}" = 1 ]; then
				ARG_MIRROR_DNAME="${OPTARG}";
			elif [ "${ARG_MIRROR_DNAME:+1}" != 1 ]; then
				rtl_setrstatus "${_ppigf_rstatus}" 'missing -m argument and no default present.';
			fi;
			_ppigf_shiftfl=2; ;;
		M)	ARG_MIRROR=1;
			if [ "${OPTARG:+1}" = 1 ]; then
				ARG_MIRROR_DNAME_GIT="${OPTARG}";
			elif [ "${ARG_MIRROR_DNAME_GIT:+1}" != 1 ]; then
				rtl_setrstatus "${_ppigf_rstatus}" 'missing -M argument and no default present.';
			fi;
			_ppigf_shiftfl=2; ;;
		r)	ARG_RDEPENDS=1; _ppigf_shiftfl=1; ;;
		R)	ARG_RDEPENDS_FULL=1; _ppigf_shiftfl=1; ;;
		t)	ARG_TARBALL=1; _ppigf_shiftfl=1; ;;
		v)	ARG_VERBOSE=1; _ppigf_shiftfl=1; ;;
		*)	cat etc/pkgtool.usage; exit 1; ;;
		esac;
		;;

	nonopt)
		local _ppigf_verb="${1}" _ppigf_rstatus="${2#\$}";
		shift 2;

		case "${1}" in
		*=*)	rtl_set_var_from_cmdline "${_ppigf_rstatus}" "${1}";
			_ppigf_rc="${?}"; ;;
		*)	PKGTOOL_PKG_NAME="${1}"; ;;
		esac;

		if [ "${_ppigf_rc}" -ne 0 ]; then
			return "${_ppigf_rc}";
		else
			_ppigf_shiftfl=1;
		fi;
		;;

	done)
		local _ppigf_verb="${1}" _ppigf_rstatus="${2#\$}";

		if [ "${PKGTOOL_PKG_NAME:+1}" != 1 ]\
		&& [ "${ARG_MIRROR:-0}" -eq 0 ]; then
			_ppigf_rc=1;
			rtl_setrstatus "${_ppigf_rstatus}" 'missing package name.';
		else
			export PKGTOOL_PKG_NAME;
			case "${ARG_VERBOSE:-0}" in

			0)	rtl_log_enable_tags "${LOG_TAGS_normal}"; ;;
			1)	rtl_log_enable_tags "${LOG_TAGS_verbose}"; ;;
			*)	_ppigf_rc=1;
				rtl_setrstatus "${_ppigf_rstatus}" 'invalid verbosity level (max. -v)';
				;;

			esac;
		fi;

		if [ "${_ppigf_rc}" -ne 0 ]; then
			return "${_ppigf_rc}";
		fi;
		;;

	*)
		return 1;
		;;
	esac;

	if [ "${_ppigf_shiftfl}" -ge 1 ]; then
		return "$((${_ppigf_shiftfl} + 1))";
	else
		return 0;
	fi;

	return "${_ppigf_rc}";
};
# }}}

# {{{ pkgtoolp_info($_rstatus, $_pkg_name)
pkgtoolp_info() {
	local	_ppi_rstatus="${1}" _ppi_pkg_name="${2}"				\
		_ppi_fname="" _ppi_group_name="" _ppi_groups="" _ppi_groups_noauto=""	\
		_ppi_patch_idx=0 _ppi_pkg_disabled="" _ppi_pkg_finished=""		\
		_ppi_pkg_name_uc="" _ppi_pkg_names="" _ppi_rc=0;
	rtl_toupper2 \$_ppi_pkg_name \$_ppi_pkg_name_uc;

	if ! ex_pkg_load_groups \$_ppi_groups \$_ppi_groups_noauto \$GROUP_AUTO \$GROUP_TARGET; then
		_ppi_rc=1;
		rtl_setrstatus "${_ppi_rstatus}" 'Error: failed to load build groups.';
	elif ! ex_pkg_find_package \$_ppi_group_name "${_ppi_groups}" "${_ppi_pkg_name}"; then
		_ppi_rc=1;
		rtl_setrstatus "${_ppi_rstatus}" 'Error: unknown package \`'"${_ppi_pkg_name}'"'.';
	elif ! ex_pkg_get_packages \$_ppi_pkg_names "${_ppi_group_name}"; then
		_ppi_rc=1;
		rtl_setrstatus "${_ppi_rstatus}" 'Error: failed to expand package list of build group \`'"${_ppi_group_name}'"'.';
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"\
			"${_ppi_group_name}" "${_ppi_pkg_name}" "" "${BUILD_WORKDIR}"; then
		_ppi_rc=1;
		rtl_setrstatus "${_ppi_rstatus}" 'Error: failed to set package environment for \`'"${_ppi_pkg_name}'"'.';
	else
		rtl_get_var_unsafe \$_ppi_pkg_version -u "PKG_${_ppi_pkg_name}_VERSION";
		rtl_log_env_vars "info" "package" $(rtl_get_vars_fast "^PKG_${_ppi_pkg_name_uc}");
		rtl_log_msg "info" "${MSG_pkgtool_build_group}" "${_ppi_group_name}";

		if [ "${PKG_DEPENDS:+1}" != 1 ]; then
			rtl_log_msg "info" "${MSG_pkgtool_pkg_no_deps}" "${_ppi_pkg_name}";
		else
			rtl_log_msg "info" "${MSG_pkgtool_pkg_direct_deps}" "${_ppi_pkg_name}" "${PKG_DEPENDS}";
			if ! ex_pkg_unfold_depends					\
					\$_ppi_pkg_disabled \$_ppi_pkg_finished		\
					\$_ppi_pkg_names 1 1 "${_ppi_group_name}"	\
					"${_ppi_pkg_names}" "${_ppi_pkg_name}" 0	\
					"${BUILD_WORKDIR}";
			then
				rtl_log_msg "warning" "${MSG_pkgtool_pkg_deps_fail}" "${_ppi_pkg_name}";
			else
				rtl_lfilter \$_ppi_pkg_names "${_ppi_pkg_name}";

				if [ "${_ppi_pkg_names:+1}" = 1 ]; then
					rtl_log_msg "info" "${MSG_pkgtool_pkg_deps_full}"\
							"${_ppi_pkg_name}" "$(rtl_lsort "${_ppi_pkg_names}")";
				fi;

				if [ "${_ppi_pkg_disabled:+1}" = 1 ]; then
					rtl_log_msg "info" "${MSG_pkgtool_pkg_deps_full_disabled}"\
							"${_ppi_pkg_name}" "$(rtl_lsort "${_ppi_pkg_disabled}")";
				fi;
			fi;
		fi;

		_ppi_patch_idx=1;
		while ex_pkg_get_default			\
			\$_ppi_fname "${_ppi_patch_idx}"	\
		       	"${_ppi_pkg_name}"			\
			"${_ppi_pkg_version}"			\
			"vars_file patches_pre patches"		\
		   && [ "${_ppi_fname:+1}" = 1 ];
		do
			: $((_ppi_patch_idx += 1));
			if [ -e "${_ppi_fname}" ]; then
				sha256sum "${_ppi_fname}";
			fi;
		done;
	fi;

	return "${_ppi_rc}";
};
# }}}
# {{{ pkgtoolp_mirror($_rstatus, $_mirror_dname, $_mirror_dname_git)
pkgtoolp_mirror() {
	local	_ppm_rstatus="${1}" _ppm_mirror_dname="${2}" _ppm_mirror_dname_git="${3}"	\
		_ppm_group_name="" _ppm_groups="" _ppm_groups_noauto="" _ppm_pkg_name=""	\
		_ppm_pkg_names="" _ppm_pkg_parent="" _ppm_pkgs_failed="" _ppm_rc=0;

	umask 022;
	rtl_subst \$_ppm_mirror_dname "~" "${HOME}";
	rtl_subst \$_ppm_mirror_dname_git "~" "${HOME}";

	if ! ex_pkg_load_groups \$_ppm_groups \$_ppm_groups_noauto \$GROUP_AUTO \$GROUP_TARGET; then
		_ppm_rc=1;
		rtl_setrstatus "${_ppm_rstatus}" 'Error: failed to load build groups.';
	elif [ "${_ppm_mirror_dname:+1}" = 1 ]\
	&& ! rtl_fileop mkdir "${_ppm_mirror_dname}"; then
		_ppm_rc=1;
		rtl_setrstatus "${_ppm_rstatus}" 'Error: failed to create \`${_ppm_mirror_dname}'"'"'.';
	elif [ "${_ppm_mirror_dname_git:+1}" = 1 ]\
	&& ! rtl_fileop mkdir "${_ppm_mirror_dname_git}"; then
		_ppm_rc=1;
		rtl_setrstatus "${_ppm_rstatus}" 'Error: failed to create \`${_ppm_mirror_dname_git}'"'"'.';
	else
		for _ppm_group_name in ${_ppm_groups}; do
			ex_pkg_get_packages \$_ppm_pkg_names "${_ppm_group_name}";

			for _ppm_pkg_name in ${_ppm_pkg_names}; do
				rtl_get_var_unsafe \$_ppm_pkg_parent -u "PKG_${_ppm_pkg_name}_INHERIT_FROM";
				if ! pkgtoolp_mirror_fetch					\
						"${_ppm_rstatus}" "${_ppm_mirror_dname}"	\
						"${_ppm_mirror_dname_git}" "${_ppm_pkg_name}"	\
						"${_ppm_pkg_parent:-${_ppm_pkg_name}}"		\
						\$_ppm_pkgs_failed;
				then
					_ppm_rc=1;
					rtl_setrstatus "${_ppm_rstatus}" 'Warning: failed to mirror one or more packages: '"${_ppm_pkgs_failed}";
				fi;
			done;
		done;
	fi;

	return "${_ppm_rc}";
};
# }}}
# {{{ pkgtoolp_mirror_fetch($_rstatus, $_mirror_dname, $_mirror_dname_git, $_pkg_name, $_pkg_name_real, $_rpkgs_failed)
pkgtoolp_mirror_fetch() {
	local	_ppmf_rstatus="${1}" _ppmf_mirror_dname="${2}" _ppmf_mirror_dname_git="${3}" _ppmf_pkg_name="${4}"	\
		_ppmf_pkg_name_real="${5}" _ppmf_rpkgs_failed="${6#\$}"							\
		_ppmf_fname="" _ppmf_pkg_disabled=0 _ppmf_pkg_fname="" _ppmf_pkg_mirrors_git="" _ppmf_pkg_sha256sum=""	\
		_ppmf_pkg_url="" _ppmf_pkg_urls_git="" _ppmf_rc=0;

	if rtl_get_var_unsafe \$_ppmf_pkg_disabled -u "PKG_${_ppmf_pkg_name_real}_DISABLED"\
	&& [ "${_ppmf_pkg_disabled:-0}" -eq 1 ]; then
		rtl_log_msg "verbose" "${MSG_pkgtool_pkg_disabled}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}";
	else
		if rtl_get_var_unsafe \$_ppmf_pkg_url -u "PKG_${_ppmf_pkg_name_real}_URL"\
		&& rtl_get_var_unsafe \$_ppmf_pkg_sha256sum -u "PKG_${_ppmf_pkg_name_real}_SHA256SUM"\
		&& [ "${_ppmf_pkg_url:+1}" = 1 ]\
		&& [ "${_ppmf_pkg_sha256sum:+1}" = 1 ];
		then

			if [ "${_ppmf_mirror_dname:+1}" != 1 ]; then
				_ppmf_rc=0; rtl_log_msg "verbose" "${MSG_pkgtool_pkg_skip_archive_mirror}" "${_ppmf_pkg_name}";

			elif [ "${_ppmf_pkg_name}" != "${_ppmf_pkg_name_real}" ]; then
				rtl_log_msg "info" "${MSG_pkgtool_pkg_archive_mirroring_parent}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}" "${_ppmf_pkg_url}";
				if ! rtl_fileop ln_symbolic "${_ppmf_pkg_name_real}" "${_ppmf_mirror_dname}/${_ppmf_pkg_name}"; then
					_ppmf_rc=1; rtl_log_msg "warning" "${MSG_pkgtool_pkg_link_fail}"\
							"${_ppmf_mirror_dname}/${_ppmf_pkg_name}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}";
				fi;

			else
				if rtl_get_var_unsafe \$_ppmf_pkg_fname -u "PKG_${_ppmf_pkg_name_real}_FNAME"\
				&& [ "${_ppmf_pkg_fname:+1}" != 1 ]; then
					_ppmf_pkg_fname="${_ppmf_pkg_url##*/}";
				fi;
				rtl_log_msg "info" "${MSG_pkgtool_pkg_archive_mirroring}" "${_ppmf_pkg_name}" "${_ppmf_pkg_url}";

				if ! rtl_fileop mkdir "${_ppmf_mirror_dname}/${_ppmf_pkg_name}"\
				|| ! rtl_fetch_url_wget						\
						"${_ppmf_pkg_url}"				\
						"${_ppmf_pkg_sha256sum}"			\
						"${_ppmf_mirror_dname}/${_ppmf_pkg_name}"	\
						"${_ppmf_pkg_fname}" "${_ppmf_pkg_name_real}"	\
						"";
				then
					_ppmf_rc=1;
					rtl_log_msg "warning" "${MSG_pkgtool_pkg_mirror_fail}" "${_ppmf_pkg_name}";
					rtl_lconcat "${_ppmf_rpkgs_failed}" "${_ppmf_pkg_name}";
				else
					rtl_fetch_clean_dlcache		\
					       "${_ppmf_mirror_dname}"	\
					       "${_ppmf_pkg_name}"	\
					       "${_ppmf_pkg_fname}"	\
					       "${_ppmf_pkg_urls_git}";
				fi;
			fi;

		fi;

		if rtl_get_var_unsafe \$_ppmf_pkg_urls_git -u "PKG_${_ppmf_pkg_name_real}_URLS_GIT"\
		&& [ "${_ppmf_pkg_urls_git:+1}" = 1 ];
		then

			if [ "${_ppmf_mirror_dname_git:+1}" != 1 ]; then
				_ppmf_rc=0; rtl_log_msg "verbose" "${MSG_pkgtool_pkg_skip_git_mirror}" "${_ppmf_pkg_name}";

			elif rtl_get_var_unsafe \$_ppmf_pkg_mirrors_git -u "PKG_${_ppmf_pkg_name_real}_MIRRORS_GIT"\
			&&   [ "${_ppmf_pkg_mirrors_git}" = "skip" ]; then
				_ppmf_rc=0; rtl_log_msg "verbose" "${MSG_pkgtool_pkg_skip_git_mirror_disabled}" "${_ppmf_pkg_name}";

			elif [ "${_ppmf_pkg_name}" != "${_ppmf_pkg_name_real}" ]; then
				rtl_log_msg "info" "${MSG_pkgtool_pkg_git_mirroring_parent}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}" "${_ppmf_pkg_urls_git}";
				if ! rtl_fileop ln_symbolic "${_ppmf_pkg_name_real}" "${_ppmf_mirror_dname_git}/${_ppmf_pkg_name}"; then
					_ppmf_rc=1;
					rtl_log_msg "warning" "${MSG_pkgtool_pkg_link_fail}"	\
						"${_ppmf_mirror_dname_git}/${_ppmf_pkg_name}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}";
					rtl_lconcat "${_ppmf_rpkgs_failed}" "${_ppmf_pkg_name}";
				fi;

			else
				rtl_log_msg "info" "${MSG_pkgtool_pkg_git_mirroring}" "${_ppmf_pkg_name}" "${_ppmf_pkg_urls_git}";
				if ! rtl_fileop mkdir "${_ppmf_mirror_dname_git}/${_ppmf_pkg_name}"\
				|| ! rtl_fetch_mirror_urls_git "${DEFAULT_GIT_ARGS}" "${_ppmf_mirror_dname_git}/${_ppmf_pkg_name}" ${_ppmf_pkg_urls_git}; then
					_ppmf_rc=1;
					rtl_log_msg "warning" "${MSG_pkgtool_pkg_mirror_fail}" "${_ppmf_pkg_name}";
					rtl_lconcat "${_ppmf_rpkgs_failed}" "${_ppmf_pkg_name}";
				else
					rtl_fetch_clean_dlcache "${_ppmf_mirror_dname_git}" "${_ppmf_pkg_name}" "${_ppmf_pkg_fname}" "${_ppmf_pkg_urls_git}";
				fi;
			fi;

		fi;

		if [ "${_ppmf_pkg_url:+1}" != 1 ]\
		&& [ "${_ppmf_pkg_sha256sum:+1}" != 1 ]\
		&& [ "${_ppmf_pkg_urls_git:+1}" != 1 ]; then
			_ppmf_rc=0; rtl_log_msg "verbose" "${MSG_pkgtool_pkg_skip_no_urls}" "${_ppmf_pkg_name}";
		fi;
	fi;

	return "${_ppmf_rc}";
};
# }}}
# {{{ pkgtoolp_rdepends($_rstatus, $_pkg_name, $_full_rdependsfl)
pkgtoolp_rdepends() {
	local	_ppr_rstatus="${1}" _ppr_pkg_name="${2}" _ppr_full_rdependsfl="${3}"	\
		_ppr_depends="" _ppr_group_name="" _ppr_groups="" _ppr_groups_noauto=""	\
		_ppr_pkg_depends="" _ppr_pkg_disabled="" _ppr_pkg_finished=""		\
		_ppr_pkg_name_rdepend="" _ppr_pkg_names="" _ppr_pkg_rdepends=""		\
		_ppr_pkg_rdepends_direct="" _ppr_rc=0;

	if ! ex_pkg_load_groups \$_ppr_groups \$_ppr_groups_noauto \$GROUP_AUTO \$GROUP_TARGET; then
		_ppr_rc=1;
		rtl_setrstatus "${_ppr_rstatus}" 'Error: failed to load build groups.';
	elif ! ex_pkg_find_package \$_ppr_group_name "${_ppr_groups}" "${_ppr_pkg_name}"; then
		_ppr_rc=1;
		rtl_setrstatus "${_ppr_rstatus}" 'Error: unknown package \`'"${_ppr_pkg_name}'"'.';
	elif ! ex_pkg_get_packages \$_ppr_pkg_names "${_ppr_group_name}"; then
		_ppr_rc=1;
		rtl_setrstatus "${_ppr_rstatus}" 'Error: failed to expand package list of build group \`'"${_ppr_group_name}'"'.';
	elif ! ex_pkg_unfold_rdepends					\
			\$_ppr_pkg_disabled \$_ppr_pkg_finished		\
			\$_ppr_pkg_rdepends_direct			\
			"${_ppr_group_name}" "${_ppr_pkg_names}"	\
			"${_ppr_pkg_name}" 1 "${BUILD_WORKDIR}";
	then
		_ppr_rc=1;
		rtl_setrstatus "${_ppr_rstatus}" 'Error: failed to unfold reverse dependency-expanded package name list for \`'"${_ppr_pkg_name}'"'.';
	elif [ "${_ppr_pkg_disabled:+1}" != 1 ]\
	  && [ "${_ppr_pkg_finished:+1}" != 1 ]\
	  && [ "${_ppr_pkg_rdepends_direct:+1}" != 1 ];
	then
		rtl_log_msg "info" "${MSG_pkgtool_pkg_deps_rev_none}" "${_ppr_pkg_name}";
	else
		for _ppr_pkg_name_rdepend in $(rtl_lsort	\
				${_ppr_pkg_finished}		\
				${_ppr_pkg_rdepends_direct});
		do
			rtl_lconcat \$_ppr_pkg_rdepends "${_ppr_pkg_name_rdepend}";

			if [ "${_ppr_full_rdependsfl}" -eq 1 ]; then
				rtl_get_var_unsafe \$_ppr_depends -u "PKG_"${_ppr_pkg_name}"_DEPENDS";
				if rtl_lunfold_depends 'PKG_${_rld_name}_DEPENDS' \$_ppr_pkg_depends ${_ppr_depends}\
				&& [ "${_ppr_pkg_depends:+1}" = 1 ]; then
					rtl_lconcat \$_ppr_pkg_rdepends "[33m${_ppr_pkg_depends}[93m";
				fi;
			fi;
		done;

		if [ "${_ppr_pkg_rdepends:+1}" = 1 ]; then
			rtl_log_msg "info" "${MSG_pkgtool_pkgs_deps_rev}" "${_ppr_pkg_name}" "${_ppr_pkg_rdepends}";
		fi;

		if [ "${_ppr_pkg_disabled:+1}" = 1 ]; then
			rtl_log_msg "info" "${MSG_pkgtool_pkgs_deps_rev_disabled}" "${_ppr_pkg_name}" "$(rtl_lsort "${_ppr_pkg_disabled}")";
		fi;
	fi;

	return "${_ppr_rc}";
};
# }}}
# {{{ pkgtoolp_tarball($_rstatus, $_pkg_name)
pkgtoolp_tarball() {
	local	_ppt_rstatus="${1}" _ppt_pkg_name="${2}"				\
		_ppt_date="" _ppt_group_name="" _ppt_groups="" _ppt_groups_noauto=""	\
		_ppt_hname="" _ppt_pkg_name_full="" _ppt_pkg_version="" _ppt_rc=0	\
		_ppt_tarball_fname="";

	if ! ex_pkg_load_groups \$_ppt_groups \$_ppt_groups_noauto \$GROUP_AUTO \$GROUP_TARGET; then
		_ppt_rc=1;
		rtl_setrstatus "${_ppt_rstatus}" 'Error: failed to load build groups.';
	elif ! ex_pkg_find_package \$_ppt_group_name "${_ppt_groups}" "${_ppt_pkg_name}"; then
		_ppt_rc=1;
		rtl_setrstatus "${_ppt_rstatus}" 'Error: unknown package \`'"${_ppt_pkg_name}'"'.';
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"	\
			"${_ppt_group_name}" 0 "${_ppt_pkg_name}" "" "${BUILD_WORKDIR}";
	then
		_ppt_rc=1;
		rtl_setrstatus "${_ppt_rstatus}" 'Error: failed to set package environment for \`'"${_ppt_pkg_name}'"'.';
	elif ! _ppt_date="$(date +%Y%m%d_%H%M%S)"; then
		_ppt_rc=1;
		rtl_setrstatus "${_ppt_rstatus}" 'Error: failed to call date(1).';
	elif ! _ppt_hname="$(hostname -f)"; then
		_ppt_rc=1;
		rtl_setrstatus "${_ppt_rstatus}" 'Error: failed to call hostname(1).';
	else
		if [ "${PKG_VERSION:+1}" = 1 ]; then
			_ppt_pkg_name_full="${_ppt_pkg_name}-${PKG_VERSION}";
		else
			_ppt_pkg_name_full="${_ppt_pkg_name}";
		fi;

		_ppt_tarball_fname="${_ppt_pkg_name_full}@${_ppt_hname}-${_ppt_date}.tbz2";
		rtl_log_msg "info" "${MSG_pkgtool_tarball_creating}" "${PKG_BASE_DIR}" "${_ppt_pkg_name}";

		if ! tar -C "${BUILD_WORKDIR}" -cpf -			\
				"${PKG_BASE_DIR#${BUILD_WORKDIR%/}/}"	\
				"${_ppt_pkg_name}_stderrout.log"	|\
					bzip2 -c -9 - > "${_ppt_tarball_fname}";
		then
			_ppt_rc=1;
			rtl_setrstatus "${_ppt_rstatus}" 'Error: failed to create compressed tarball of \`'"${PKG_BASE_DIR}'"' and \`'"${_ppt_pkg_name}"'_stderrout.log'"'"'.';
		else
			rtl_log_msg "info" "${MSG_pkgtool_tarball_created}" "${PKG_BASE_DIR}" "${_ppt_pkg_name}";
		fi;
	fi;

	return "${_ppt_rc}";
};
# }}}

pkgtool() {
	local	_rc=0 _status=""		\
		BUILD_GROUPS="" ARCH BUILD_KIND	\
		BUILD_WORKDIR PKGTOOL_PKGNAME PREFIX;

	if ! pkgtoolp_init \$_status "${@}"; then
		_rc=1;
		_status="Error: ${_status}";
	else
		case "1" in
		"${ARG_INFO:-0}")		pkgtoolp_info \$_status "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_MIRROR:-0}")		pkgtoolp_mirror \$_status "${ARG_MIRROR_DNAME}" "${ARG_MIRROR_DNAME_GIT}"; ;;
		"${ARG_RDEPENDS:-0}")		pkgtoolp_rdepends \$_status "${PKGTOOL_PKG_NAME}" 0; ;;
		"${ARG_RDEPENDS_FULL:-0}")	pkgtoolp_rdepends \$_status "${PKGTOOL_PKG_NAME}" 1; ;;
		"${ARG_TARBALL:-0}")		pkgtoolp_tarball \$_status "${PKGTOOL_PKG_NAME}"; ;;
		esac; _rc="${?}";
	fi;

	if [ "${_rc}" -ne 0 ]; then
		rtl_log_enable_tags "${LOG_TAGS_all}";
		rtl_log_msg "fatalexit" "0;${_status}";
	elif [ "${_status:+1}" = 1 ]; then
		rtl_log_enable_tags "${LOG_TAGS_all}";
		rtl_log_msg "info" "0;${_status}";
	fi;
};

set +o errexit -o noglob -o nounset; pkgtool "${@}";

# vim:filetype=sh textwidth=0

#!/bin/sh
# Copyright (c) 2020, 2021, 2022, 2023 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

# {{{ pkgtoolp_init($_rstatus)
pkgtoolp_init() {
	local	_pi_rstatus="${1#\$}"						\
		_pi_args_long=""						\
		_pi_name_base="pkgtool"						\
		_pi_optstring="a:b:efhim:M:p:rRtv"				\
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
	  || ! ex_init_theme						\
	  		"${_pi_rstatus}" "${BUILD_HNAME}"		\
			"${_pi_name_base}" "${ARG_THEME:-}"		\
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
	   + ${ARG_EDIT:-0}
	   + ${ARG_FILES:-0}
	   + ${ARG_MIRROR:-0}
	   + ${ARG_PROFILE:-0}
	   + ${ARG_RDEPENDS:-0}
	   + ${ARG_TARBALL:-0}))" -gt 1 ];
	then
		cat etc/pkgtool.usage;
		_ppia_rc=1;
		rtl_setrstatus "${_ppia_rstatus}" 'only one of -e, -f, -i, -m and/or -M, -p, -r, -s, or -t must be specified.';
	elif [ "$((${ARG_INFO:-0}
	     + ${ARG_EDIT:-0}
	   + ${ARG_FILES:-0}
	     + ${ARG_MIRROR:-0}
	     + ${ARG_PROFILE:-0}
	     + ${ARG_RDEPENDS:-0}
	     + ${ARG_TARBALL:-0}))" -eq 0 ];
	then
		cat etc/pkgtool.usage;
		_ppia_rc=1;
		rtl_setrstatus "${_ppia_rstatus}" 'one of -e, -f, -i, -m and/or -M, -p, -r, -s, or -t must be specified.';
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

		ARG_INFO=0; ARG_EDIT=0; ARG_MIRROR=0;
		ARG_RDEPENDS=0; ARG_TARBALL=0; ARG_VERBOSE=0;
		;;

	longopt)
		local	_ppigf_verb="${1}" _ppigf_rstatus="${2#\$}" _ppigf_opt="${3}";

		case "${_ppigf_opt}" in
		--theme)	shift 3;
				if [ "${#}" != 1 ]; then
					rtl_setrstatus "${_ppigf_rstatus}" 'missing argument to --theme option';
					return 1;
				else
					ARG_THEME="${1:-}"; _ppigf_shiftfl=2;
				fi;
				;;

		*)		_ppigf_shiftfl=0; ;;
		esac;
		;;

	opt)
		local	_ppigf_verb="${1}" _ppigf_rstatus="${2#\$}"	\
			_ppigf_opt="${3}" _ppigf_optarg="${4:-}";
		shift 4;

		case "${_ppigf_opt}" in
		a)	ARCH="${OPTARG}"; _ppigf_shiftfl=2; ;;
		b)	BUILD_KIND="${OPTARG}"; _ppigf_shiftfl=2; ;;
		h)	cat etc/pkgtool.usage; exit 0; ;;
		e)	ARG_EDIT=1; _ppigf_shiftfl=1; ;;
		f)	ARG_FILES=1; _ppigf_shiftfl=1; ;;
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
		p)	ARG_PROFILE=1;
			if [ "${OPTARG:+1}" = 1 ]; then
				ARG_PROFILE_LOG_FNAME="${OPTARG}";
			else
				rtl_setrstatus "${_ppigf_rstatus}" 'missing -p argument.';
			fi;
			_ppigf_shiftfl=2; ;;
		r)	ARG_RDEPENDS=1; _ppigf_shiftfl=1; ;;
		t)	ARG_TARBALL=1; _ppigf_shiftfl=1; ;;
		v)	ARG_VERBOSE=1; _ppigf_shiftfl=1; ;;
		*)	cat etc/pkgtool.usage; exit 1; ;;
		esac;
		;;

	nonopt)
		local _ppigf_verb="${1}" _ppigf_rstatus="${2#\$}";
		shift 2;

		case "${1}" in
		*=*)	rtl_set_var_from_spec "${_ppigf_rstatus}" "${1}";
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
		&& [ "${ARG_MIRROR:-0}" -eq 0 ]\
		&& [ "${ARG_PROFILE:-0}" -eq 0 ]; then
			_ppigf_rc=1;
			rtl_setrstatus "${_ppigf_rstatus}" 'missing package name.';
		else
			export PKGTOOL_PKG_NAME;
			case "${ARG_VERBOSE:-0}" in

			0)	rtl_log_enable_tagsV "${LOG_TAGS_normal}"; ;;
			1)	rtl_log_enable_tagsV "${LOG_TAGS_verbose}"; ;;
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

# {{{ pkgtoolp_edit($_rstatus, $_pkg_name)
pkgtoolp_edit() {
	local	_ppe_rstatus="${1}" _ppe_pkg_name="${2}"					\
		_ppe_fname="" _ppe_group_fname="" _ppe_group_fname_nline="" _ppe_group_name=""	\
		_ppe_patch_idx=0 _ppe_pkg_disabled="" _ppe_pkg_finished="" _ppe_pkg_name_uc=""	\
		_ppe_pkg_names="" _ppe_pkg_vars="" _ppe_rc=0;
	rtl_toupper2 \$_ppe_pkg_name \$_ppe_pkg_name_uc;

	if ! ex_pkg_load_groups \$_ppe_groups \$_ppe_groups_noauto; then
		_ppi_rc=1;
		rtl_setrstatus "${_ppi_rstatus}" 'Error: failed to load build groups.';
	elif ! ex_pkg_find_package \$_ppe_group_name "${_ppe_groups}" "${_ppe_pkg_name}"; then
		_ppe_rc=1;
		rtl_setrstatus "${_ppe_rstatus}" 'Error: unknown package \`'"${_ppe_pkg_name}'"'.';
	elif ! ex_pkg_get_packages \$_ppe_pkg_names "${_ppe_group_name}"; then
		_ppe_rc=1;
		rtl_setrstatus "${_ppe_rstatus}" 'Error: failed to expand package list of build group \`'"${_ppe_group_name}'"'.';
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"\
			"${_ppe_group_name}" "${_ppe_pkg_name}" "" "${BUILD_WORKDIR}"; then
		_ppe_rc=1;
		rtl_setrstatus "${_ppe_rstatus}" 'Error: failed to set package environment for \`'"${_ppe_pkg_name}'"'.';
	else
		rtl_get_var_unsafe \$_ppe_group_fname -u "PKG_${_ppe_pkg_name}_GROUP_FNAME";

		case "${EDITOR}" in
		"")
			rtl_setrstatus "${_ppe_rstatus}" 'Error: \${EDITOR} unset.';
			;;

		nano)
			_ppe_group_fname_nline="$(						\
				grep -n "PKG_${_ppe_pkg_name_uc}_" "${_ppe_group_fname}"	|\
				awk -F: 'NR == 1 { print $1 }')";
			"${EDITOR}"							\
				${_ppe_group_fname_nline:+"+${_ppe_group_fname_nline}"}	\
				"${_ppe_group_fname}"
			_ppe_rc="${?}";
			;;

		vi|vim|nvi|nvim)
			"${EDITOR}" "${_ppe_group_fname}" "+/PKG_${_ppe_pkg_name_uc}_/";
			_ppe_rc="${?}";
			;;
		*)
			"${EDITOR}" "${_ppe_group_fname}";
			_ppe_rc="${?}";
			;;
		esac;
	fi;

	return "${_ppe_rc}";
};
# }}}
# {{{ pkgtoolp_files($_rstatus, $_pkg_name)
pkgtoolp_files() {
	local	_ppf_rstatus="${1}" _ppf_pkg_name="${2}"			\
		_ppf_destdir="" _ppf_group_name="" _ppf_groups=""		\
		_ppf_groups_noauto="" _ppf_pkg_name_uc="" _ppf_pkg_vars=""	\
		_ppf_rc=0;
	rtl_toupper2 \$_ppf_pkg_name \$_ppf_pkg_name_uc;

	if ! ex_pkg_load_groups \$_ppf_groups \$_ppf_groups_noauto; then
		_ppf_rc=1;
		rtl_setrstatus "${_ppf_rstatus}" 'Error: failed to load build groups.';
	elif ! ex_pkg_find_package \$_ppf_group_name "${_ppf_groups}" "${_ppf_pkg_name}"; then
		_ppf_rc=1;
		rtl_setrstatus "${_ppf_rstatus}" 'Error: unknown package \`'"${_ppf_pkg_name}'"'.';
	elif ! ex_pkg_get_packages \$_ppf_pkg_names "${_ppf_group_name}"; then
		_ppf_rc=1;
		rtl_setrstatus "${_ppf_rstatus}" 'Error: failed to expand package list of build group \`'"${_ppf_group_name}'"'.';
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"\
			"${_ppf_group_name}" "${_ppf_pkg_name}" "" "${BUILD_WORKDIR}"; then
		_ppf_rc=1;
		rtl_setrstatus "${_ppf_rstatus}" 'Error: failed to set package environment for \`'"${_ppf_pkg_name}'"'.';
	else
		ex_pkg_get_package_vars \$_ppf_pkg_vars "${DEFAULT_BUILD_VARS}" "${_ppf_pkg_name}";
		rtl_get_var_unsafe \$_ppf_destdir -u "PKG_DESTDIR";

		if [ "${_ppf_destdir:+1}" != 1 ]; then
			_ppf_rc=1;
			rtl_setrstatus "${_ppf_rstatus}" 'Error: empty or unset \$PKG_DESTDIR.';
		else
			printf "%s/:\n" "${_ppf_destdir%/}";
			(cd "${_ppf_destdir}" && find . -ls);
			_ppf_rc="${?}";
		fi;
	fi;

	return "${_ppf_rc}";
};
# }}}
# {{{ pkgtoolp_info($_rstatus, $_pkg_name)
pkgtoolp_info() {
	local	_ppi_rstatus="${1}" _ppi_pkg_name_list="${2}"	\
		_ppi_groups="" _ppi_groups_noauto=""		\
		_ppi_pkg_name="" _ppi_rc=0 _ppi_rc_single=0	\
		_ppi_status="";
	rtl_llift \$_ppi_pkg_name_list "," " ";

	if ! ex_pkg_load_groups \$_ppi_groups \$_ppi_groups_noauto; then
		_ppi_rc=1;
		rtl_setrstatus "${_ppi_rstatus}" 'Error: failed to load build groups.';
	else
		for _ppi_pkg_name in ${_ppi_pkg_name_list}; do
			pkgtoolp_info_single				\
				"${_ppi_rstatus}" "${_ppi_pkg_name}"	\
				"${_ppi_groups}" "${_ppi_groups_noauto}";
			_ppi_rc_single="${?}";
			if [ "${_ppi_rc_single}" -ne 0 ]; then
				_ppi_rc="${_ppi_rc_single}";
				eval _ppi_status="\${${_ppi_rstatus#\$}}";
				rtl_log_msgV "fatal" "0;${_ppi_status}";
			fi;
		done;
	fi;

	if [ "${_ppi_rc}" -ne 0 ]; then
		rtl_setrstatus "${_ppi_rstatus}" 'Failure in one or more package(s).';
	fi;
	return "${_ppi_rc}";
};
# }}}
# {{{ pkgtoolp_info_single($_rstatus, $_pkg_name)
pkgtoolp_info_single() {
	local	_ppis_rstatus="${1}" _ppis_pkg_name="${2}" _ppis_groups="${3}" _ppis_groups_noauto="${4}"	\
		_ppis_fname="" _ppis_group_fname="" _ppis_group_name="" _ppis_patch_idx=0 _ppis_pkg_disabled=""	\
		_ppis_pkg_finished="" _ppis_pkg_name_uc="" _ppis_pkg_names="" _ppis_pkg_vars="" _ppis_rc=0;
	rtl_toupper2 \$_ppis_pkg_name \$_ppis_pkg_name_uc;

	if ! ex_pkg_find_package \$_ppis_group_name "${_ppis_groups}" "${_ppis_pkg_name}"; then
		_ppis_rc=1;
		rtl_setrstatus "${_ppis_rstatus}" 'Error: unknown package \`'"${_ppis_pkg_name}'"'.';
	elif ! ex_pkg_get_packages \$_ppis_pkg_names "${_ppis_group_name}"; then
		_ppis_rc=1;
		rtl_setrstatus "${_ppis_rstatus}" 'Error: failed to expand package list of build group \`'"${_ppis_group_name}'"'.';
	elif ! ex_pkg_env "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"\
			"${_ppis_group_name}" "${_ppis_pkg_name}" "" "${BUILD_WORKDIR}"; then
		_ppis_rc=1;
		rtl_setrstatus "${_ppis_rstatus}" 'Error: failed to set package environment for \`'"${_ppis_pkg_name}'"'.';
	else
		rtl_get_var_unsafe \$_ppis_group_fname -u "PKG_${_ppis_pkg_name}_GROUP_FNAME";
		rtl_get_var_unsafe \$_ppis_pkg_version -u "PKG_${_ppis_pkg_name}_VERSION";
		ex_pkg_get_package_vars \$_ppis_pkg_vars "${DEFAULT_BUILD_VARS}" "${_ppis_pkg_name}";
		rtl_log_env_vars "package_vars" "Package variables" ${_ppis_pkg_vars};
		rtl_log_msgV "info_build_group" "${MSG_info_build_group}" "${_ppis_group_name}" "${_ppis_group_fname}";

		if [ "${PKG_DISABLED:-0}" -eq 1 ]; then
			rtl_log_msgV "info_pkg_disabled" "${MSG_info_pkg_disabled}" "${_ppis_pkg_name}";
		fi;

		if [ "${PKG_DEPENDS:+1}" != 1 ]; then
			rtl_log_msgV "info_pkg_no_deps" "${MSG_info_pkg_no_deps}" "${_ppis_pkg_name}";
		else
			rtl_log_msgV "info_pkg_direct_deps" "${MSG_info_pkg_direct_deps}" "${_ppis_pkg_name}" "${PKG_DEPENDS}";
			if ! ex_pkg_unfold_depends					\
					\$_ppis_pkg_disabled \$_ppis_pkg_finished		\
					\$_ppis_pkg_names 1 1 "${_ppis_group_name}"	\
					"${_ppis_pkg_names}" "${_ppis_pkg_name}" 0	\
					"${BUILD_WORKDIR}";
			then
				rtl_log_msgV "warning" "${MSG_info_pkg_deps_fail}" "${_ppis_pkg_name}";
			else
				rtl_lfilter \$_ppis_pkg_names "${_ppis_pkg_name}";

				if [ "${_ppis_pkg_names:+1}" = 1 ]; then
					rtl_log_msgV "info_pkg_deps_full" "${MSG_info_pkg_deps_full}"\
							"${_ppis_pkg_name}" "$(rtl_lsortV "${_ppis_pkg_names}")";
				fi;

				if [ "${_ppis_pkg_disabled:+1}" = 1 ]; then
					rtl_log_msgV "info_pkg_deps_full_disabled" "${MSG_info_pkg_deps_full_disabled}"\
							"${_ppis_pkg_name}" "$(rtl_lsortV "${_ppis_pkg_disabled}")";
				fi;
			fi;
		fi;

		_ppis_patch_idx=1;
		while ex_pkg_get_default			\
			\$_ppis_fname "${_ppis_patch_idx}"	\
		       	"${_ppis_pkg_name}"			\
			"${_ppis_pkg_version}"			\
			"vars_files patches_pre patches"	\
		   && [ "${_ppis_fname:+1}" = 1 ];
		do
			: $((_ppis_patch_idx += 1));
			if [ -e "${_ppis_fname}" ]; then
				sha256sum "${_ppis_fname}";
			fi;
		done;
	fi;

	return "${_ppis_rc}";
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

	if ! ex_pkg_load_groups \$_ppm_groups \$_ppm_groups_noauto; then
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
		rtl_log_msgV "verbose" "${MSG_mirror_pkg_disabled}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}";
	else
		if rtl_get_var_unsafe \$_ppmf_pkg_url -u "PKG_${_ppmf_pkg_name_real}_URL"\
		&& rtl_get_var_unsafe \$_ppmf_pkg_sha256sum -u "PKG_${_ppmf_pkg_name_real}_SHA256SUM"\
		&& [ "${_ppmf_pkg_url:+1}" = 1 ]\
		&& [ "${_ppmf_pkg_sha256sum:+1}" = 1 ];
		then

			if [ "${_ppmf_mirror_dname:+1}" != 1 ]; then
				_ppmf_rc=0; rtl_log_msgV "verbose" "${MSG_mirror_pkg_skip_archive_mirror}" "${_ppmf_pkg_name}";

			elif [ "${_ppmf_pkg_name}" != "${_ppmf_pkg_name_real}" ]; then
				rtl_log_msgV "mirror_pkg_archive_mirroring_parent" "${MSG_mirror_pkg_archive_mirroring_parent}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}" "${_ppmf_pkg_url}";
				if ! rtl_fileop ln_symbolic "${_ppmf_pkg_name_real}" "${_ppmf_mirror_dname}/${_ppmf_pkg_name}"; then
					_ppmf_rc=1; rtl_log_msgV "warning" "${MSG_mirror_pkg_link_fail}"\
							"${_ppmf_mirror_dname}/${_ppmf_pkg_name}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}";
				fi;

			else
				if rtl_get_var_unsafe \$_ppmf_pkg_fname -u "PKG_${_ppmf_pkg_name_real}_FNAME"\
				&& [ "${_ppmf_pkg_fname:+1}" != 1 ]; then
					_ppmf_pkg_fname="${_ppmf_pkg_url##*/}";
				fi;
				rtl_log_msgV "mirror_pkg_archive_mirroring" "${MSG_mirror_pkg_archive_mirroring}" "${_ppmf_pkg_name}" "${_ppmf_pkg_url}";

				if ! rtl_fileop mkdir "${_ppmf_mirror_dname}/${_ppmf_pkg_name}"\
				|| ! rtl_fetch_url_wget						\
						"${_ppmf_pkg_url}"				\
						"${_ppmf_pkg_sha256sum}"			\
						"${_ppmf_mirror_dname}/${_ppmf_pkg_name}"	\
						"${_ppmf_pkg_fname}" "${_ppmf_pkg_name_real}"	\
						"";
				then
					_ppmf_rc=1;
					rtl_log_msgV "warning" "${MSG_mirror_pkg_mirror_fail}" "${_ppmf_pkg_name}";
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
				_ppmf_rc=0; rtl_log_msgV "verbose" "${MSG_mirror_pkg_skip_git_mirror}" "${_ppmf_pkg_name}";

			elif rtl_get_var_unsafe \$_ppmf_pkg_mirrors_git -u "PKG_${_ppmf_pkg_name_real}_MIRRORS_GIT"\
			&&   [ "${_ppmf_pkg_mirrors_git}" = "skip" ]; then
				_ppmf_rc=0; rtl_log_msgV "verbose" "${MSG_mirror_pkg_skip_git_mirror_disabled}" "${_ppmf_pkg_name}";

			elif [ "${_ppmf_pkg_name}" != "${_ppmf_pkg_name_real}" ]; then
				rtl_log_msgV "mirror_pkg_git_mirroring_parent" "${MSG_mirror_pkg_git_mirroring_parent}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}" "${_ppmf_pkg_urls_git}";
				if ! rtl_fileop ln_symbolic "${_ppmf_pkg_name_real}" "${_ppmf_mirror_dname_git}/${_ppmf_pkg_name}"; then
					_ppmf_rc=1;
					rtl_log_msgV "warning" "${MSG_mirror_pkg_link_fail}"	\
						"${_ppmf_mirror_dname_git}/${_ppmf_pkg_name}" "${_ppmf_pkg_name}" "${_ppmf_pkg_name_real}";
					rtl_lconcat "${_ppmf_rpkgs_failed}" "${_ppmf_pkg_name}";
				fi;

			else
				rtl_log_msgV "mirror_pkg_git_mirroring" "${MSG_mirror_pkg_git_mirroring}" "${_ppmf_pkg_name}" "${_ppmf_pkg_urls_git}";
				if ! rtl_fileop mkdir "${_ppmf_mirror_dname_git}/${_ppmf_pkg_name}"\
				|| ! rtl_fetch_mirror_urls_git "${DEFAULT_GIT_ARGS}" "${_ppmf_mirror_dname_git}/${_ppmf_pkg_name}" ${_ppmf_pkg_urls_git}; then
					_ppmf_rc=1;
					rtl_log_msgV "warning" "${MSG_mirror_pkg_mirror_fail}" "${_ppmf_pkg_name}";
					rtl_lconcat "${_ppmf_rpkgs_failed}" "${_ppmf_pkg_name}";
				else
					rtl_fetch_clean_dlcache "${_ppmf_mirror_dname_git}" "${_ppmf_pkg_name}" "${_ppmf_pkg_fname}" "${_ppmf_pkg_urls_git}";
				fi;
			fi;

		fi;

		if [ "${_ppmf_pkg_url:+1}" != 1 ]\
		&& [ "${_ppmf_pkg_sha256sum:+1}" != 1 ]\
		&& [ "${_ppmf_pkg_urls_git:+1}" != 1 ]; then
			_ppmf_rc=0; rtl_log_msgV "verbose" "${MSG_mirror_pkg_skip_no_urls}" "${_ppmf_pkg_name}";
		fi;
	fi;

	return "${_ppmf_rc}";
};
# }}}
# {{{ pkgtoolp_profile($_rstatus)
pkgtoolp_profile() {
	local	_ppp_rstatus="${1}" _ppp_log_fname="${2}"		\
		_ppp_line=""						\
		_ppp_ts=0 _ppp_ts_delta=0 _ppp_ts_last=0 _ppp_ts_max=0	\
		_ppp_pkg_name="" _ppp_pkg_step_max="" _ppp_rc=0		\
		IFS0="${IFS}" IFS;

	_ppp_log_fname="profile.log";

	for _ppp_pkg_name in $(find		\
			"${BUILD_WORKDIR}"	\
			-maxdepth 1		\
			-mindepth 1		\
			-name ".*.start"	\
			-printf "%P\n");
	do
		_ppp_pkg_name="${_ppp_pkg_name%.start}";
		_ppp_pkg_name="${_ppp_pkg_name##.}";
		_ppp_ts_last=0; _ppp_ts_max=0; _ppp_pkg_step_max="";

		rtl_set_IFS_nl;
		for _ppp_line in $(				\
			find					\
				"${BUILD_WORKDIR}"		\
				-maxdepth 1			\
				-mindepth 1			\
				-name ".${_ppp_pkg_name}.*"	\
				-printf "%T@ %P\n" |		\
			sort -nk1);
		do
			IFS=" "; set -- ${_ppp_line}; rtl_set_IFS_nl;
			_ppp_ts="${1}"; _ppp_pkg_step="${2}";
			_ppp_ts="${_ppp_ts%%.*}";
			if [ "${_ppp_ts_last}" -eq 0 ]; then
				_ppp_ts_last="${_ppp_ts}";
			fi;

			_ppp_ts_delta="$((${_ppp_ts}-${_ppp_ts_last}))";
			_ppp_ts_last="${_ppp_ts}";

			if [ "${_ppp_ts_delta}" -gt "${_ppp_ts_max}" ]; then
				_ppp_ts_max="${_ppp_ts_delta}";
				_ppp_pkg_step_max="${_ppp_pkg_step#.${_ppp_pkg_name}.}";
			fi;
		done;
		printf	"%20s %5u %s\n"		\
			"${_ppp_pkg_step_max}"	\
			"${_ppp_ts_max}"	\
			"${_ppp_pkg_name}";
	done | sort -nk2 >"${_ppp_log_fname}";
	IFS="${IFS0}";

	printf	"%5u items written to \`%s'; tail -n25 follows:\n"	\
		"$(wc -l < "${_ppp_log_fname}")"			\
		"${_ppp_log_fname}";
	tail -n15 "${_ppp_log_fname}";

	printf "\n";
	printf "By build step:\n";
	for _ppp_step in ${DEFAULT_BUILD_STEPS}; do
		printf "%20s %d\n"	\
			"${_ppp_step}"	\
			"$(grep " ${_ppp_step} " "${_ppp_log_fname}" | wc -l)";
	done | grep -v " [01]$" | sort -nk2;

	return "${_ppp_rc}";
};
# }}}
# {{{ pkgtoolp_rdepends($_rstatus, $_pkg_name)
pkgtoolp_rdepends() {
	local	_ppr_rstatus="${1}" _ppr_pkg_name="${2}"				\
		_ppr_depends="" _ppr_group_name="" _ppr_groups="" _ppr_groups_noauto=""	\
		_ppr_pkg_depends="" _ppr_pkg_disabled="" _ppr_pkg_finished=""		\
		_ppr_pkg_name_rdepend="" _ppr_pkg_names="" _ppr_pkg_rdepends=""		\
		_ppr_pkg_rdepends_direct="" _ppr_rc=0;

	if ! ex_pkg_load_groups \$_ppr_groups \$_ppr_groups_noauto; then
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
			"${_ppr_pkg_name}" 1 "${BUILD_WORKDIR}"		\
			"norecurse";
	then
		_ppr_rc=1;
		rtl_setrstatus "${_ppr_rstatus}" 'Error: failed to unfold reverse dependency-expanded package name list for \`'"${_ppr_pkg_name}'"'.';
	elif [ "${_ppr_pkg_disabled:+1}" != 1 ]\
	  && [ "${_ppr_pkg_finished:+1}" != 1 ]\
	  && [ "${_ppr_pkg_rdepends_direct:+1}" != 1 ];
	then
		rtl_log_msgV "info" "${MSG_rdepends_pkg_deps_rev_none}" "${_ppr_pkg_name}";
	else
		for _ppr_pkg_name_rdepend in $(rtl_lsortV	\
				${_ppr_pkg_finished}		\
				${_ppr_pkg_rdepends_direct});
		do
			if rtl_get_var_unsafe \$_ppr_depends -u "PKG_"${_ppr_pkg_name_rdepend}"_DEPENDS"\
			&& [ "${_ppr_depends:+1}" = 1 ]; then
				if rtl_lunfold_dependsV 'PKG_${_rld_name}_DEPENDS' \$_ppr_pkg_depends ${_ppr_depends}\
				&& rtl_lfilter \$_ppr_pkg_depends "${_ppr_pkg_name}"\
				&& [ "${_ppr_pkg_depends:+1}" = 1 ]; then
					rtl_lconcat \$_ppr_pkg_rdepends "[33m$(rtl_uniq "$(rtl_lsortV ${_ppr_pkg_depends})")[93m";
				fi;
			fi;
			rtl_lconcat \$_ppr_pkg_rdepends "${_ppr_pkg_name_rdepend}";
		done;

		if [ "${_ppr_pkg_rdepends:+1}" = 1 ]; then
			rtl_log_msgV "info" "${MSG_rdepends_pkgs_deps_rev_recurse}" "${_ppr_pkg_name}" "${_ppr_pkg_rdepends}";
		fi;

		if [ "${_ppr_pkg_disabled:+1}" = 1 ]; then
			rtl_log_msgV "info" "${MSG_rdepends_pkgs_deps_rev_disabled}" "${_ppr_pkg_name}" "$(rtl_lsortV "${_ppr_pkg_disabled}")";
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

	if ! ex_pkg_load_groups \$_ppt_groups \$_ppt_groups_noauto; then
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
		rtl_log_msgV "info" "${MSG_tarball_creating}" "${PKG_BASE_DIR}" "${_ppt_pkg_name}";

		if ! tar -C "${BUILD_WORKDIR}" -cpf -			\
				"${PKG_BASE_DIR#${BUILD_WORKDIR%/}/}"	\
				"${_ppt_pkg_name}_stderrout.log"	|\
					bzip2 -c -9 - > "${_ppt_tarball_fname}";
		then
			_ppt_rc=1;
			rtl_setrstatus "${_ppt_rstatus}" 'Error: failed to create compressed tarball of \`'"${PKG_BASE_DIR}'"' and \`'"${_ppt_pkg_name}"'_stderrout.log'"'"'.';
		else
			rtl_log_msgV "info" "${MSG_tarball_created}" "${PKG_BASE_DIR}" "${_ppt_pkg_name}";
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
		"${ARG_EDIT:-0}")		pkgtoolp_edit \$_status "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_FILES:-0}")		pkgtoolp_files \$_status "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_INFO:-0}")		pkgtoolp_info \$_status "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_MIRROR:-0}")		pkgtoolp_mirror \$_status "${ARG_MIRROR_DNAME}" "${ARG_MIRROR_DNAME_GIT}"; ;;
		"${ARG_PROFILE:-0}")		pkgtoolp_profile \$_status "${ARG_PROFILE_LOG_FNAME}"; ;;
		"${ARG_RDEPENDS:-0}")		pkgtoolp_rdepends \$_status "${PKGTOOL_PKG_NAME}"; ;;
		"${ARG_TARBALL:-0}")		pkgtoolp_tarball \$_status "${PKGTOOL_PKG_NAME}"; ;;
		esac; _rc="${?}";
	fi;

	if [ "${_rc}" -ne 0 ]; then
		rtl_log_enable_tagsV "${LOG_TAGS_all}";
		rtl_log_msgV "fatalexit" "0;${_status}";
	elif [ "${_status:+1}" = 1 ]; then
		rtl_log_enable_tagsV "${LOG_TAGS_all}";
		rtl_log_msgV "info" "0;${_status}";
	fi;
};

set +o errexit -o noglob -o nounset; pkgtool "${@}";

# vim:filetype=sh textwidth=0

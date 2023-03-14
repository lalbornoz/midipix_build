#!/bin/sh
# Copyright (c) 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

# {{{ buildp_ast($_param)
buildp_ast() {
	local	_bpa_param="${1}"				\
		_bpa_cmd="" _bpa_pids="" _bpa_pids_new=""	\
		_bpa_pids_niter=0 _bpa_pkg_name="";

	for _bpa_cmd in	\
			rtl_fileop rtl_kill_tree rtl_lconcat	\
			rtl_log_msg rtl_uniq rtl_state_clear;
	do
		if ! command -v "${_bpa_cmd}" >/dev/null 2>&1; then
			return 0;
		fi;
	done;

	trap '' HUP INT TERM USR1 USR2;

	if [ "${_bpa_param}" = "abort" ]; then
		rtl_log_msg "fatalexit" "${MSG_build_aborted}";
	fi;

	while [ "${_bpa_pids_niter}" -lt 8 ]; do
		rtl_lconcat \$_bpa_pids "${_bpa_pids_new}";
		_bpa_pids_new="";
		if ! rtl_kill_tree \$_bpa_pids_new "${$}" "TERM"\
		|| [ "${_bpa_pids_new:+1}" != 1 ]; then
			break;
		else
			: $((_bpa_pids_niter+=1));
		fi;
	done;

	if [ "${_bpa_pids:+1}" = 1 ]; then
		rtl_log_msg "verbose" "${MSG_build_killed_pids}" "$(rtl_uniq ${_bpa_pids})";
	fi;

	if [ "${BUILD_PKG_WAIT:+1}" = 1 ]\
	&& [ "${ARG_RESET_PKG}" -eq 1 ]; then
		for _bpa_pkg_name in ${BUILD_PKG_WAIT}; do
			rtl_state_clear "${BUILD_WORKDIR}" "${_bpa_pkg_name}";
		done;
		rtl_log_msg "verbose" "${MSG_build_reset_pkg_state}" "${BUILD_PKG_WAIT}";
	fi;

	if [ "${DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME:+1}" = 1 ]; then
		rtl_fileop rm "${DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME}";
	fi;

	return 0;
};
# }}}

# {{{ buildp_init($_rstatus)
buildp_init() {
	local	_bi_rstatus="${1#\$}"						\
		_bi_args_long="--as-needed --debug-minipx --reset-state"	\
		_bi_name_base="build"						\
		_bi_optstring="a:b:C:D:F:hp:Pr:RxvV:"				\
		_bi_rc=0 _bi_status="";
	shift;

	if ! . "${0%/*}/subr.ex/ex_init.subr"; then
		_bi_rc=1;
		_bi_status='failed to source \`'"${0%/*}/subr/ex_init.subr"\';
		eval ${_bi_rstatus}=\"${_bi_status}\";
	elif ! ex_init_help								\
			"${_bi_rstatus}" "${_bi_args_long}"				\
			"${_bi_name_base}" "${_bi_optstring}" "${@}"			\
	  || ! ex_init_env "${_bi_rstatus}"						\
	  		\$BUILD_HNAME \$BUILD_USER "${_bi_name_base}"			\
	  || ! ex_init_getopts								\
	  		"${_bi_rstatus}" "buildp_init_getopts_fn"			\
			"${_bi_optstring}" "${@}"					\
	  || ! ex_init_logging "${_bi_rstatus}" \$ARG_VERBOSE_TAGS "${ARG_VERBOSE}"	\
	  || ! ex_pkg_load_vars "${_bi_rstatus}" \$ARCH \$BUILD_KIND			\
	  || ! ex_init_prereqs "${_bi_rstatus}" "${DEFAULT_PREREQS}"			\
	  || ! buildp_init_args "${_bi_rstatus}"					\
	  || ! ex_init_files								\
			"${_bi_rstatus}"						\
			\$ARG_CLEAN_BUILDS \$ARG_DIST					\
			"${DEFAULT_BUILD_LOG_FNAME}"					\
			"${DEFAULT_BUILD_LOG_LAST_FNAME}"				\
			"${DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME}"			\
			"${DEFAULT_CHECK_PATH_VARS}"					\
			"${DEFAULT_CLEAR_ENV_VARS_EXCEPT}"				\
			"${DEFAULT_CLEAR_PREFIX_PATHS}"					\
			"${BUILD_DLCACHEDIR}" "${PREFIX}"				\
			"${PREFIX_RPM}" "${BUILD_WORKDIR}";
	then
		_bi_rc=1;
	fi;
	return "${_bi_rc}";
};
# }}}
# {{{ buildp_init_args($_rstatus)
buildp_init_args() {
	local	_bpia_rstatus="${1#\$}"								\
		_bpia_foundfl=0 _bpia_group="" _bpia_groups="" _bpia_groups_noauto=""		\
		_bpia_pkg_names="" _bpia_pkg_names_unknown="" _bpia_pkg_names_unknown_count=0	\
		_bpia_rc=0;

	case "${ARG_FETCH_FORCE}" in
	ipv4)	rtl_lconcat \$DEFAULT_GIT_ARGS "-4";
		rtl_lconcat \$DEFAULT_WGET_ARGS "-4"; ;;
	ipv6)	rtl_lconcat \$DEFAULT_GIT_ARGS "-6";
		rtl_lconcat \$DEFAULT_WGET_ARGS "-6"; ;;
	esac;

	if [ "${ARG_AS_NEEDED:-0}" -eq 1 ]\
	&&   [ -e "${PREFIX}/build.gitref" ]\
	&&   [ "$(git rev-parse HEAD)" = "$(cat "${PREFIX}/build.gitref")" ]; then
		_bpia_rc=0;
		rtl_setrstatus "${_bpia_rstatus}" 'Git repository has not changed since last build and --as-needed was specified.';
	elif ! ex_pkg_process_restart_spec "${_bpia_rstatus}" \$ARG_RESTART \$ARG_RESTART_AT \$ARG_RESTART_RECURSIVE; then
		_bpia_rc=1;
		rtl_setrstatus "${_bpia_rstatus}" 'failed to process -r specification: ${'"${_bpia_rstatus}"'}.';
	elif ! ex_pkg_load_groups \$_bpia_groups \$_bpia_groups_noauto \$GROUP_AUTO \$GROUP_TARGET; then
		_bpia_rc=1;
		rtl_setrstatus "${_bpia_rstatus}" 'failed to load build groups.';
	else
		if ! rtl_lmatch \$ARG_DIST:- "rpm" ","; then
			rtl_lfilter \$_bpia_groups "host_deps_rpm";
		fi;

		if [ "${BUILD_GROUPS:+1}" != 1 ]; then
			BUILD_GROUPS="${_bpia_groups}";
		else	_bpia_foundfl=0; for _bpia_group in ${BUILD_GROUPS}; do
				if rtl_lmatch \$_bpia_groups "${_bpia_group}"; then
					_bpia_foundfl=1; break;
				fi;
			done;
			if [ "${_bpia_foundfl}" -eq 0 ]; then
				_bpia_foundfl=0; for _bpia_group in ${BUILD_GROUPS}; do
					if rtl_lmatch \$_bpia_groups "${_bpia_group}"; then
						_bpia_rc=1;
						rtl_setrstatus "${_bpia_rstatus}" 'unknown build group \`'"${_bpia_group}'"'.';
					fi;
				done;
			fi;
		fi;

		if [ "${_bpia_rc:-0}" -eq 0 ]; then
			if   rtl_lmatch \$ARG_DIST "zipdist" ","\
			&& ! rtl_lmatch \$ARG_DIST "minipix" ","; then
				rtl_lconcat \$ARG_DIST "minipix" ",";
			fi;

			if [ "${ARG_DIST:+1}" = 1 ]; then
				rtl_lfilter \$BUILD_GROUPS "dist";
				rtl_lconcat \$BUILD_GROUPS "dist";
			fi;

			if [ "${ARG_RESTART:+1}" = 1 ]\
			&& ! rtl_lmatch \$ARG_RESTART "ALL LAST"; then
				for _bpia_pkg_name in ${ARG_RESTART}; do
					if ! ex_pkg_find_package \$_bpia_pkg_names "${BUILD_GROUPS}" "${_bpia_pkg_name}" >/dev/null; then
						rtl_lconcat \$_bpia_pkg_names_unknown "${_bpia_pkg_name}";
					fi;
				done;
				rtl_llength \$_bpia_pkg_names_unknown_count \$_bpia_pkg_names_unknown;

				case "${_bpia_pkg_names_unknown_count}" in
				0)	;;

				1)	_bpia_rc=1;
					rtl_setrstatus "${_bpia_rstatus}" 'unknown package \`'"${_bpia_pkg_names_unknown}'"'.';
					;;

				*)	rtl_subst \$_bpia_pkg_names_unknown " " ", ";
					_bpia_rc=1
					rtl_setrstatus "${_bpia_rstatus}" 'unknown packages: '"${_bpia_pkg_names_unknown}'"'.';
					;;
				esac;
			fi;
		fi;
	fi;

	return "${_bpia_rc}";
};
# }}}
# {{{ buildp_init_getopts_fn(...)
buildp_init_getopts_fn() {
	local _bpigf_rc=0 _bpigf_shiftfl=0;

	case "${1}" in
	init)
		local	_bpigf_verb="${1}" _bpigf_rstatus="${2#\$}";

		: ${ARCH:="nt64"};
		: ${BUILD_KIND:="debug"};

		ARG_AS_NEEDED=0; ARG_CLEAN_BUILDS=""; ARG_DEBUG_MINIPIX=0; ARG_DIST="";
		ARG_FETCH_FORCE=""; ARG_PARALLEL=1; ARG_RELAXED=0; ARG_RESET_PKG=0;
		ARG_RESTART=""; ARG_RESTART_AT=""; ARG_RESTART_RECURSIVE=""; ARG_VERBOSE=0;
		ARG_VERBOSE_TAGS="";
		;;

	longopt)
		local	_bpigf_verb="${1}" _bpigf_rstatus="${2#\$}" _bpigf_opt="${3}";

		case "${_bpigf_opt}" in
		--as-needed)	ARG_AS_NEEDED=1; _bpigf_shiftfl=1; ;;
		--debug-minipx)	ARG_DEBUG_MINIPIX=1; _bpigf_shiftfl=1; ;;
		--help)		_bpigf_shiftfl=1; ;;
		--reset-state)	ARG_RESET_PKG=1; _bpigf_shiftfl=1; ;;

		# {{{ --roar
		--roar)		printf "%s\n" '
[40m[37m              [40m[34m▃▃▃▃[0m
[40m[37m           [40m[34m▟[44m[94m        [40m[34m▙[0m
[40m[35m▟▙▃▟▙      [44m[34m [44m[33m/\[34m[34m    [34m[33m/\[34m[34m [40m[37m    [40m[97mroar![0m
[40m[35m▜[40m[95m▒▓▒[40m[35m▛      [104m[94m  [103m[94m▛ [103m[33m""" [103m[94m▜[104m[34m [40m[37m   [40m[97m/[0m
[40m[37m [40m[35m▜[45m[35m [40m[35m▛       [104m[94m [103m[30m  ^ _ ^ [104m[94m [40m[37m  [40m[97m/[0m
[40m[37m  [40m[35m▀        [46m[36m [103m[33m (__[103m[30my[103m[33m_)[103m[30m [46m[36m [0m
[40m[37m [40m[93m▟▙    ▁▂▃▟[103m[36m▐[40m[36m▙[40m[93m▜[103m[33m`\_/[40m[93m▛[40m[36m▟▌[0m
[40m[37m [40m[93m▟▙   ▟[103m[30m    [103m[36m▓▓▓[103m[30m| |[40m[93m▍[40m[36m▓▓▓[0m
[40m[37m [40m[93m▜[103m[30m\[40m[93m▙ ▟[103m[30m    [103m[36m▓▓▓▓▓[103m[30m |[40m[36m▓▓▓▓▓[0m
[40m[37m  [40m[93m▜[103m[30m\\    \ [103m[36m▒▒▒[103m[30m|[103m[33m [103m[30m|[40m[37m [40m[36m▒▒▒[0m
[40m[37m   [40m[93m▜[103m[30m\     ) [103m[36m▒[103m[30m_|[103m[33m [103m[30m|[40m[93m▙ [40m[36m▒[0m
[40m[37m   [103m[30m([4m     /  ))))))[0m';
				exit 0;
				;;
		# }}}

		*)		_bpigf_shiftfl=0; ;;
		esac;
		;;

	opt)
		local	_bpigf_verb="${1}" _bpigf_rstatus="${2#\$}"	\
			_bpigf_opt="${3}" _bpigf_optarg="${4:-}";
		shift 4;

		case "${_bpigf_opt}" in
		a)	ARCH="${_bpigf_optarg}"; _bpigf_shiftfl=2; ;;
		b)	BUILD_KIND="${_bpigf_optarg}"; _bpigf_shiftfl=2; ;;
		C)	ARG_CLEAN_BUILDS="${_bpigf_optarg}"; _bpigf_shiftfl=2; ;;
		D)	ARG_DIST="${_bpigf_optarg}"; _bpigf_shiftfl=2; ;;
		F)	ARG_FETCH_FORCE="${_bpigf_optarg}"; _bpigf_shiftfl=2; ;;
		h)	_bpigf_shiftfl=1; ;;
		p)	ARG_PARALLEL="${_bpigf_optarg}"; _bpigf_shiftfl=2; ;;

		P)	ARG_PARALLEL="auto";
			if [ "${2:+1}" = 1 ]\
			&& rtl_isnumber "${2}"; then
				_bpigf_rc=1;
				rtl_setrstatus "${_bpigf_rstatus}" 'maximum parallelisation job count is set with the \`-p jobs'\'' option.';
				break;
			fi;
			_bpigf_shiftfl=1;
			;;

		r)	ARG_RESTART="${_bpigf_optarg}"; _bpigf_shiftfl=2; ;;
		R)	ARG_RELAXED=1; _bpigf_shiftfl=1; ;;

		x)	ARG_VERBOSE_TAGS="${ARG_VERBOSE_TAGS:+${ARG_VERBOSE_TAGS},}xtrace";
			_bpigf_shiftfl=1; ;;

		v)	ARG_VERBOSE=1; _bpigf_shiftfl=1; ;;
		V)	ARG_VERBOSE_TAGS="${_bpigf_optarg}"; _bpigf_shiftfl=2; ;;
		*)	cat etc/build.usage.short; exit 1; ;;
		esac;
		;;

	nonopt)
		local	_bpigf_verb="${1}" _bpigf_rstatus="${2#\$}"	\
			_bpigf_vname="" _bpigf_vval="";
		shift 2;

		if rtl_match "${1}" "=*"; then
			BUILD_GROUPS_INHIBIT_DEPS=1; _bpigf_arg="${1#=}";
		else
			_bpigf_arg="${1}";
		fi;

		case "${_bpigf_arg}" in
		*=*)		rtl_set_var_from_cmdline "${_bpigf_rstatus}" "${_bpigf_arg}";
				_bpigf_rc="${?}";
				;;

		[!a-zA-Z]*)	_bpigf_rc=1;
				rtl_setrstatus "${_bpigf_rstatus}" 'build group names must start with [a-zA-Z] (in argument \`'"${_bpigf_arg}"''\''.)';
				;;

		*[!_bpigf_a-zA-Z]*)
				_bpigf_rc=1;
				rtl_setrstatus "${_bpigf_rstatus}" 'build group names must not contain [!_a-zA-Z] (in argument \`'"${_bpigf_arg}"''\''.)';
				;;

		*)		rtl_lconcat \$BUILD_GROUPS "${_bpigf_arg}"; ;;
		esac;

		if [ "${_bpigf_rc}" -ne 0 ]; then
			return "${_bpigf_rc}";
		else
			_bpigf_shiftfl=1;
		fi;
		;;

	done)
		local _bpigf_verb="${1}" _bpigf_rstatus="${2#\$}";

		case "${ARG_PARALLEL}" in
		auto)	if ! rtl_get_cpu_count "${_bpigf_rstatus}" \$ARG_PARALLEL; then
				_bpigf_rc=1;
			else
				ARG_PARALLEL=$((${ARG_PARALLEL}/2));
			fi; ;;

		max)	if ! rtl_get_cpu_count "${_bpigf_rstatus}" \$ARG_PARALLEL; then
				_bpigf_rc=1;

			fi; ;;

		"")	ARG_PARALLEL=1; ;;

		*)	if ! rtl_isnumber "${ARG_PARALLEL}"; then
				_bpigf_rc=1;
				rtl_setrstatus "${_bpigf_rstatus}" 'invalid jobs count \`'"${ARG_PARALLEL}"''\''.';
			fi; ;;
		esac;

		if [ "${_bpigf_rc}" -eq 0 ]; then
			DEFAULT_BUILD_CPUS="${ARG_PARALLEL}";
		else
			return "${_bpigf_rc}";
		fi;
		;;

	*)
		return 1;
		;;
	esac;

	if [ "${_bpigf_shiftfl}" -ge 1 ]; then
		return "$((${_bpigf_shiftfl} + 1))";
	else
		return 0;
	fi;

	return "${_bpigf_rc}";
};
# }}}

# {{{ buildp_dispatch($_msg)
buildp_dispatch() {
	local _bpd_msg="${1}"; shift;

	case "${_bpd_msg}" in
	disabled_pkg|finish_pkg|missing_pkg|msg_pkg|skipped_pkg|start_pkg|start_pkg_child|step_pkg)
		buildp_dispatch_pkg_state "${_bpd_msg}" "${@}"; ;;

	finish_group|start_group)
		buildp_dispatch_group_state "${_bpd_msg}" "${@}"; ;;

	*)	if command -v "buildp_dispatch_${_bpd_msg}" >/dev/null 2>&1; then
			"buildp_dispatch_${_bpd_msg}" "${@}";
		fi; ;;
	esac;

	return 0;
};
# }}}
# {{{ buildp_dispatch_fail_pkg($_group_name, $_pkg_name)
buildp_dispatch_fail_pkg() {
	local _bpdfp_group_name="${1}" _bpdfp_pkg_name="${2}";

	: $((BUILD_NFAIL+=1))
       	rtl_lconcat \$BUILD_PKGS_FAILED "${_bpdfp_pkg_name}";

	if [ "${ARG_RELAXED:-0}" -eq 0 ]; then
		rtl_log_msg "fatal" "${MSG_pkg_stderrout_log}" "${BUILD_WORKDIR}" "${_bpdfp_pkg_name}";
		cat "${BUILD_WORKDIR}/${_bpdfp_pkg_name}_stderrout.log";

		if [ "${DEFAULT_BUILD_LAST_FAILED_PKG_FNAME:+1}" = 1 ]; then
			printf "%s\n" "${_bpdfp_pkg_name}" > "${DEFAULT_BUILD_LAST_FAILED_PKG_FNAME}";
		fi;

		rtl_log_msg "fatal" "${MSG_build_failed_in}" "${_bpdfp_pkg_name}" "${BUILD_WORKDIR}/${_bpdfp_pkg_name}_stderrout.log";
	else
		rtl_log_msg "warning" "${MSG_build_failed_in}" "${_bpdfp_pkg_name}" "${BUILD_WORKDIR}/${_bpdfp_pkg_name}_stderrout.log";
	fi;

	return 0;
};
# }}}
# {{{ buildp_dispatch_group_state($_msg, $_group_name)
buildp_dispatch_group_state() {
	local _bpdgs_msg="${1}" _bpdgs_group_name="${2}";

	case "${_bpdgs_msg}" in
	finish_group)	rtl_log_msg "group_finish" "${MSG_group_finish}" "${6}" "${4}" "${5}" "${_bpdgs_group_name}"; ;;
	start_group)	rtl_log_msg "group_begin" "${MSG_group_begin}" "${6}" "${4}" "${5}" "${_bpdgs_group_name}"; ;;
	esac;

	return 0;
};
# }}}
# {{{ buildp_dispatch_pkg_state($_msg, $_group_name, $_pkg_name)
buildp_dispatch_pkg_state() {
	local	_bpdps_msg="${1}" _bpdps_group_name="${2}" _bpdps_pkg_name="${3}"	\
		_bpdps_var="" _bpdps_vars="";

	case "${_bpdps_msg}" in
	disabled_pkg)	: $((BUILD_NSKIP+=1)); rtl_log_msg "pkg_skip" "${MSG_pkg_skip_disabled}" "${_bpdps_pkg_name}"; ;;
	missing_pkg)	rtl_log_msg "fatalexit" "${MSG_pkg_skip_unknown}" "${_bpdps_pkg_name}"; ;;
	msg_pkg)	shift 3; rtl_log_msg "${MSG_pkg_msg}" "${_bpdps_group_name}" "${_bpdps_pkg_name}" "${*}"; ;;
	skipped_pkg)	: $((BUILD_NSKIP+=1)); rtl_log_msg "pkg_skip" "${MSG_pkg_skip_finished}" "${_bpdps_pkg_name}"; ;;
	start_pkg)	rtl_log_msg "pkg_begin" "${MSG_pkg_begin}" "${7}" "${6}" "${4}" "${5}" "${_bpdps_pkg_name}"; ;;
	step_pkg)	rtl_log_msg "pkg_step" "${MSG_pkg_step}" "${4}" "${_bpdps_pkg_name}"; ;;

	finish_pkg)
		: $((BUILD_NFINI+=1));
		if rtl_lmatch \$ARG_VERBOSE_TAGS "build" ","; then
			cat "${BUILD_WORKDIR}/${_bpdps_pkg_name}_stderrout.log";
		fi;
		rtl_log_msg "pkg_finish" "${MSG_pkg_finish}" "${7}" "${6}" "${4}" "${5}" "${_bpdps_pkg_name}"; ;;

	start_pkg_child)
		if [ "${PKG_NO_LOG_VARS:-0}" -eq 0 ]; then
			for _bpdps_var in ${DEFAULT_BUILD_VARS}; do
				if eval [ \"\${PKG_${_bpdps_var}:+1}\" = 1 ]; then
					_bpdps_vars="${_bpdps_vars:+${_bpdps_vars} }PKG_${_bpdps_var}";
				fi;
			done;
			rtl_log_env_vars "info" "build" ${_bpdps_vars};
		fi;
		if rtl_lmatch \$ARG_VERBOSE_TAGS "xtrace" ","; then
			set -o xtrace;
		fi; ;;
	esac;

	return 0;
};
# }}}

# {{{ buildp_time_init()
buildp_time_init() {
	rtl_date \$BUILD_DATE_START "%Y-%m-%d-%H-%M-%S";
	rtl_date \$_build_time_secs "%s";
};
# }}}
# {{{ buildp_time_update()
buildp_time_update() {
	local _bptu_date;

	rtl_date \$_bptu_date "%s";
	: $((_build_time_secs=${_bptu_date}-${_build_time_secs}));
	: $((_build_time_hours=${_build_time_secs}/3600));
	: $((_build_time_minutes=(${_build_time_secs}%3600)/60));
	: $((_build_time_secs=(${_build_time_secs}%3600)%60));
};
# }}}

build() {
	local	_build_time_hours=0 _build_time_mins=0 _build_time_secs=0 _pkg_name="" _rc=0 _status=""			\
		BUILD_DATE_START="" BUILD_GROUPS="" BUILD_GROUPS_INHIBIT_DEPS=0 BUILD_HNAME BUILD_IS_PARENT=1		\
		BUILD_NFAIL=0 BUILD_NFINI=0 BUILD_NSKIP=0 BUILD_PKGS_FAILED="" BUILD_TARGET="" BUILD_USER=""		\
		DEFAULT_BUILD_CPUS=1 DEFAULT_BUILD_LAST_FAILED_PKG_FNAME="" DEFAULT_BUILD_LOG_FNAME=""			\
		DEFAULT_BUILD_STEPS="" DEFAULT_BUILD_VARS="" DEFAULT_CLEAR_PREFIX_PATHS="" DEFAULT_GIT_ARGS=""		\
		DEFAULT_GITROOT_HEAD="${DEFAULT_GITROOT_HEAD:-}" DEFAULT_LOG_ENV_VARS="" DEFAULT_MIRRORS=""		\
		DEFAULT_TARGET="" DEFAULT_WGET_ARGS="" MIDIPIX_BUILD_PWD="";

	BUILD_PKG_WAIT="";
	DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME="";

	trap "buildp_ast exit" EXIT; trap "buildp_ast abort" HUP INT TERM USR1 USR2;

	if ! buildp_init \$_status "${@}"; then
		_rc=0;
		_status="Error: ${_status}";
	else
		buildp_time_init;
		rtl_log_msg "build_begin" "${MSG_build_begin}" "${BUILD_USER}" "${BUILD_HNAME}" "${BUILD_DATE_START}";
		rtl_log_env_vars "build_vars" "build (global)" ${DEFAULT_LOG_ENV_VARS};

		ex_pkg_dispatch									\
			\$BUILD_PKG_WAIT "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"	\
			"${ARG_RELAXED}" buildp_dispatch "${BUILD_GROUPS}"			\
			"${BUILD_GROUPS_INHIBIT_DEPS}" "${ARG_PARALLEL}"			\
			"${BUILD_WORKDIR}/build.fifo" "${ARG_RESTART}" "${ARG_RESTART_AT}"	\
			"${ARG_RESTART_RECURSIVE}" "${BUILD_WORKDIR}";

		buildp_time_update;
		rtl_log_msg "build_finish" "${MSG_build_finish}" "${BUILD_NFINI:-0}" "${BUILD_NSKIP:-0}" "${BUILD_NFAIL:-0}";
		rtl_log_msg "build_finish_time" "${MSG_build_finish_time}" "${_build_time_hours:-0}" "${_build_time_minutes:-0}" "${_build_time_secs:-0}";

		if [ "${BUILD_PKGS_FAILED:+1}" = 1 ]; then
			_rc=1;
			_status="Build script failure(s) in: ${BUILD_PKGS_FAILED}.";
		fi;
	fi;

	if [ "${_rc}" -ne 0 ]; then
		rtl_log_enable_tags "${LOG_TAGS_all}";
		rtl_log_msg "fatalexit" "0;${_status}";
	elif [ "${_status:+1}" = 1 ]; then
		rtl_log_enable_tags "${LOG_TAGS_all}";
		rtl_log_msg "info" "0;${_status}";
	fi;
};

set +o errexit -o noglob -o nounset; build "${@}";

# vim:filetype=sh textwidth=0

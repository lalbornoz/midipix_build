#!/bin/sh
#
set -o errexit -o noglob;

glob() { set +o noglob; echo ${@}; set -o noglob; };
map() { local _ifs="${IFS}" _sep="${1}"; shift; IFS="${_sep}"; echo "${*}"; IFS="${_ifs}"; };
rc() { echo "${@}"; "${@}"; };

rotate_build() {
	local _build_dname="${1}" _hostname="${2}" _limit="${3}";
	local _dist_dates="";
	for _dist_fname in $(glob			\
			${_build_dname}/*.tar.xz	\
			${_build_dname}/*.tar.xz.asc); do
		if [ -e "${_dist_fname}" ]; then
			_dist_date="${_dist_fname#*@${_hostname}-}";
			_dist_date="${_dist_date%.tar.xz*}";
			_dist_date="${_dist_date%-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]}";
			_dist_dates="${_dist_dates:+${_dist_dates} }${_dist_date}";
		fi;
	done;
	if [ -n "${_dist_dates}" ]; then
		rotate_build_dates "${_build_dname}" "${_dist_dates}" "${_limit}";
	fi;
};

rotate_build_dates() {
	local _build_dname="${1}" _dist_dates="${2}" _limit="${3}";
	local _dist_dates_count _dist_dates_count_limit="" _dist_fname="" _nl="
";	_dist_dates="$(map "${_nl}" ${_dist_dates} | sort | uniq)";
	_dist_dates_count="$(echo "${_dist_dates}" | wc -l)";
	if [ "${_dist_dates_count}" -gt "${_limit}" ]; then
		_dist_dates_count_limit=$((${_dist_dates_count}-${_limit}));
		_dist_dates="$(echo "${_dist_dates}" |\
				sed -n "1,${_dist_dates_count_limit}p")";
		for _dist_date in ${_dist_dates}; do
			for _dist_fname in $(glob	\
					${_build_dname}/*-${_dist_date}-*.tar.xz*); do
				rc rm -f "${_dist_fname}";
			done;
		done;
	fi;
};

rotate_builds() {
	local _build_dnames="${1}" _limit="${2}";
	local _hostname="$(hostname)";
	for _build_dname in ${_build_dnames}; do
		rotate_build "${_build_dname}" "${_hostname}" "${_limit}";
	done;
};

rotate_builds "${1}" "${2:-3}";

# vim:filetype=sh noexpandtab sw=8 ts=8 

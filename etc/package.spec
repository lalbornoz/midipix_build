#REMOVEDBYSED#
#REMOVEDBYSED# Refer to subr.ex/ex_rtl_rpm.subr:ex_rtl_build_rpm() for the list of
#REMOVEDBYSED# %{}-enclosed variables substituted prior to running rpmbuild(1).
#REMOVEDBYSED#
Name:           %{pkg_name}
Version:        %{pkg_version_rpm}
Release:        1
Summary:        %{pkg_name} %{pkg_version_full}
License:        Unknown
Group:          Applications
Url:            %{pkg_url}

%description
%{pkg_name} %{pkg_version_full}

%prep
%build
%install
rm -rf "${RPM_BUILD_ROOT}"
mkdir -p "${RPM_BUILD_ROOT}"
cp -pPr "%{pkg_destdir}/." "${RPM_BUILD_ROOT}"

%post
%postun
%files

%changelog


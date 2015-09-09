class mariadb::repository {

# only centos supported at the moment
case $operatingsystem {
  centos: {
    yumrepo {
      "MariaDB":
      baseurl => $architecture ? {
        "i386"      => "http://yum.mariadb.org/10.0/centos6-x86",
        "x86_64"    => "http://yum.mariadb.org/10.0/centos7-amd64"
      },
      descr => "MariaDB",
      enabled => 1,
      gpgcheck => 1,
      gpgkey    => "https://yum.mariadb.org/RPM-GPG-KEY-MariaDB"
    }

    yumrepo {
      "MariaDB-MaxScale":
        baseurl => $architecture ? {
          "x86_64"    => "http://code.mariadb.com/mariadb-maxscale/latest/centos/7/"
        },
        descr => "MariaDB-MaxScale",
        enabled => 1,
        gpgcheck => 1,
        gpgkey    => "https://yum.mariadb.org/RPM-GPG-KEY-MariaDB"
      }

    }

  }

}

class mariadb::repository::maxscale {
# no 32bit builds are provided by mariadb, don't use this class on 32bit!

# only centos supported at the moment
case $operatingsystem {
  centos: {
    yumrepo {
      "MariaDB-MaxScale":
        baseurl => $architecture ? {
          "x86_64"    => "http://code.mariadb.com/mariadb-maxscale/latest/centos/7/x86_64/"
        },
        descr => "MariaDB-MaxScale",
        enabled => 1,
        gpgcheck => 0,
        gpgkey    => "https://yum.mariadb.org/RPM-GPG-KEY-MariaDB"
      }

    }

  }

}

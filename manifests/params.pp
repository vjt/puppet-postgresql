class postgresql::params {
  $version        = '9.1'
  $listen_address = 'localhost'
  $port           = '5432'
  $user           = 'postgres'
  $group          = 'postgres'

  case $::osfamily {
    debian: {
      $client_package = "postgresql-client-${version}"
      $server_package = "postgresql-${version}"

      $datadir = "/var/lib/postgresql/${version}/main"
      $confdir = "/etc/postgresql/${version}/main"
      $sockdir = "/var/run/postgresql"
      $pidfile = "/var/run/postgresql/${version}-main.pid"
      $initdb  = "/usr/lib/postgresql/${version}/bin/initdb"
    }

    suse: {
      $client_package = 'postgresql'
      $server_package = 'postgresql-server'

      $datadir = '/var/lib/pgsql/data'
      $confdir = $datadir
      $sockdir = "/tmp"
      $pidfile = false
      $initdb  = "/usr/bin/initdb"
    }

    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}

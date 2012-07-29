class postgresql::server (
  $version = $postgresql::params::version,
  $listen  = $postgresql::params::listen_address,
  $port    = $postgresql::params::port,
  $acls    = [],
) inherits postgresql::params {

  package { "postgresql-server-${version}":
    name   => $server_package,
    ensure => present,
    before => Datadir["postgresql-$version"],
  }

  datadir { "postgresql-${version}":
    ensure => present
  }

  service { "postgresql-$version":
    name      => 'postgresql',
    ensure    => running,
    require   => Config["postgresql-server-config-$version"],
    subscribe => Package["postgresql-server-$version"],
  }

  config {
    "postgresql-server-config-$version":
      name   => 'postgresql.conf',
      ensure => present;

    "postgresql-server-access-$version":
      name    => 'pg_hba.conf',
      ensure  => present,
  }

  define config($ensure, $name) {
    $confdir = $postgresql::server::confdir
    $datadir = $postgresql::server::datadir
    $sockdir = $postgresql::server::sockdir
    $pidfile = $postgresql::server::pidfile
    $listen  = $postgresql::server::listen
    $port    = $postgresql::server::port
    $acls    = $postgresql::server::acls

    file { $title:
      name    => "${confdir}/${name}",
      content => template("postgresql/${name}.erb"),
      ensure  => $ensure,
      owner   => $postgresql::server::user,
      group   => $postgresql::server::group,
      mode    => '0600',
      require => Datadir["postgresql-${postgresql::server::version}"],
      notify  => Service["postgresql-${postgresql::server::version}"],
    }
  }

  define datadir($ensure) {
    $path = $postgresql::server::datadir
    $init = $postgresql::server::initdb

    file { $path:
      ensure  => directory,
      owner   => $postgresql::server::user,
      group   => $postgresql::server::group,
      mode    => '0700',
      before  => Exec["postgresql-initdb-${postgresql::server::version}"],
    }

    exec { "postgresql-initdb-${postgresql::server::version}":
      user      => $postgresql::server::user,
      group     => $postgresql::server::group,
      creates   => "${path}/PG_VERSION",
      command   => "${init} --locale=en_US.UTF8 ${path}",
      logoutput => true,
    }
  }

}

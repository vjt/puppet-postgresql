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
    file { $title:
      name    => "${confdir}/${name}",
      content => template("postgresql/${name}.erb"),
      ensure  => $ensure,
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => Datadir["postgresql-$version"],
      notify  => Service["postgresql-$version"],
    }
  }

  define datadir($ensure) {
    file { $datadir:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0700',
      before  => Exec["postgresql-initdb-${version}"],
    }

    exec { "postgresql-initdb-${version}":
      user      => $user,
      group     => $group,
      creates   => "${datadir}/PG_VERSION",
      command   => "${initdb} --locale=en_US.UTF8 ${datadir}",
      logoutput => true,
    }
  }

}

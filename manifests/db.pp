define postgresql::db (
    $password,
    $ensure   = present,
    $owner    = $name,
    $encoding = 'UTF8',
    $locale   = 'en_US.UTF8',
) {

  case $ensure {
    present : {
      pg_user {$owner:
        ensure   => present,
        password => $password,
        require  => Service['postgresql'],
      }

      pg_database {$name:
        ensure    => present,
        owner     => $owner,
        require   => Pg_user[$owner],
        encoding  => $encoding,
        locale    => $locale,
      }
    }

    absent : {
      pg_user {$owner:
        ensure  => absent,
        require => Pg_database[$name],
      }
      pg_database {$name:
        ensure  => absent,
        require => Service['postgresql'],
      }
    }
  }
}

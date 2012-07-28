class postgresql::client (
  $version = $postgresql::params::version
) inherits postgresql::params {

  package { "postgresql-client-$version":
    name    => $client_package,
    ensure  => present,
  }
}

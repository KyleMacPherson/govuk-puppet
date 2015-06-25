# == Class: mongodb::server
#
# Setup a MongoDB server.
#
# === Parameters:
#
# [*version*]
# [*package_name*]
# [*dbpath*]
# [*oplog_size*]
#   Defines size of the oplog in megabytes.
#   If undefined, we use MongoDB's default.
#
# [*replicaset_members*]
#   An array of the members for the replica set.
#   Defaults to empty, which throws an error, so
#   it must be set.
#
# [*development*]
#   Disable journalling and endable query profiling.
#   Saves space at the expense of data integrity.
#   Default: false
#
class mongodb::server (
  $version,
  $package_name = 'mongodb-10gen',
  $dbpath = '/var/lib/mongodb',
  $oplog_size = undef,
  $replicaset_members = [],
  $development = false,
) {
  validate_bool($development)
  validate_array($replicaset_members)
  if empty($replicaset_members) {
    fail("Replica set can't have no members")
  }

  include mongodb::backup

  if $development {
    $replicaset_name = 'development'
  } else {
    $replicaset_name = 'production'
  }

  anchor { 'mongodb::begin':
    before => Class['mongodb::repository'],
    notify => Class['mongodb::service'];
  }

  class { 'mongodb::repository': }

  class { 'mongodb::package':
    version      => $version,
    package_name => $package_name,
    require      => Class['mongodb::repository'],
    notify       => Class['mongodb::service'];
  }

  class { 'mongodb::config':
    dbpath          => $dbpath,
    development     => $development,
    oplog_size      => $oplog_size,
    replicaset_name => $replicaset_name,
    require         => Class['mongodb::package'],
    notify          => Class['mongodb::service'];
  }

  class { 'mongodb::configure_replica_set':
    replicaset_name   => $replicaset_name,
    members           => $replicaset_members,
    require           => Class['mongodb::service'];
  }

  class { 'mongodb::logging':
    require => Class['mongodb::config'],
  }

  class { 'mongodb::firewall':
    require => Class['mongodb::config'],
  }

  class { 'mongodb::service':
    require => Class['mongodb::logging'],
  }

  class { 'mongodb::monitoring':
    dbpath  => $dbpath,
    require => Class['mongodb::service'],
  }

  class { 'collectd::plugin::mongodb':
    require => Class['mongodb::config'],
  }

  # We don't need to wait for the monitoring class
  anchor { 'mongodb::end':
    require => Class[
      'mongodb::firewall',
      'mongodb::service',
      'mongodb::configure_replica_set'
    ],
  }
}

# == Class: govuk_elasticsearch::housekeeping
#
#  Delete old snapshots from elasticsearch
#
# === Parameters:
#
# [*ensure*]
#   Whether the resources should exist.
#
# [*es_repo*]
#   The local elasticsearch repositories where snapshots are stored.
#   This could be either a single element or an array.
#
# [*es_snapshot_limit*]
#   The number of snapshots we want to keep.
#
class govuk_elasticsearch::housekeeping (
  $ensure = 'present',
  $es_repo = [],
  $es_snapshot_limit = 7,
  ) {

  if $es_repo == undef {
    fail('No Elasticsearch repositories were set')
  } else {
    # Validates a maximum and minimum string length
    validate_slength($es_repo, 120, 3)
    $repositories = join(regsubst($es_repo,'(.*)','"\1"'), ' ')
  }

  # This is a CLI JSON processor which allows us to "awk" the data on the fly
  package { 'jq':
    ensure => $ensure,
  }

  file { 'es-prune-snapshots':
    ensure  => $ensure,
    path    => '/usr/local/bin/es-prune-snapshots',
    content => template('govuk_elasticsearch/es-prune-snapshots.erb'),
    mode    => '0755',
  }

  cron::crondotdee { 'elasticsearch-remove-old-snapshots':
    ensure  => $ensure,
    command => '/usr/local/bin/es-prune-snapshots',
    hour    => 4,
    minute  => 0,
  }
}

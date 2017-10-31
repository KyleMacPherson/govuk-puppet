# == Class: govuk_elasticsearch::backup
#
# GOV.UK specific class to backup elasticsearch indexes.
#
# === Parameters
#
# [*ensure*]
#   Whether to create the resources.
#
# [*aws_access_key_id*]
#   AWS key to authenticate requests
#
# [*aws_secret_access_key*]
#   AWS key to authenticate requests
#
# [*aws_region*]
#   AWS region for the S3 bucket
#
# [*s3_bucket*]
#   Defines the AWS S3 bucket where the backups
#   will be uploaded. It should be created by the
#   user
#
# [*es_repos*]
#   The repositories within elasticsearch
#   where backups will be stored
#
# [*es_indices*]
#   Elaticsearch indexes
#
# [*cron_hour*]
#   The hour that the job should run
#
# [*cron_minute*]
#   The minute that the job should run
#
class govuk_elasticsearch::backup (
  $ensure = 'present',
  $aws_access_key_id = undef,
  $aws_secret_access_key = undef,
  $aws_region = 'eu-west-1',
  $s3_bucket = undef,
  $es_repo = undef,
  $es_indices = [],
  $cron_hour = 0,
  $cron_minute = 0,
  $alert_hostname = 'alert.cluster',
){

  $threshold_secs = 28 * 3600
  $service_desc = 'Elasticsearch-Index_Backup'
  $json_es_indices = join(regsubst($es_indices, '(.*)', '"\1"'), ',')

  if $s3_bucket {
    @@icinga::passive_check { "check_esindexbackup-${::hostname}":
      ensure              => $ensure,
      service_description => $service_desc,
      freshness_threshold => $threshold_secs,
      host_name           => $::fqdn,
      notes_url           => monitoring_docs_url(backup-passive-checks),
    }

    file { '/usr/local/bin/es-backup-s3':
      ensure  => $ensure,
      mode    => '0755',
      content => template('govuk_elasticsearch/es-backup-s3.erb'),
    }

    cron::crondotdee { 's3-elasticsearch-indexes':
      ensure  => $ensure,
      command => '/usr/local/bin/es-backup-s3',
      hour    => $cron_hour,
      minute  => $cron_minute,
    }

    file { '/usr/local/bin/es-restore-s3':
      ensure  => $ensure,
      mode    => '0755',
      content => template('govuk_elasticsearch/es-restore-s3.erb'),
    }

    class { 'govuk_elasticsearch::housekeeping':
      es_repo => $es_repo,
    }
  }
}

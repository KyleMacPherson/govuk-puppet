# == Class: govuk_jenkins::job::content_performance_manager
#
# Create a jenkins job to periodically run rake for the following tasks:
# - import:all_inventory
#
# === Parameters:
#
# [*rake_import_all_inventory_frequency *]
#   The cron timings for the import:all_inventory rake task
#   Default: undef
#
# [*rake_import_all_ga_metrics_frequency *]
#   The cron timings for the import:all_inventory rake task
#   Default: undef
#
class govuk_jenkins::job::content_performance_manager (
  $rake_import_all_inventory_frequency = undef,
  $rake_import_all_ga_metrics_frequency = undef,
) {
  file { '/etc/jenkins_jobs/jobs/content_performance_manager.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/content_performance_manager.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }
}

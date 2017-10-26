# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::apps::bouncer::postgresql_role (
  $password = '',
  $rds = undef,
  ){
  $bouncer_role = 'bouncer'
  $db           = 'transition_production'
  $hostname     = 'transition-postgresql-primary'

  # For RDS, we have to specify hostnames in psql queries.
  if $::aws_migration {
    $alter_default_privileges_bouncer_query = "psql -h ${hostname} -d ${db} -c 'ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ${bouncer_role}'"
    $bouncer_can_select_everything_query = "psql -h ${hostname} -d ${db} -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${bouncer_role}'"
    $test_privileges_are_set_for_one_table = "psql -h ${hostname} -d ${db} -c '\\dp' | grep -q 'bouncer=r/'"
  } else {
    $alter_default_privileges_query = "psql -d ${db} -c 'ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ${bouncer_role}'"
    $bouncer_can_select_everything_query = "psql -d ${db} -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${bouncer_role}'"
    $test_privileges_are_set_for_one_table = "psql -d ${db} -c '\\dp' | grep -q 'bouncer=r/'"
  }

  postgresql::server::role { $bouncer_role:
    password_hash => postgresql_password($bouncer_role, $password),
    rds           => $rds,
  }

  postgresql::server::database_grant { "${bouncer_role} can connect to ${db}":
    privilege => 'CONNECT',
    db        => $db,
    role      => $bouncer_role,
    require   => [Postgresql::Server::Role[$bouncer_role], Class['govuk::apps::transition::postgresql_db']],
  }

  exec { "${bouncer_role} will be able to SELECT from all yet-to-be-created tables in ${db}":
    command => $alter_default_privileges_query,
    unless  => $test_privileges_are_set_for_one_table,
    user    => 'postgres',
    require => Postgresql::Server::Database_grant["${bouncer_role} can connect to ${db}"],
  }

  # FIXME: We will be able to do this via the postgres puppet module from version 4.2.0:
  # https://github.com/puppetlabs/puppetlabs-postgresql/blob/master/CHANGELOG.md#2015-03-10---supported-release-420
  # https://github.com/puppetlabs/puppetlabs-postgresql/pull/405
  exec { "${bouncer_role} can SELECT from all existing tables in ${db}":
    command => $bouncer_can_select_everything_query,
    unless  => $test_privileges_are_set_for_one_table,
    user    => 'postgres',
    require => Exec["${bouncer_role} will be able to SELECT from all yet-to-be-created tables in ${db}"],
  }
}

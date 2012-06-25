class govuk::testing_tools {
  package { 'libqt4-dev':
    ensure  => installed,
    require => Apt::Ppa_Repository['kubuntu-backports'],
  }

  package { 'xvfb':
    ensure => installed;
  }

  package { 'phantomjs':
    ensure  => installed,
    require => Apt::Ppa_Repository['jerome-etienne'],
  }

  file { '/etc/init/xvfb.conf':
    ensure  => present,
    source  => 'puppet:///modules/govuk/xvfb.conf',
  }

  service { 'xvfb':
    ensure   => running,
    provider => upstart,
    require  => [
      Package['xvfb'],
      File['/etc/init/xvfb.conf'],
    ]
  }

  apt::ppa_repository { 'jerome-etienne':
    publisher => 'jerome-etienne',
    repo      => 'neoip'
  }

  apt::ppa_repository { 'kubuntu-backports':
    publisher => 'kubuntu-ppa',
    repo      => 'backports',
  }
}

# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class puppet::puppetserver::firewall {
  @ufw::allow { 'allow-puppetserver-from-all':
    port => 8140,
  }
}

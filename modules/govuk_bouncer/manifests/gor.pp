# == Class: govuk_bouncer::gor
#
# Setup gor traffic replay for the Bouncer application
#
# === Parameters
#
# [*enabled*]
#   Boolean to determine if Bouncer traffic will be replayed; defaults to false.
#
# [*ip_address*]
#   IP address of the Bouncer application to replay against; defaults to undef.
#
class govuk_bouncer::gor (
  $enabled = false,
  $ip_address = undef,
) {

  validate_bool($enabled)

  if $enabled and is_ip_address($ip_address) {
    $gor_enable         = true
    # Bouncer only receives traffic over HTTP (port 80)
    $gor_targets        = ["http://${ip_address}"]
  } else {
    $gor_enable         = false
    $gor_targets        = []
  }

  class { 'govuk_gor':
    args    => {
      '-input-raw'          => ':3049',
      '-output-http'        => $gor_targets,
      '-http-allow-method'  => [
        'GET', 'HEAD', 'OPTIONS',
      ],
      '-http-original-host' => '',
    },
    envvars => {
      'GODEBUG' => 'netdns=go',
    },
    enable  => $gor_enable,
  }
}

# Class: puppet_infra::profile::console
#
#
class puppet_infra::profile::console inherits puppet_infra::profile::global {
  $prune_upto                = hiera('puppet_infra::profile::console::prune_upto')
  $password_reset_expiration = hiera('puppet_infra::profile::console::password_reset_expiration')
  $session_timeout           = hiera('puppet_infra::profile::console::session_timeout')
  $failed_attempts_lockout   = hiera('puppet_infra::profile::console::failed_attempts_lockout')
  $timezone                  = hiera('puppet_infra::profile::console::timezone')
  $unresponsive_threshold    = hiera('puppet_infra::profile::console::unresponsive_threshold')
  $disable_live_management   = str2bool(hiera('puppet_infra::profile::console::disable_live_management'))

  validate_re($password_reset_expiration, '^\d+$')
  validate_re($session_timeout, '^\d+$')
  validate_re($failed_attempts_lockout, '^\d+$')
  validate_bool($disable_live_management)


  include puppet_enterprise::license
  include puppet_enterprise::profile::console
  include puppet_enterprise::profile::mcollective::console

  class { 'pe_console_prune':
    prune_upto => $prune_upto,
  }

  file { "/etc/puppetlabs/console-services/conf.d/custom-settings.conf":
    ensure  => file,
    content => template("${module_name}/console-settings.conf.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify => Service['pe-console-services'],
  }
  class { 'puppet_infra::console':
    timezone                => $timezone,
    unresponsive_threshold  => $unresponsive_threshold,
    disable_live_management => $disable_live_management,
    require => Class['puppet_enterprise::profile::console'],
  }
}

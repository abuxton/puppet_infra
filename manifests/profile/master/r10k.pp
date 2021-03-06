# Class: puppet_infra::profile::master::r10k
#
#
class puppet_infra::profile::master::r10k {
  $remote          = hiera('puppet_infra::profile::master::r10k::remote')
  $version         = hiera('puppet_infra::profile::master::r10k::version')
  $install_options = hiera('puppet_infra::profile::master::r10k::install_options', undef)
  $basemodulepath  = hiera('puppet_infra::profile::master::basemodulepath')
  $environmentpath = hiera('puppet_infra::profile::master::environmentpath')
  $webhook_enable  = str2bool(hiera('puppet_infra::profile::master::r10k::webhook_enable'))


  if $webhook_enable {
    $webhook_pass  = hiera('puppet_infra::profile::master::r10k::webhook_user')
    $webhook_user  = hiera('puppet_infra::profile::master::r10k::webhook_pass')

    validate_string($webhook_user)
    validate_string($webhook_pass)

    class {'puppet_infra::r10k::webhook':
      user => $webhook_user,
      pass => $webhook_pass,
    }
  }

  ##  This section requires the zack/R10k module
  class { '::r10k':
    version           => $version,
    sources           => {
      'puppet' => {
        'remote'  => $remote,
        'basedir' => $environmentpath,
        'prefix'  => false,
      }
    },
    purgedirs         => $environmentpath,
    manage_modulepath => false,
    install_options   => $install_options,
  }

  # Remove the default production folder so git/r10k does not complain
  # This will then be regenerated from the this repos production branch
  exec {'rm -rf production':
    creates => "${environmentpath}/production/Puppetfile",
    command => "rm -rf ${environmentpath}/production",
    require => Class['::r10k'],
    path    => $::path,
  }

  exec {'r10k deploy environment -p':
    creates => "${environmentpath}/production/Puppetfile",
    command => '/opt/puppet/bin/r10k deploy environment -p',
    require => Exec['rm -rf production'],
  }


}

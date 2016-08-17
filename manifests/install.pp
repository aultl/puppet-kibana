# install.pp - install the kibana software
class kibana::install inherits kibana {

  # Create group
  group { 'group_kibana' :
    ensure => present,
    name   => $kibana::params::group_name,
    gid    => $kibana::params::user_gid,
  }

  # Create user 
  user { 'user_kibana':
    name       => $kibana::params::user_name,
    comment    => $kibana::params::user_gcos,
    home       => $kibana::params::home_path,
    managehome => true,
    ensure     => present,
    shell      => '/bin/bash',
    uid        => $kibana::params::user_uid,
    gid        => $kibana::params::user_gid,
    membership => 'minimum',
  }

  # create service home 
  file { 'kibana_service_path' :
    ensure => directory,
    name   => $kibana::params::service_path,
    owner  => $kibana::params::user_name,
    group  => $kibana::params::group_name,
    mode   => '755',
  }

  # create cert path 
  file { 'kibana_cert_path' :
    ensure  => directory,
    name    => $kibana::params::cert_path,
    owner   => $kibana::params::user_name,
    group   => $kibana::params::group_name,
    mode    => '755',
    require => File['kibana_service_path'],
  }

  # create log path 
  file { 'kibana_log_path' :
    ensure  => directory,
    name    => $kibana::params::log_path,
    owner   => $kibana::params::user_name,
    group   => $kibana::params::group_name,
    mode    => '755',
    require => File['kibana_service_path'],
  }

  # do we enable ssl?
  if $listen_https {
    $ssl_key  = "${kibana::params::cert_path}/key.pem"
    $ssl_cert = "${kibana::params::cert_path}/cert.crt"

    # create key file 
    file { 'ssl_key_file' :
      ensure  => present,
      name    => "${kibana::params::cert_path}/key.pem",
      source  => "puppet:///modules/${module_name}/${client_key}",
      owner   => $kibana::params::user_name,
      group   => $kibana::params::group_name,
      mode    => '644',
      require => File['kibana_cert_path'],
    }

    # create cert file 
    file { 'ssl_cert_file' :
      ensure  => present,
      name    => "${kibana::params::cert_path}/cert.crt",
      source  => "puppet:///modules/${module_name}/${client_cert}",
      owner   => $kibana::params::user_name,
      group   => $kibana::params::group_name,
      mode    => '644',
      require => File['kibana_cert_path'],
    }
  }

  # create config file 
  file { 'kibana_conf' :
    ensure  => present,
    name    => "${kibana::params::service_path}/current/config/kibana.yml",
    content => template("${module_name}/kibana.yml.erb"),
    owner   => $kibana::params::user_name,
    group   => $kibana::params::group_name,
    mode    => '644',
    require => File['kibana_service_path'],
    notify  => Service['kibana'],
  }
  
  # Install kibana package
  package { 'jtv-kibana' :
    ensure  => present,
    require => [ User['user_kibana'], Repo['inhouse-apps'], File['kibana_service_path'] ]
  }

  # install an init script
  if $::osfamily == 'RedHat' {
    # Do RedHat/CentOS type stuff
    if $::operatingsystemreleasemajor == '6' {
      # Drop in a SySv Init Script
      file { 'kibana_init_el6':
        ensure => present,
        name   => "/etc/init.d/kibana",
        source => "puppet:///modules/${module_name}/kibana.sysv",
        owner  => 'root',
        group  => 'root',
        mode   => '755',
        notify => Exec['install_kibana_init'],
      }

      exec { 'install_kibana_init' :
        cwd         => $kibana::params::service_path,
        user        => 'root',
        command     => "/sbin/chkconfig --add kibana",
        refreshonly => true,
      }
    } else {
      # Drop in a Systemd Init Script
      file { 'kibana_init_el7':
        ensure => present,
        name   => "/etc/systemd/system/kibana.service",
        source => "puppet://${module_name}/kibana.service",
        owner  => 'root',
        group  => 'root',
      }
    }
  } elsif $::osfamily == 'Solaris' {
    # Do Solaris SMF type stuff
  } else {
    # Do nothing ?!?
    notice("Unable to create startup script for ${osfamily} on node: ${fqdn}!")
  }

}

# config.pp - configure system services
class kibana::config inherits kibana {
  # Configure sudo 
  sudo::user_rule { 'softeng_kibana' :
    user_list => '%softeng',
    runas     => $user_name,
    command   => 'ALL',
  }

  # can user remotely login?
  if ( $allow_login ) {
    access::entry { 'kibana' :
      user  => $kibana::params::user_name,
      login => true,
    }
  }

  # make sure we rotate the iptables log
  file { "/etc/logrotate.d/kibana" :
    ensure => present,
    source => "puppet:///modules/${module_name}/kibana.logrotate",
    owner  => 'root',
    group  => 'root',
    mode   => 640,
  }


  # Configure iptables
  if ($use_iptables == 'yes') {
    iptables::rule { 'kibana_request' :
      action   => 'accept',
      dport    => $http_port,
      chain    => 'RH-Firewall',
      protocol => 'tcp',
      state    => 'new',
    }
  }
}

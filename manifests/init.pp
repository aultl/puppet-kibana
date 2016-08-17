# init.pp - Entry point for the kibana module
class kibana (
  $allow_login  = false,
  $http_port    = '5601',
  $listen_https = false,
  $use_iptables = 'no',
  $client_cert  = '',
  $client_key   = '',
  $es_url,
) inherits kibana::params {

  anchor { 'kibana::begin': }
  -> class { '::kibana::install': }
  -> class { '::kibana::config': }
  ~> class { '::kibana::service': }
  -> anchor { 'kibana::end': }

}

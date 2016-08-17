# params.pp - Parameters for the kibana module
class kibana::params {
  $user_name    = 'kibana'
  $user_uid     = '522'
  $group_name   = 'kibana'
  $group_gid    = '522'
  $home_path    = "/export/home/${user_name}"
  $service_path = '/opt/kibana'
  $cert_path    = "${service_path}/certs"
  $log_path     = "${service_path}/logs"

}

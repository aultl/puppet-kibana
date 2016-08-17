# service.pp - Manages the kibana service
class kibana::service inherits kibana {
  service { 'kibana' :
    ensure    => running,
    enable    => true,
    subscribe => File['kibana_conf'],
  }  
}

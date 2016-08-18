# puppet-kibana

This puppet module was written to install, configure, and start and elastic search node or cluster

I have built a custom RPM for kibana, as such the module only uses the package provider

# usage

class { '::kibana'   :<br />
  es_url       => 'http://127.0.0.1:9200',<br/>
  use_iptables => 'yes',<br/>
}<br/>

It is recommended to have a elasticsearch server configured in 'client' more on the same server

elasticsearch::node { 'cluster_logs' :<br/>
  node_type     => 'client',<br/>
  cluster_name  => 'cluster_01',<br/>
  cluster_nodes => [ 'node1.example.tld', 'node2.example.tld', 'node3.example.tld' ],<br/>
}<br/>

The 'use_iptables' flag causes the module to call my puppet-iptables module and open the listen port specified. Default of 5601.

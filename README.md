# puppet-elasticsearch

This puppet module was written to install, configure, and start and elastic search node or cluster

I have built a custom RPM for kibana, as such the module only uses the package provider

# usage

class { '::kibana'   :
  es_url       => 'http://127.0.0.1:9200',
  use_iptables => 'yes',
}

elasticsearch::node { 'cluster_logs' :
  node_type     => 'client',
  cluster_name  => 'cluster_01',
  cluster_nodes => [ 'node1.example.tld', 'node2.example.tld', 'node3.example.tld' ],
}


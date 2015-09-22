# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/jayjanssen/packer-percona

# This sets up 3 nodes with a common PXC, but you need to run bootstrap.sh to connect them.

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

ps_version = "56"

# Node group counts and aws security groups (if using aws provider)
mha = {
  'mysql1' => {
    'local_vm_ip' => '192.168.170.2',
    'server_id' => 1,
  },
  'mysql2' => {
    'local_vm_ip' => '192.168.170.3',
    'server_id' => 2,
  },
  'mysql3' => {
    'local_vm_ip' => '192.168.170.4',
    'server_id' => 3,
  }
}


mha_nodes_arr = []
mha.each_pair{ |name, attrs| 
  mha_nodes_arr.push( name + ":" + attrs['local_vm_ip'] )
}
mha_nodes = mha_nodes_arr.join(',')


Vagrant.configure("2") do |config|
	config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"

  # Create all three nodes identically except for name and ip
  mha.each_pair { |name, node_params|
    config.vm.define name do |node_config|
      node_config.vm.hostname = name
      node_config.vm.network :private_network, ip: node_params['local_vm_ip']
      node_config.vm.provision :hostmanager

      # Provisioners
      provision_puppet( node_config, "percona_server.pp" ) { |puppet| 
        puppet.facter = {
          "percona_server_version"  => ps_version,
          'innodb_buffer_pool_size' => '128M',
          'innodb_log_file_size' => '64M',
          'innodb_flush_log_at_trx_commit' => '0',
          'server_id' => node_params['server_id'],
          'extra_mysqld_config' => "performance_schema=OFF
skip-name-resolve
read-only", 

           # Sysbench setup
          'sysbench_load' => (node_params['server_id'] == 1 ? true : false ),
          'tables' => 1,
          'rows' => 1000000,
          'threads' => 1,
          'tx_rate' => 10,

          # Vividcortex setup
          # 'vividcortex_api_key' => ENV['VIVIDCORTEX_API_KEY'],
           
           # MHA node
          'mha_node' => true,
        }
      }

      # Providers
      provider_virtualbox( name, node_config, 1024 ) { |vb, override|
        provision_puppet( override, "percona_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            'datadir_dev' => 'dm-2',
          }
        }
      }
      end
  }

  config.vm.define 'manager' do |node_config|
    node_config.vm.network :private_network, ip: "192.168.170.60"

    node_config.vm.provision :hostmanager

    # Provisioners
    provision_puppet( node_config, "base.pp" )
    provision_puppet( node_config, "percona_client.pp" ){ |puppet|  
      puppet.facter = {
        "percona_server_version"  => ps_version,
        'mha_manager' => true,
        'mha_nodes' => mha_nodes,
      }
    }
    provision_puppet( node_config, "sysbench.pp" )

    provider_virtualbox( 'manager', node_config, 256 )
  end

end


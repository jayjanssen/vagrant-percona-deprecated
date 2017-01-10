# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/grypyrg/packer-percona

# This sets up 3 consul server nodes and 1 consul client node

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

# Node names and ips (for local VMs)
# (Amazon) aws_region is where to bring up the node
# (Amazon) Security groups are 'default' (22 open) and 'pxc' (3306, 4567-4568, 4444 open) for each respective region
# Don't worry about amazon config if you are not using that provider.
consul = {
	'consul1' => {
		'local_vm_ip' => '192.168.70.2',
		'aws_region' => 'us-east-1',
		'server_id' => 1,
		'security_groups' => ['sg-c88d28ae', 'sg-126b9b6e']
	},
	'consul2' => {
		'local_vm_ip' => '192.168.70.3',
		'aws_region' => 'us-east-1',
		'server_id' => 2,
		'security_groups' => ['sg-c88d28ae', 'sg-126b9b6e']
	},
	'consul3' => {
		'local_vm_ip' => '192.168.70.4',
		'aws_region' => 'us-east-1',
		'server_id' => 3,
		'security_groups' => ['sg-c88d28ae', 'sg-126b9b6e']
	}
}
client = {
	'client1' => {
		'local_vm_ip' => '192.168.70.10',
		'aws_region' => 'us-east-1',
		'security_groups' => ['sg-c88d28ae', 'sg-be6c9cc2'],
		'type' => 'client'
	}
}

# Use 'public' for cross-region AWS. 'private' otherwise (or commented out)
aws_ips = 'private'
if_adapter='vboxnet1'

Vagrant.configure("2") do |config|
	config.vm.box = "grypyrg/centos-x86_64"
	config.vm.box_version = "~> 7"
	config.ssh.username = "vagrant"

	config.hostmanager.enabled = false # Disable this for AWS
	config.hostmanager.include_offline = true

	# Create all three nodes identically except for name and ip
	consul.each_pair { |name, node_params|
		config.vm.define name do |node_config|
			node_config.vm.hostname = name
			node_config.vm.network :private_network, ip: node_params['local_vm_ip'], adaptor: if_adapter
            node_config.vm.provision :hostmanager
			
			# Forward Consul UI port
			node_config.vm.network "forwarded_port", guest: 8500, host: 8500 + node_params['server_id'], protocol: 'tcp'
			
			# Provisioners
			provision_puppet( node_config, "base.pp" )
			provision_puppet( node_config, "consul_server.pp" ) { |puppet|
				puppet.facter = {
					'datacenter'		=> 'dc1',
					'bind_addr'			=> '0.0.0.0',
					'node_name'			=> name,
					'retry_join' 		=> consul.keys.join(','),
					'bootstrap_expect'	=> consul.length
				}
			}
			
			provider_virtualbox( nil, node_config, 256 ) { |vb, override|
				vb.linked_clone = true
				
				# Override the bind_addr on vbox to use the backend network
				provision_puppet( override, "consul_server.pp" ) { |puppet|
					puppet.facter = {
						'bind_addr' => node_params['local_vm_ip'],
						'default_interface' => 'eth1'
					}
				}
			}	 
			
			provider_aws( "consul #{name}", node_config, 'm3.medium', node_params['aws_region'], node_params['security_groups'], aws_ips)
			
		end
	}
	
	# Create clients
	client.each_pair { |name, node_params|
		config.vm.define name do |node_config|
			node_config.vm.hostname = name
			node_config.vm.network :private_network, ip: node_params['local_vm_ip'], adaptor: if_adapter
			node_config.vm.provision :hostmanager
			
			# Provisioners
			provision_puppet( node_config, "base.pp" )
			provision_puppet( node_config, "consul_client.pp" ) { |puppet|	
				puppet.facter = {
					'datacenter'		=> 'dc1',
					'bind_addr'			=> '0.0.0.0',
					'node_name'			=> name,
					'retry_join' 		=> consul.keys.join(',')
				}
			}
			
			provider_virtualbox( nil, node_config, 256 ) { |vb, override|
				vb.linked_clone = true
				
				# Override the bind_addr on vbox to use the backend network
				provision_puppet( override, "consul_client.pp" ) { |puppet|
					puppet.facter = {
						'bind_addr' => node_params['local_vm_ip'],
						'default_interface' => 'eth1'
					}
				}
			}	 
			
			provider_aws( "consul #{name}", node_config, 'm3.medium', node_params['aws_region'], node_params['security_groups'], aws_ips)
			
		end
	}
end

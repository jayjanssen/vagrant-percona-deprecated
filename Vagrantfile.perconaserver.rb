# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/grypyrg/packer-percona

# it also installs haproxy

# HOW TO USE
# You have to bring the machines up prior to provisioning. so run it in 2 steps:
#
# # vagrant up --no-provision --parallel
# # vagrant provision --parallel

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

mysql_version = "57"
name = "perconaserver"
aws_region = 'us-east-1'
security_groups = "default"

ip_address='192.168.8.70'
if_adapter='vboxnet14'

# should we use the public or private ips when using AWS
hostmanager_aws_ips='public'

Vagrant.configure("2") do |config|
	config.vm.box = "grypyrg/centos-x86_64"
	config.ssh.username = "vagrant"

	# it's disabled by default, it's done during the provision phase
	config.hostmanager.enabled = false
	config.hostmanager.include_offline = true

	# Create all three nodes identically except for name and ip
	config.vm.define name do |node_config|
		node_config.vm.hostname = name
		node_config.vm.network :private_network, ip: ip_address, adaptor: if_adapter

		# custom port forwarding
		node_config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
		node_config.vm.network "forwarded_port", guest: 3306, host: 3306, auto_correct: true

		# Provisioners
		node_config.vm.provision :hostmanager

		provision_puppet( node_config, "percona_server.pp" ) { |puppet|
			puppet.facter = {
				'cluster_servers'					=> name,
				'vagrant_hostname'					=> name,
				"percona_server_version"			=> mysql_version,
				"datadir_dev"						=> "dm-2",
				'innodb_buffer_pool_size'			=> '128M',
				'innodb_log_file_size'				=> '64M',
				'innodb_flush_log_at_trx_commit'	=> '0',
			}
		}

		# Providers
		provider_virtualbox( nil, node_config, 512) { |vb, override|
			provision_puppet( override, "percona_server.pp" ) { |puppet|
				puppet.facter = {"datadir_dev" => "dm-2"}
			}
		}

		provider_aws( "PXC #{name}", node_config, 'm3.medium', aws_region, security_groups, hostmanager_aws_ips) { |aws, override|
			aws.block_device_mapping = [
				{
					'DeviceName' => "/dev/sdb",
					'VirtualName' => "ephemeral0"
				}
			]
			provision_puppet( override, "percona_server.pp" ) { |puppet|
				puppet.facter = {"datadir_dev" => "xvdb"}
			}

		}
	end
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

mysql_version = "57"

name = "57-community"

Vagrant.configure("2") do |config|
	# Every Vagrant virtual environment requires a box to build off of.
	config.vm.hostname = name
	config.vm.box = "grypyrg/centos-x86_64"
	config.ssh.username = "vagrant"
  
  # Provisioners
  provision_puppet( config, "mysql_server.pp" ) { |puppet|  
    puppet.facter = {
      "enable_56" => 0,
      "enable_57" => 1,
    	"innodb_buffer_pool_size"	=> "128M",
    	"innodb_log_file_size"		=> "64M"
    }
  }
  
  # Providers
  provider_virtualbox( name, config, 1024 ) { |vb, override|
    # If we are using Virtualbox, override percona_server.pp with the right device for the datadir
    provision_puppet( override, "mysql_server.pp" ) {|puppet|
      puppet.facter = {"datadir_dev" => "dm-2"}
    }
  }
  
	provider_aws( name, config, 'm3.medium') { |aws, override|
    # For AWS, we want to map the proper device for this instance type
		aws.block_device_mapping = [
			{
				'DeviceName' => "/dev/sdb",
				'VirtualName' => "ephemeral0"
			}
		]
    # Also override the percona_server.pp manifest with the right datadir device
    provision_puppet( override, "mysql_server.pp" ) {|puppet|
      puppet.facter = {
  			'datadir_dev' => 'xvdb',
  			'innodb_buffer_pool_size' => '1G'
      }
    }
	}

  
end



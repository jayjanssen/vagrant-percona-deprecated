# -*- mode: ruby -*-
# vi: set ft=ruby :

# To create multiple slaves, read the instructions near the end
# of this file.

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

def build_box( config, name, ip, server_id )
  mysql_version = "57"

  config.vm.define name do |node_config|
    node_config.vm.hostname = name
    node_config.vm.network :private_network, ip: ip, adaptor: 1, auto_config: false
    node_config.vm.provision :hostmanager

    # Provisioners
    provision_puppet( node_config, "base.pp" )
    provision_puppet( node_config, "percona_server.pp" ) { |puppet|  
      puppet.facter = {
       'cluster_servers' => name,
      	"percona_server_version"	=> mysql_version,
      	"innodb_buffer_pool_size"	=> "128M",
      	"innodb_log_file_size"		=> "64M",
  	"server_id" 			=> server_id
      }
    }
    provision_puppet( node_config, "percona_client.pp" ) { |puppet|
      puppet.facter = {
      	"percona_server_version"	=> mysql_version
      }
    }
  
    # Providers
    provider_virtualbox( nil, node_config, 256 ) { |vb, override|
      vb.linked_clone = true
      provision_puppet( override, "percona_server.pp" ) {|puppet|
        puppet.facter = {
          "default_interface" => "eth1",
          "datadir_dev" => "dm-2"
        }
      }
    }

    provider_aws( name, node_config, 'm3.medium') { |aws, override|
      aws.block_device_mapping = [
        {
          'DeviceName' => "/dev/sdl",
          'VirtualName' => "mysql_data",
          'Ebs.VolumeSize' => 20,
          'Ebs.DeleteOnTermination' => true,
        }
      ]
      provision_puppet( override, "percona_server.pp" ) {|puppet|
        puppet.facter = {"datadir_dev" => "xvdl"}
      }
    }
  end

  if block_given?
    yield
  end
  
end


Vagrant.configure("2") do |config|
  config.vm.box = "grypyrg/centos-x86_64"
  config.ssh.username = "vagrant"

  build_box( config, 'master', '192.168.70.2', '1' )
  build_box( config, 'slave1', '192.168.70.3', '2' )

  # Uncomment the line below to build a 3rd slave. You can add more
  # lines like this one to have more nodes. Be sure to adjust the
  # parameters to prevent duplicates.
  #build_box( config, 'slave2', '192.168.70.4', '3' )
end

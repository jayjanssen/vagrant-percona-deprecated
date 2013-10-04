#!/usr/bin/perl

use Data::Dumper qw( Dumper );


print "Setup nodes with replication\n";

# setup all nodes in replication with the first node in `vagrant status` as the master.

my @running_nodes_lines = `vagrant status | grep running`;
my @running_nodes;
foreach my $line( @running_nodes_lines ) {
	if( $line =~ m/^(\w+)\s+\w+\s+\((\w+)\)$/ ) {
		push( @running_nodes, {
			name => $1,
			provider => $2
		});
	}
}

my @slaves = grep { $_->{name} ne 'manager' } @running_nodes;
my $master = shift @slaves;


# Harvest node ips
foreach my $node( @running_nodes ) {
	my $nic = 'eth1';
	$nic = 'eth0' if $node->{provider} eq 'aws';

	my $ip_str = `vagrant ssh $node->{name} -c "ip a l | grep $nic | grep inet"`;
	if( $ip_str =~ m/inet\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\// ) {
		$node->{ip} = $1;
	}
	my $hostname = `vagrant ssh $node->{name} -c "hostname -f"`; chop $hostname;
	$node->{hostname} = $hostname;
}

print "Master: " . $master->{name} . "\n";
print "Slaves: " . join( ', ', map( {$_->{name}} @slaves )) . "\n";
print "All nodes: " . join( ', ', map( {$_->{name}} @running_nodes )) . "\n";
print "===========================================================\n";


# Get Master binlog file and position
my $master_status =<<END;
mysql -e \\"show master status\\"
END
my @master_status_str = `vagrant ssh $master->{name} -c \"$master_status\"`;
my $master_log_file;
my $master_log_pos;
if( $master_status_str[$#master_status_str] =~ m/^(.+)\s+(\d+)/ ) {
	$master_log_file = $1;
	$master_log_pos = $2;
} else {
	die "Could not parse master log file and position!\n";
}

# Setup slave user:
print "Setting up 'repl' user on $master->{name}\n";
my $grant =<<END;
mysql -e \\"GRANT REPLICATION SLAVE ON *.* TO 'repl'\@'%' IDENTIFIED BY 'repl'\\"
END
system( "vagrant ssh $master->{name} -c \"$grant\"");

# Configure the slaves
print <<END;
Replication coordinates:
	master_host='$master->{ip}'
	master_log_file='$master_log_file'
	master_log_pos=$master_log_pos
END

my $change_master =<<END;
mysql -e \\"CHANGE MASTER TO master_host='$master->{ip}', master_log_file='$master_log_file', master_log_pos=$master_log_pos, master_user='repl', master_password='repl'; slave start;\\"
END
foreach my $slave( @slaves ) {
	next if( $slave->{name} eq 'manager' );
	print "Executing CHANGE MASTER on $slave->{name}\n";
	system( "vagrant ssh $slave->{name} -c \"$change_master\"");
}


print "Setting MHA grants on $master->{name}\n";
foreach my $node( @running_nodes ) {
	my $grant =<<END;
mysql -e \\"GRANT ALL ON *.* TO 'mha'\@'$node->{ip}' IDENTIFIED BY 'mha'\\"
END
	system( "vagrant ssh $master->{name} -c \"$grant\"");
}
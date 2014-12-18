#!/usr/bin/perl

## Rack Mapping
## Currently 
## Looks for rack_mapfile.txt in current directory.


use strict;
use warnings;
use Socket;

my $ipaddr;
my $rack = "/default-rack";
my @lines;

$ipaddr = $ARGV[0];

if( $ipaddr !~ m/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)
{	
### UH OH, not a valid IP, is hostname -- assume so and get IP
### This errors out if an invalid IP is sent -- BUG ALERT
my $address = inet_ntoa(inet_aton($ipaddr));
$ipaddr = $address;
}


open MAPFILE, "/etc/hadoop/conf/rack_mapfile.txt" or die "error on open: $!";
while(<MAPFILE>){
	if ($_ !~ "\#" && $_ !~ /^$/ ){
	@lines = split(' ' , $_);
		if ($lines[0] eq $ipaddr) {$rack = $lines[1];}
	}
}
close (MAPFILE);
print $rack, "\n";
exit 0;


#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

open (FILE, "/etc/oratab") || die "Cannot open your file";

our $ORACLE_HOME = "";
while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~ /\:(.*?)\:/;
	
	foreach (@sid)
	{
	 $ORACLE_HOME = pop @sid;

	}
}
close (FILE);


print "$ORACLE_HOME \n";



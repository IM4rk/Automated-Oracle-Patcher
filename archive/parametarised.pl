#!/usr/bin/perl
use warnings;
use Getopt::Long;


our $ORACLE_HOME="";

GetOptions("home=s" => \$ORACLE_HOME);

print "$ORACLE_HOME\r\n";

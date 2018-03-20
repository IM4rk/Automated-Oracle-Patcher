#!/usr/bin/perl
use strict;
use warnings;


our $ORACLE_HOME='/oracle/product/12.1.0/db1';
our $APO='/oracle/APO';


#Execute checker command

my $filename = '$APO/checker.log';
chomp ($filename);


open (FILE, "/etc/$filename") || die "Cannot open your file: $1";
while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~  /^(.*?):\//;

        foreach  (@sid)
        {

          my $cmd_setsid = "export ORACLE_SID=$_";
          my $cmdchecker  = "$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./ > $APO/checker.log ";


          print "Checking patch compatability \r\n";
          
          $ENV{ORACLE_SID}="$_";
          $ENV{ORACLE_HOME}="$ORACLE_HOME";
        
	  system($cmdchecker);
        }

}
close (FILE);


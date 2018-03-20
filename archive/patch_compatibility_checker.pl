#!/usr/bin/perl
use strict;
use warnings;


our $ORACLE_HOME='/oracle/product/12.1.0/db1';
our $APO='/oracle/APO';
our $shutdown_log='$ORACLE_HOME/shutdown.log';
our $SQLPatch='/oracle/cfgtoollogs/sqlpatch';
our $OPatch_logs=' /oracle/product/12.1.0/db1/cfgtoollogs/opatch';

my $filename = 'oratab';
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


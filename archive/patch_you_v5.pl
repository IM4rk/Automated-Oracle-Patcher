#!/usr/bin/perl
use strict;


#Directory Variables
my $ORACLE_HOME='/oracle/product/12.1.0/db1';
my $APO='/oracle/APO';
my $shutdown_log='$ORACLE_HOME/shutdown.log';
my $SQLPatch='/oracle/cfgtoollogs/sqlpatch';

#Unix Commands

my $cmd_startup = "$APO/startup.sh";
my $cmd_shutdown =  "$APO/shutdown.sh";
my $cmd_apply_patch = "$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $ORACLE_HOME/OPatch/apo.rsp";


#=======================================
#Postpatch                             #
#=======================================

print "Starting up Database\r\n";
`$cmd_startup`;
print "logging in: $ORACLE_HOME/startup.log\r\n";


print "Applying datapatch per database \r\n";
my $filename = 'oratab';
chomp ($filename);


open (FILE, "/etc/$filename") || die "Cannot open your file: $1";

while (my $line = <FILE> ){
        chomp $line;
        my @sid = $line =~  /^(.*?):\//;

        foreach  (@sid)
        {
   
          my $cmd_setsid = "export ORACLE_SID=$_";
          my $cmdpatch = "$ORACLE_HOME/OPatch/datapatch -verbose";

          print "$cmd_setsid\r\n";
          print "$cmdpatch\r\n";
          print "Logging to: $SQLPatch\r\n";
          
          $ENV{ORACLE_SID} = "$_";
          `$cmdpatch`;
          


        }

}
close (FILE);

print "Patch Success";


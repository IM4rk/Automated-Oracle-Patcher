#!/usr/bin/perl
use strict;


#Directory Variables
my $ORACLE_HOME='/oracle/product/12.1.0/db1';
my $APO='/oracle/APO';
my $shutdown_log='$ORACLE_HOME/shutdown.log';

#Unix Commands

my $cmd_startup = "$APO/startup.sh";
my $cmd_shutdown =  "$APO/shutdown.sh";
my $cmd_apply_patch = "$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $ORACLE_HOME/OPatch/apo.rsp";

#======================================
#Shutdown all database and listener   #
#======================================
print "Shutting down the listener and all corresponding databases....\r\n";
`$cmd_shutdown`;
print "Logging to: $ORACLE_HOME/shutdown.log \r\n ";

#========================================
#Apply patch                            #
#========================================
print "Applying patch......\r\n";
`$cmd_apply_patch`;

#=======================================
#Postpatch                             #
#=======================================

print "Starting up Database\r\n";
`$cmd_startup`;
print "logging in: /oracle/product/12.1.0/db1/startup.log";


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
          `$cmd_setsid`;
          `$cmdpatch`;


        }

}
close (FILE);

print "Patch Success";


#!/usr/bin/perl
use strict;


#Directory Variables
my $cd_patch_loc = '/oracle/oga_db_backups/files/patches/July_2017/25901056/25755742';
my $ORACLE_HOME='/oracle/product/12.1.0/db1';
my $APO='/oracle/APO/';
my $shutdown_log='$ORACLE_HOME/shutdown.log';

#Unix Commands
my $cmd_cd = "cd $cd_patch_loc";
my $cmd_pwd = "pwd";
my $whereami = `$cmd_pwd`;
my $cmd_tail = "tail -f";
my $cmd_startup = "/oracle/APO/startup.sh";


#Change directory to where the patch is
print "Changing Directory to where the patch is\r\n";
print "$cmd_cd\r\n";

#Shutdown all database and listener

print "Shutting down the listener and all corresponding databases\r\n";
`$APO/shutdown.sh`;
print "logging in:/oracle/product/12.1.0/db1/shutdown.log ";


#Apply Patch
my $cmd_apply_patch = "/oracle/product/12.1.0/db1/OPatch/opatch apply -silent -ocmrf /oracle/product/12.1.0/db1/OPatch/apo.rsp";
print "Applying patch\r\n";
`$cmd_apply_patch`;


#Postpatch 

print "Starting up Database\r\n";
`$cmd_startup`;
print "logging in: /oracle/product/12.1.0/db1/startup.log";


print "Applying post patch implemented per database";
my $filename = 'oratab';
chomp ($filename);

my $ORACLE_HOME='/oracle/product/12.1.0/db1';

open (FILE, "/etc/$filename") || die "Cannot open your file: $1";

while (my $line = <FILE> ){
        chomp $line;
        my @sid = $line =~  /^(.*?):\//;

        foreach  (@sid)
        {
          my $cmd = "export ORACLE_SID=$_";
          my $cmdpatch = "$ORACLE_HOME/OPatch/datapatch -verbose";

          print "$cmd\r\n";
           print "$cmdpatch\r\n";
          `$cmd`;
          `$cmdpatch`;


        }

}


close (FILE);

print "Patch Success";










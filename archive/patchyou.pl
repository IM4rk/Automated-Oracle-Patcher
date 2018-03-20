#!/usr/bin/perl
use strict;


#Directory Variables
my $cd_patch_loc = '/oracle/oga_db_backups/files/patches/July_2017/25901056/25755742';
my $ORACLE_HOME='/oracle/product/12.1.0/db1';
my $APO='/oracle/APO';
my $shutdown_log='$ORACLE_HOME/shutdown.log';

#Unix Commands
my $cmd_cd = "cd $cd_patch_loc";
my $cmd_pwd = "pwd";
my $whereami = `$cmd_pwd`;
my $cmd_tail = "tail -f";

 
#Change directory to where the patch is
print "Changing Directory to where the patch is\r\n";
print "$cmd_cd\r\n";

#Shutdown all database and listener

print "Shutting down the listener and all corresponding databases\r\n";
`$APO/shutdown.sh`;


#Apply Patch
my $cmd_apply_patch = "/oracle/product/12.1.0/db1/OPatch/opatch apply -silent -ocmrf /oracle/product/12.1.0/db1/OPatch/apo.rsp";
print "Applying patch";
`$cmd_apply_patch`;








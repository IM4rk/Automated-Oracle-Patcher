#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#Directory Variables
our $ORACLE_HOME='';
our $APO="/oracle/APO";
our $shutdown_log="$ORACLE_HOME/shutdown.log";


#=======================================
#Take parameter input                  #
###=====================================

GetOptions("home=s" => \$ORACLE_HOME);

#Unix Commands

our $cmd_startup = "$APO/stop_and_start/dbstart $ORACLE_HOME";
our $cmd_startup_mount = "$APO/stop_and_start/dbstart_mounted $ORACLE_HOME";
our $cmd_startup_upgrade = "$APO/stop_and_start/dbstart_upgrade $ORACLE_HOME";
our $cmd_shutdown =  "$APO/stop_and_start/dbshut $ORACLE_HOME";
our $cmd_apply_patch = "$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $ORACLE_HOME/OPatch/apo.rsp";
our $cmdpatch = "$ORACLE_HOME/OPatch/datapatch -verbose";




#======================================
#Shutdown all database and listener   #
#======================================
#print "Shutting down the listener and all corresponding databases....\r\n";

$ENV{ORACLE_OWNER}="oracle";
$ENV{ORACLE_HOME}="$ORACLE_HOME";
system ($cmd_shutdown);



#======================================
#Startup all database and listener     #
##======================================


$ENV{ORACLE_OWNER}="oracle";
$ENV{ORACLE_HOME}="$ORACLE_HOME";
system ($cmd_startup);



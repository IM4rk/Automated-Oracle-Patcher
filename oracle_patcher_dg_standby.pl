#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#Directory Variables
our $ORACLE_HOME = "";
our $APO="/oracle/APO";
our $shutdown_log="$ORACLE_HOME/shutdown.log";


#======================================
#Capture ORACLE_HOME variable          #
#======================================

open (FILE, "/etc/oratab") || die "Cannot open your file";

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
print "ORACLE_HOME variable has been set as: \n";
print "$ORACLE_HOME \n";

#======================================
##Patch Compatability Checks          #
##=====================================

our $cmd_check_patch  = "$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./ > /oracle/APO/logs/pre-patch_check.log";
system ($cmd_check_patch);
our $cmd_check = "grep passed /oracle/APO/logs/pre-patch_check.log | wc -l";
our $proceed_patch = `$cmd_check`;


if ($proceed_patch == 0 )
{
        print "Pre-check failed. Program will be terminated \n";
        print "View logs to check failure reason: \n";
        print "/oracle/APO/logs/pre-patch_check.log \n";
        exit;
}
else
{
        print "Pre-check passed. Commencing Patch \n";


#Unix Commands

our $cmd_startup = "$APO/stop_and_start/dbstart $ORACLE_HOME";
our $cmd_startup_mount = "$APO/stop_and_start/dbstart_mounted $ORACLE_HOME";
our $cmd_startup_standby_mount = "$APO/stop_and_start/dbstart_mounted_standby $ORACLE_HOME";
our $cmd_startup_standby_mount_dg = "$APO/stop_and_start/dbstart_mounted_standby_dg $ORACLE_HOME";
our $cmd_startup_clones = "$APO/stop_and_start/dbstart_clones $ORACLE_HOME";
our $cmd_startup_upgrade = "$APO/stop_and_start/dbstart_upgrade $ORACLE_HOME";
our $cmd_shutdown =  "$APO/stop_and_start/dbshut $ORACLE_HOME";
our $cmd_apply_patch = "$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $APO/config/apo.rsp";
our $cmdpatch = "$ORACLE_HOME/OPatch/datapatch -verbose";


#======================================
#Shutdown all database and listener   #
#======================================

$ENV{ORACLE_OWNER}="oracle";
$ENV{ORACLE_HOME}="$ORACLE_HOME";
system ($cmd_shutdown);
sleep (5);


#========================================
#Apply patch                            #
#========================================
print "Applying patch......\r\n";
system ($cmd_apply_patch);



#=======================================
#Postpatch                             #
#=======================================

#At this point, the patcher has two course of action depending on wether the database is a Clone/Primary  or Standby
#Segegate Primary and Standby databases and store in a config file


#Decide wether to delete old dg_list


our $cmd_pmon = "ps -ef | grep -i pmon | grep -v grep | wc -l";
our $proceed_delete = `$cmd_pmon`;

if ($proceed_delete == 0 )
{
 print "All databases are down therefore sticking to latest DG list before last shutdown \n";

}
else
{
  print "deleting old dg list \n";
  my $cmd_rm_dg_list = "rm /oracle/APO/DG/dg_list.log";
  `$cmd_rm_dg_list`;

open (FILE, "/etc/oratab") || die "Cannot open your file";
while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~ /^(.*?):\//;

        foreach  (@sid)
        {
          print "$_ \r\n";
          my $cmd_setsid = "export ORACLE_SID=$_";
          my $cmd_detect_standby = "/oracle/APO/DG/detect_standby.sh";

          print "$cmd_setsid\r\n";

          $ENV{ORACLE_SID}="$_";
          $ENV{ORACLE_HOME}="$ORACLE_HOME";
          sleep (2);
          system($cmd_detect_standby);

        }
}
close (FILE);

}


#Detect Standby Databases in a dataguard environment and write to config file
our $config_standby = "cat /oracle/APO/DG/dg_list.log > /oracle/APO/config/standby_dg";
system ($config_standby);
my $cmd_replace_OH = "perl -pi.back -e 's{TING}{$ORACLE_HOME}g;' /oracle/APO/config/standby_dg";
system ($cmd_replace_OH);


#Detect Primary of Clone Databases and write on the config file
#our $config_clone = "grep -v  _ds /etc/oratab > /oracle/APO/config/clone";
#system ($config_clone);


print "Starting Standby Databases on Mount mode and enabling log apply......  \r\n";
system ($cmd_startup_standby_mount_dg);

my $standby = 'standby_dg';
chomp ($standby);

my $cmd_rm_dg_post_patch="rm /oracle/APO/logs/dg_post_patch.log";
`$cmd_rm_dg_post_patch`;

#Loop through the standby list
open (FILE, "/oracle/APO/config/$standby") || die "Cannot open your file";



while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~ /^(.*?):/;


        foreach  (@sid)
        {

                 print  "INSTANCE_NAME:$_ \n" ;

                 $ENV{ORACLE_SID}="$_";
                 $ENV{ORACLE_HOME}="$ORACLE_HOME";
                 $ENV{PATH}="$ORACLE_HOME/bin";
                 my $cmd_apply_log = "/oracle/APO/DG/apply_log.sh";
                 system ($cmd_apply_log);
                 print "Full logs can be found in: \n";
                 print "/oracle/APO/logs/dg_post_patch.log \n";

         }
}
close (FILE);

}



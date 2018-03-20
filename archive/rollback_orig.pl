#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#Directory Variables
our $ORACLE_HOME = "";
our $APO="/oracle/APO";
our $shutdown_log="$ORACLE_HOME/shutdown.log";
our $PATCH_ID = '';

GetOptions("id=s" => \$PATCH_ID);



#======================================
#Capture ORACLE_HOME variable          #
#======================================

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
print "ORACLE_HOME variable has been set as: \n";
print "$ORACLE_HOME \n";

#Unix Commands

our $cmd_startup = "$APO/stop_and_start/dbstart $ORACLE_HOME";
our $cmd_startup_mount = "$APO/stop_and_start/dbstart_mounted $ORACLE_HOME";
our $cmd_startup_standby_mount = "$APO/stop_and_start/dbstart_mounted_standby $ORACLE_HOME";
our $cmd_startup_clones = "$APO/stop_and_start/dbstart_clones $ORACLE_HOME";
our $cmd_startup_upgrade = "$APO/stop_and_start/dbstart_upgrade $ORACLE_HOME";
our $cmd_shutdown =  "$APO/stop_and_start/dbshut $ORACLE_HOME";
our $cmd_apply_patch = "$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $APO/config/apo.rsp";
our $cmdpatch = "$ORACLE_HOME/OPatch/datapatch -verbose";
our $cmd_rollback = "$ORACLE_HOME/OPatch/opatch rollback -id $PATCH_ID";

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
print "Rolling back patch $PATCH_ID ......\r\n";
system ($cmd_rollback);



#=======================================
#Postpatch                             #
#=======================================

#At this point, the patcher has two course of action depending on wether the database is a clone  or standby

#Segegate Primary and Standby databases and store in a config file

our $config_clone = "grep -v  _ds /etc/oratab > /oracle/APO/config/clone";
our $config_standby = "grep -i  _ds /etc/oratab > /oracle/APO/config/standby";

system ($config_clone);
system ($config_standby);

		
print "Starting Standby Databases on Mount mode......  \r\n";
system ($cmd_startup_standby_mount);
my $standby = 'standby';
chomp ($standby);


open (FILE, "/oracle/APO/config/$standby") || die "Cannot open your file";

while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~ /^(.*?):\//;

        foreach  (@sid)
        {
          print "$_ \r\n";

       }
}
close (FILE);



print "Applying datapatch on each Primary or Clone databases  \r\n";
system ($cmd_startup_clones);
my $clones = 'clone';
chomp ($clones);


open (FILE, "/oracle/APO/config/$clones") || die "Cannot open your file";

while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~ /^(.*?):\//;

        foreach  (@sid)
        {
          print "$_ \r\n";
          my $cmd_setsid = "export ORACLE_SID=$_";
          my $cmdpatch = "$ORACLE_HOME/OPatch/datapatch -verbose";


          print "$cmd_setsid\r\n";
          print "$cmdpatch\r\n";

          $ENV{ORACLE_SID}="$_";
          $ENV{ORACLE_HOME}="$ORACLE_HOME";
          sleep (15);
          system($cmdpatch);

        }
}
close (FILE);


print "Patching Complete";




#======================================
#Produce Database Patch status         #
#======================================

my $cmd_delete_current_log = "rm /oracle/APO/logs/datapatch_result.log";
system ($cmd_delete_current_log);

open (FILE, "/oracle/APO/config/$clones") || die "Cannot open your file";
while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~ /^(.*?):\//;

        foreach  (@sid)
        {
          print "$_ \r\n";
          my $cmd_setsid = "export ORACLE_SID=$_";
          my $cmd_patch_status = "$APO/logs/datapatch_log.sh";

          $ENV{ORACLE_SID}="$_";
          $ENV{ORACLE_HOME}="$ORACLE_HOME";
          sleep (10);
          system($cmd_patch_status);

        }
}
close (FILE);


print "Database logs can be found in: \r\n";
print "/oracle/APO/logs/datapatch_result.log \r\n";




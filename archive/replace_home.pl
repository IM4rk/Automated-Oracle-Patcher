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

our $cmd_startup = "$APO/startup.sh";
our $cmd_shutdown =  "$APO/shutdown.sh";
our $cmd_apply_patch = "$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $ORACLE_HOME/OPatch/apo.rsp";
our $cmdpatch = "$ORACLE_HOME/OPatch/datapatch -verbose";


print "Oracle HOME set as: $ORACLE_HOME \r\n";
our $cmd_set_OHOME = "perl -pi -e 's/export ORACLE_HOME/export ORACLE_HOME=\ $ORACLE_HOME/' /oracle/APO/startup.sh";
system ($cmd_set_OHOME);


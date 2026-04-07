#!/bin/tclsh
#

puts "SETTING CONFIGURATION"

global complete
proc wait_to_complete {} {
global complete
set  complete [vucomplete]
if {!$complete} {after 5000  wait_to_complete} else { exit } 
}

dbset db ora
dbset bm TPC-C
diset connection system_password oracle
diset connection instance tpcc
diset tpcc count_ware 500
diset tpcc ora_driver timed
diset tpcc rampup 2
diset tpcc duration 15
loadscript
vuset vu 10
vucreate
vurun

wait_to_complete
vwait forever


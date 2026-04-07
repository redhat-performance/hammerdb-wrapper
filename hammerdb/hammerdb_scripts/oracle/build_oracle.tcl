puts "SETTING CONFIGURATION"
global complete
proc wait_to_complete {} {
global complete
set complete [vucomplete]
if {!$complete} {after 5000 wait_to_complete} else { exit }
}
dbset db ora
diset connection system_password oracle
diset connection instance tpcc 
diset tpcc count_ware 500
diset tpcc num_vu 40
diset tpcc tpcc_def_tab tpcctab
print dict
buildschema
wait_to_complete
vwait forever

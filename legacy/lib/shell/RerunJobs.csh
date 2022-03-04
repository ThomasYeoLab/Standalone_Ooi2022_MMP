#! /bin/csh -f

# $Author: B.T. Thomas Yeo $ $Date: 2011/04/13$

# checks!
if($#argv < 5) then
    echo "usage: RerunJobs.csh start stop key username num_nodes"
    echo "Selectively rerun jobs of user on launchpad between pbs_<start> to pbs_<stop> whose status contains the string key"
    exit
endif

set start = $1
set stop = $2
set key = $3
set username = $4
set num_nodes = $5

set count = $start
while($count <= $stop)
     set cmd = `grep $key /pbs/$username/pbsjob_$count.status`
     echo $cmd
     pbsubmit -l nodes=1:ppn=$num_nodes -c "$cmd"
     sleep 10

     @ count = $count + 1
end

#! /bin/csh -f

# $Author: B.T. Thomas Yeo $ $Date: 2011/04/13$

# checks!
if($#argv < 3) then
    echo "usage: DeleteJobs.csh start stop username"
    echo "Selectively delete jobs of user on launchpad between pbs_<start> to pbs_<stop>"
    exit
endif

set start = $1
set stop = $2
set username = $3

set count = $start
while($count <= $stop)
     set job = `qstat | grep $username | grep pbsjob_$count | head -n 1 | awk '{print $1}'`

     if($#job > 0) then
	set cmd = "qdel $job"
	echo $cmd
	eval $cmd
     endif

     @ count = $count + 1
end

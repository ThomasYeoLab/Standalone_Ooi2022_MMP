#! /bin/csh -f

# $Author: B.T. Thomas Yeo $ $Date: 2011/04/13$

# checks!
if($#argv < 5) then
    echo "usage: DeleteJobs.csh start stop test_flag str username"
    echo "Selectively delete jobs of users on launchpad between pbs_<start> to pbs_<stop> containing the <str> in their .status file"
    exit
endif

set start = $1
set stop = $2
set test_flag = $3
set str = $4
set username = $5

set count = $start
while($count <= $stop)
     set job = `qstat | grep ythomas | grep pbsjob_$count | awk '{print $1}'`

     if($#job > 0) then
	set find_str = `grep $str /pbs/$username/pbsjob_$count.status` 
     	if($#find_str > 0) then
	    echo "${job}: $find_str"
	    
	    if($test_flag == 0) then
		set cmd = "qdel $job"
		echo $cmd
		eval $cmd
	    endif
	endif
     endif

     @ count = $count + 1
end

#! /bin/csh -f 

# $Author: B.T. Thomas Yeo $ $Date: 2011/04/13$

# usage: NumberNodesUsedInLaunchpad.csh <username>
# Checks number of nodes being used in launchpad taking into account some jobs might use multiple nodes

if($#argv == 1) then

    set name = $1

    set x = `qstat | grep $name | awk '{print $5}' | grep R | wc -l`
    echo "$name has $x active jobs"

    set x =  `qstat -n -1 | grep $name | grep compute | awk '{print $12}' | awk -F\+ '{s = s + NF; print s}' | tail -n 1`
    echo "$name is using $x active nodes"

    set x =  `qstat -n -1 | grep $name | awk '{print $10}' | grep Q | wc -l`
    echo "$name has $x queued jobs"
else
    set x = `qstat -q | tail -n 1 | awk '{print $1}'`
    echo "Number of active jobs: $x"

    set x =  `qstat -n -1 | grep compute | awk '{print $12}' | awk -F\+ '{s = s + NF; print s}' | tail -n 1`
    echo "Number of active nodes: $x"

    set x =  `qstat -n -1 | awk '{print $10}' | grep Q | wc -l`
    echo "Number of queued jobs: $x"

endif

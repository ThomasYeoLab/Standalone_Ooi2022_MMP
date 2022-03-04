#!/bin/bash

#cd /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti && \
#	make \
#	|| exit

bin=/cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/stackcheck_nifti.test


cd /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti && \
	g++ -o $bin stackcheck_nifti.cpp -static -Wextra -Wall -Werror -ggdb -I/autofs/cluster/vc/buckner/code/lib/c/nifticlib-0.4/linux_x86_64/include -I/autofs/cluster/vc/buckner/code/lib/c/nifticlib-0.4/linux_x86_64/include -I/usr/include -L/autofs/cluster/vc/buckner/code/lib/c/nifticlib-0.4/linux_x86_64/lib -lfslio -L/autofs/cluster/vc/buckner/code/lib/c/nifticlib-0.4/linux_x86_64/lib -lniftiio -L/usr/lib -L/autofs/cluster/vc/buckner/code/lib/c/nifticlib-0.4/linux_x86_64/lib -lznz -lm -lz  \
	|| exit 1

echo "Running with $bin"

cd /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti && \
	rm -vrf /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test2/new-dev && \
	mkdir /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test2/new-dev && \
	$bin --threshold 150 --zip -report -plot -mean -mask -snr -stdev -i /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test/MGPH01MGMR1R1_BOLD_5_EQC.nii -o /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test2/new-dev/MGPH01MGMR1R1_BOLD_5_EQC 2>&1 > /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test2/new-dev/MGPH01MGMR1R1_BOLD_5_EQC.log && \
	echo "SUCESSFULLY EXITED" || echo "ERROR: EXITED $?"
echo gunzip -v test2/new-dev/*.gz && \
	gunzip -v test2/new-dev/*.gz
echo "================================================================================"
echo diff -d -w -r test2/new-dev test2/test-dev && \
	diff -d -w -r test2/new-dev test2/test-dev;
echo "================================================================================"
echo "DONE TEST WITH ZIP"

echo
echo

cd /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti && \
	rm -vrf /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test2/new-dev && \
	mkdir /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test2/new-dev && \
	$bin --threshold 150 -report -plot -mean -mask -snr -stdev -i /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test/MGPH01MGMR1R1_BOLD_5_EQC.nii -o /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test2/new-dev/MGPH01MGMR1R1_BOLD_5_EQC 2>&1 > /cluster/vc/buckner/code/lib/c/src/stackcheck_nifti/test2/new-dev/MGPH01MGMR1R1_BOLD_5_EQC.log && \
	echo "SUCESSFULLY EXITED" || echo "ERROR: EXITED $?"
echo "================================================================================"
echo diff -d -w -r test2/new-dev test2/test-dev && \
	diff -d -w -r test2/new-dev test2/test-dev;
echo "================================================================================";
echo "DONE TEST NO ZIP"

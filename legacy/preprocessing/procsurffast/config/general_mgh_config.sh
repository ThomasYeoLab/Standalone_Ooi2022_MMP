#!/bin/bash

echo "Switching FreeSurfer version (to stable4) for procsurffast"

export FREESURFER_HOME=/usr/local/freesurfer/stable4/ 
export FSFAST_HOME=$FREESURFER_HOME/fsfast
export MNI_DIR=$FREESURFER_HOME/mni
export FSL_DIR=/usr/pubsw/packages/fsl/current
source $FREESURFER_HOME/SetUpFreeSurfer.sh

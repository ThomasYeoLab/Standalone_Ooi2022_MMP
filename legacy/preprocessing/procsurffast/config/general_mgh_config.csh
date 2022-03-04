#! /bin/csh -f

echo "Setting up general mgh configuration"


#set procsurffast_path = /autofs/cluster/nexus/7/software/code/procsurffast/

#setenv PATH ./:${procsurffast_path}:${procsurffast_path}/utilities/:${procsurffast_path}/dependencies/:$PATH

#set path = (. \
#            $procsurffast_path \
#            ${procsurffast_path}/utilities/ \
#            ${procsurffast_path}/dependencies/ \
#	    $path)



setenv FREESURFER_HOME /usr/local/freesurfer/stable4/ 
setenv FSFAST_HOME $FREESURFER_HOME/fsfast
setenv MNI_DIR $FREESURFER_HOME/mni
setenv FSL_DIR /usr/pubsw/packages/fsl/current
source $FREESURFER_HOME/SetUpFreeSurfer.csh



# temporary
#setenv PATH ${PATH}:/autofs/cluster/nexus/12/users/ythomas/general_fcfast/
#set path = (/autofs/cluster/nexus/12/users/ythomas/general_fcfast/ $path)

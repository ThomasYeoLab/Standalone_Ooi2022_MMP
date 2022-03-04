#! /bin/csh -f

set functions = (actmapf_nifti bandpass_nifti gauss_nifti glm_nifti imgopr_nifti plot_nifti qnt_nifti rho2z_nifti stackcheck_nifti timecourse_nifti var_nifti)

set curr_pwd = `pwd`

foreach f ($functions)
    cd $f
    make clean;
    make all;
    find . -name "*.o" -print | xargs rm
    cd $curr_pwd
end

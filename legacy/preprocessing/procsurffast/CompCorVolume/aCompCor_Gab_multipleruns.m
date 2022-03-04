function aCompCor_Gab_multipleruns(funclist, roilist, outfile)
% This script will perform compcor (adapted from Chai, 2012) and output 5 compcor components to a textfile (as specified by outfile)
% Example: aCompCor_Gab_multipleruns('ALFIE48_reorient_skip_faln_mc_g1000000000_bpss.txt', '/Data/Experiments/ALFIE/Preprocess/ALFIE_RW_Resting_fcMRI/ALFIE48/bold/005/ALFIE48.func.wm.vent.nii.gz', 'ALFIE48_vent_wm_5aCompCor.dat')
% Input:	funclist - path to a textfile that lists all functional runs to be processed
%		roilist - path to the ventricle+white matter mask (nifti)
%		outfile - path to the output text file; output will be a Nx5 matrix where N = number of volumes and each column corresponds to 1 principal component
% First, concatenate all runs as specified by funclist, then perform compcor
% For more details into compcor, see aCompCor_Gab.m
% Created by Jesisca Tandi and Thomas Yeo

funcfile = fopen(funclist);
funcfile = textscan(funcfile, '%s');
funcfile = funcfile{1};

if ~isempty(cell2mat(strfind(roilist, 'txt')))
    roifile = fopen(roilist);
    roifile = textscan(roifile, '%s');
    roifile = roifile{1};
    if numel(roifile~=1)
        disp('More than 1 ROI file found!')
    end
else
    roifile = roilist;
end

if numel(funcfile)~=1
    
    mergedfile = [dirname(funclist) '/mergedfunc.nii.gz'];
    % Concatenate functional data temporally
    disp(['fslmerge -t ' mergedfile ' ' sprintf('%s.nii.gz ', funcfile{:})])
    [a b] = system(['fslmerge -t ' mergedfile ' ' sprintf('%s.nii.gz ', funcfile{:})]);
    if (a==0)
        disp('Concatenated runs!')
    else
        error('Unable to concatenate')
    end
    
    funcfile_now = mergedfile;
else
    funcfile_now = [funcfile{1} '.nii.gz'];
    
end
disp(funcfile_now)

ROIdata = aCompCor_Gab(funcfile_now, roifile);

outprint = fopen(outfile, 'w+');
fprintf(outprint, [repmat('%f\t', [1 size(ROIdata,2)]) '\n'], ROIdata');
fclose(outprint)


exit(1)

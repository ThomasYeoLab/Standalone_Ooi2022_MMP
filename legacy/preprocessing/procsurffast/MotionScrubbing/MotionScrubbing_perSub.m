function MotionScrubbing_perSub(datadir, subid)
% How to run:
%	MotionScrubbing_perSub('/Data/Experiments/ALFIE/Preprocess/ALFIE_RW_Resting_fcMRI/', 'ALFIE01')
% This is a wrapper script to perform motion scrubbing on fc-preprocessed data located in <datadir>/<subid>
% It will loop through all runs (as set by <datadir>/<subid>/scripts/<subid>.params)
% Output files can be found in <datadir>/<subid>/qc, e.g.
%	<subid>_bld<runnumber>_FrameIndex_FD0.2_DVARS0.005.txt - a binary mask (Nx1) where N=number of volumes in that run; 1=keep 0=discard; Mask is created based on the threshold specified (see filename "FrameIndex_FD###_DVARS#####.txt")
%	<subid>_bld<runnumber>_FD_DVARS.txt - a Nx2 matrix, column 1 = FD, column 2 = DVARS
%	<subid>_bld<runnumber>_MotionScrub.jpg - time courses of FD and DVARS
% For more details, see MotionScrubbing_perrun.m
% Written by Jesisca Tandi and Thomas Yeo

addpath(getenv('CODE_DIR'), 'procsurffast', 'MotionScrubbing')


% Get subject run numbers
[a runno] = system(['cat ' char(datadir) '/' char(subid) '/scripts/' char(subid) '.params | grep fcbold']);
eval(strrep(strrep(runno(5:end),'(', '['), ')', ']'));

    FD_th = []; % Use default
    DVARS_th = []; % Use default

disp(['Running motion scrubbing for ' char(subid) ' with run numbers ' char(runno)])

for r = 1:numel(fcbold)
	mcfile = [datadir '/' char(subid) '/bold/' num2str(fcbold(r), '%03d') '/' char(subid) '_bld' num2str(fcbold(r), '%03d') '_rest_reorient_skip_faln_mc.nii.gz'];
	fcfile = [datadir '/' char(subid) '/bold/' num2str(fcbold(r), '%03d') '/' char(subid) '_bld' num2str(fcbold(r), '%03d') '_rest_reorient_skip_faln_mc_g1000000000_bpss_resid.nii.gz'];
	rel_rms = [datadir '/' char(subid) '/bold/' num2str(fcbold(r), '%03d') '/' char(subid) '_bld' num2str(fcbold(r), '%03d') '_rest_reorient_skip_faln_mc_rel.rms'];
	outfilename = [datadir '/' char(subid) '/qc/' char(subid) '_bld' num2str(fcbold(r), '%03d')];
    
	MotionScrubbing_perrun(mcfile, fcfile, rel_rms, FD_th, DVARS_th, outfilename);
    clear mcfile fcfile rel_rms outfilename
end


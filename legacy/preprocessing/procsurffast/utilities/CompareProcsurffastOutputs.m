function CompareProcsurffastOutputs(sdir1, sdir2, s, bold_runs, output_file)

% CompareProcsurffastOutputs(sdir1, sdir2, s, bold_runs, output_file)
%
% Compare sdir1/s with sdir2/s
% Assume freesurfer found here sdir1/s_FS and sdir2/s_FS
% bold runs is a vector specifying bold runs number
% output_file is report file. Default = sdir2/s.report.txt

if(nargin < 5)
   output_file = fullfile(sdir2, [s '.report.txt']);
end

fid = fopen(output_file, 'w');

for inputs = {'_rest_reorient.nii.gz', '_rest_reorient_skip.nii.gz', '_rest_reorient_skip_faln.nii.gz', '_rest_reorient_skip_faln_mc.nii.gz', '_rest_reorient_skip_faln_mc_atl_g7.nii.gz', '_rest_reorient_skip_faln_mc_atl_g7_bpss_resid.nii.gz', '_rest_reorient_skip_faln_mc_g1000000000_bpss_resid.nii.gz'}
  fprintf(fid, [inputs{1} '\n']);
for i = 1:length(bold_runs)
  input = [s '_bld' num2str(bold_runs(i), '%03d') inputs{1}];

  file1 = fullfile(sdir1, s, 'bold', num2str(bold_runs(i), '%03d'), input);
  file2 = fullfile(sdir2, s, 'bold', num2str(bold_runs(i), '%03d'), input);
  if(exist(file1, 'file') && exist(file2, 'file'))
	y = MRIread(file2);	
	x = MRIread(file1);

	x = transpose(reshape(x.vol, size(x.vol, 1)*size(x.vol, 2)*size(x.vol, 3), size(x.vol, 4)));
	y = transpose(reshape(y.vol, size(y.vol, 1)*size(y.vol, 2)*size(y.vol, 3), size(y.vol, 4)));
	diff = CorrelateFingerprints(x, y);
	Y = sort(diff, 'ascend');
	vol_diff_min = Y(1);
	vol_diff_fiveper = Y(round(0.05*length(Y)));

	fprintf(fid, ['Max Diff: ' num2str(max(abs(x(:) - y(:)))) ' (range: ' num2str(range(x(:))) ') , Min Corr: ' num2str(vol_diff_min) ', Bottom 5%% Corr: ' num2str(vol_diff_fiveper) ' \n']);
  end
end
end


for hemi = {'lh' 'rh'}
for inputs = {'_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6.nii.gz', '_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6_sm6.nii.gz', '_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6_sm6_fsaverage5.nii.gz'}
  fprintf(fid, [hemi{1} inputs{1} '\n']);
for i = 1:length(bold_runs)
  input = [hemi{1} '.' s '_bld' num2str(bold_runs(i), '%03d') inputs{1}];

  file1 = fullfile(sdir1, s, 'surf', input);
  file2 = fullfile(sdir2, s, 'surf', input);
  if(exist(file1, 'file') && exist(file2, 'file'))
        y = MRIread(file2);  
        x = MRIread(file1);

        x = transpose(reshape(x.vol, size(x.vol, 1)*size(x.vol, 2)*size(x.vol, 3), size(x.vol, 4)));
        y = transpose(reshape(y.vol, size(y.vol, 1)*size(y.vol, 2)*size(y.vol, 3), size(y.vol, 4)));
        diff = CorrelateFingerprints(x, y);
        Y = sort(diff, 'ascend');
        surf_diff_min = Y(1);
        surf_diff_fiveper = Y(round(0.05*length(Y)));

        fprintf(fid, ['Max Diff: ' num2str(max(abs(x(:) - y(:)))) ' (range: ' num2str(range(x(:))) ') , Min Corr: ' num2str(surf_diff_min) ', Bottom 5%% Corr: ' num2str(surf_diff_fiveper) ' \n']);
  end
end
end
end


for inputs = {'_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_FS1mm_FS2mm_sm6.nii.gz', '_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_FS1mm_MNI1mm_MNI2mm_sm6.nii.gz'}
  fprintf(fid, [inputs{1} '\n']);
  
  if(strcmp(inputs{1}, '_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_FS1mm_FS2mm_sm6.nii.gz'))
    mask = MRIread(fullfile(getenv('CODE_DIR'), 'templates/volume/FS_nonlinear_volumetric_space_4.5/ReallyLooseHeadMask.GCA.t0.5.nii.gz'));
  else
    mask = MRIread(fullfile(getenv('CODE_DIR'), 'templates/volume/FSL_MNI152_FS4.5.0/mri/ReallyLooseMNIHeadMask.2mm.nii.gz'));  
  end
      
  
for i = 1:length(bold_runs)
  input = [s '_bld' num2str(bold_runs(i), '%03d') inputs{1}];

  file1 = fullfile(sdir1, s, 'vol', input);
  file2 = fullfile(sdir2, s, 'vol', input);
  if(exist(file1, 'file') && exist(file2, 'file'))
        y = MRIread(file2);  
        x = MRIread(file1);

        x = transpose(reshape(x.vol, size(x.vol, 1)*size(x.vol, 2)*size(x.vol, 3), size(x.vol, 4)));
        y = transpose(reshape(y.vol, size(y.vol, 1)*size(y.vol, 2)*size(y.vol, 3), size(y.vol, 4)));
        diff = CorrelateFingerprints(x, y);
        Y = sort(diff, 'ascend');
        vol_diff_min = Y(1);
        vol_diff_fiveper = Y(round(0.05*length(Y)));
        vol_mask_min_diff = min(diff(mask.vol(:) == 1));
        
        fprintf(fid, ['Max Diff: ' num2str(max(abs(x(:) - y(:)))) ' (range: ' num2str(range(x(:))) ') , Min Corr: ' num2str(vol_diff_min) ', Bottom 5%% Corr: ' num2str(vol_diff_fiveper) ', Min Brain Mask Corr: ' num2str(vol_mask_min_diff) ' \n']);
  end
end
end

for hemi = {'lh' 'rh'}
for inputs = {'.white' '.pial' '.sphere.reg'}
  fprintf(fid, [hemi{1} inputs{1} '\n']);
  input = [hemi{1} inputs{1}];

  file1 = fullfile(sdir1, [s '_FS'], 'surf', input);
  file2 = fullfile(sdir2, [s '_FS'], 'surf', input);
  if(exist(file1, 'file') && exist(file2, 'file'))
	[vertices1, faces1] = read_surf(file1);
	[vertices2, faces2] = read_surf(file2);

	if(size(vertices1, 1) ~= size(vertices2, 1))
	  fprintf(fid, 'Inf\n');
  	else
 	  diff = sqrt(sum((vertices1 - vertices2).^2, 2));
          Y = sort(diff, 'descend');
    	  surf_diff_min = Y(1);
          surf_diff_fiveper = Y(round(0.05*length(Y)));

          fprintf(fid, ['Max Diff: ' num2str(max(abs(vertices1(:) - vertices2(:)))) ' (range: ' num2str(range(x(:))) ') , Min Corr: ' num2str(surf_diff_min) ', Bottom 5%% Corr: ' num2str(surf_diff_fiveper) ' \n']);
	end		
  end
end
end




fclose(fid);

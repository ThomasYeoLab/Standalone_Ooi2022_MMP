function dvars = CalculateDVARS(timeseries)

% Calculate intensity change over time, relative to previous frame, averaged over the whole brain
% (using rms of backward difference)
% 
% Input : timeseries, is 2-D: M voxels x N timepoints
% Output : dvars, is 1-D: 1 x (N-1) timepoints
%           (dvars is relative to previous frame, hence output is N-1
%           timepoints)
%
% Note that only brain region voxels are included in the timeseries data
% Timeseries data is normalized against median of brain-region voxel
% values (based on motion corrected data), multiplied by 1000
% Written by Jesisca Tandi and Thomas Yeo

disp(['Calculating DVARS based on ' num2str(size(timeseries,1)) ' voxels on the brain region from ' num2str(size(timeseries,2)) ' frames'])

intensity_change = bsxfun(@minus, timeseries(:,2:end),timeseries(:,1:(end-1)));
dvars = sqrt(mean((abs(intensity_change)).^2, 1));

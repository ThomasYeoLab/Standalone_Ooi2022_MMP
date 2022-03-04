function [mcdata, mcmaskvol] = CreateBrainMask(mcfile, th)
% Create brain mask from motion-corrected data (threshold = 0.3)
% Written by Jesisca Tandi and Thomas Yeo

% Load motion corrected data
    mcdata = MRIread(mcfile);
    mcmask = mcdata;
    mcdata = mcdata.vol;

% Create brain mask based on motion-corrected data (before smoothing)
    [mcmaskvol] = CreateMask(mcdata, th);
    mcmask.vol = mcmaskvol;
    MRIwrite(mcmask, [strrep(mcfile,'.nii', '_mask.nii')]);

end

function [brainmask] = CreateMask(mcdata, t)
% Input - mcdata : M x N x #slice x #frame matrix of motion corrected data
%       - t : mask threshold (scale from 0 to 1)


% Load data and normalize it against largest value
    mcdata_sum = sum(mcdata,4);
    mcdata_sum = mcdata_sum./max(mcdata_sum(:));


% Threshold at 0.3
    mcdata_bin = (mcdata_sum>t);

    [mcdata_bin_comp, N] = bwlabeln(mcdata_bin, 6);

    if (mcdata_bin_comp(1,1,1) ~= 0)
        error(['Background not zero!'])
    end


% Get (second) largest component, set it as the brain mask
    maxsize = NaN(1,N);

    for i = 1:N
        maxsize(i) = sum(sum(sum(mcdata_bin_comp==i)));
    end

    if sum(maxsize==max(maxsize))>1;
        error('Cannot find a good mask')
    end

    brainmask = mcdata_bin_comp==find(maxsize==max(maxsize));

end


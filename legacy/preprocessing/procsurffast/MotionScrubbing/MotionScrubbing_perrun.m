function [fd, dvars, FrameIndex] = MotionScrubbing_perrun(mcfile, fcfile, rel_rms, FD_th, DVARS_th, outfilename)
% How to run :
% MotionScrubbing_perrun('/CheeVul/Preprocessed_fMRI/CheeVul_SD_Resting/CV40/bold/006/CV40_bld006_rest_reorient_skip_faln_mc.nii.gz', '/CheeVul/Preprocessed_fMRI/CheeVul_SD_Resting/CV40/bold/006/CV40_bld006_rest_reorient_skip_faln_mc_g1000000000_bpss_resid.nii.gz', '/CheeVul/Preprocessed_fMRI/CheeVul_SD_Resting/CV40/bold/006/CV40_bld006_rest_reorient_skip_faln_mc_rel.rms', [0.2], [0.005], '/CheeVul/Preprocessed_fMRI/CheeVul_SD_Resting/CV40/qc/CV40_bld006')
%     To use default thresholds, pass in empty matrix for DVARS_th and FD_th
%     To save figures and .txt files, specify 'outfilename'. If not
%     specified, no figure or textfiles will be saved
%
% FD threshold is in mm. DVARS threshold is the actual number (e.g. 0.5% should be written as 0.005)
% Adapted from Power 2012
% 
% Input:    mcfile - motion corrected nifti
%           fcfile - functional-conn preprocessed data (after regression)
%           rel_rms - relative motion textfile
%           FD_th - threshold for Framewise Displacement (default 0.2mm)
%           DVARS_th - threshold for DVARS (default is 0.005 or 0.5%)
%           outfilename - specify if you want to save the outputs (figures and textfiles of FD, DVARS, and Frame index)
%
% Output (if specified):	*FrameIndex_FD0.2_DVARS0.005.txt - a binary mask (Nx1) where N=number of volumes in that run; 1=keep 0=discard; Mask is created based on the threshold specified (see filename "FrameIndex_FD###_DVARS#####.txt")
%				*FD_DVARS.txt - a Nx2 matrix, column 1 = FD, column 2 = DVARS
%				*MotionScrub.jpg - time courses of FD and DVARS 
% Written by Jesisca Tandi and Thomas Yeo

fwhm = 6;
sigma = fwhm/(2*((2*log(2))^0.5));
mask_th = 0.3;
DVARS_default_th = 0.005;
FD_default_th = 0.2;

if (nargin<3)
    error('Not enough arguments')
elseif (nargin>6)
    error('Too many input arguments')
elseif (nargin==6)
    fig_flag = 1;
    if isempty(FD_th)
        FD_th = FD_default_th;
        disp(['Framewise Displacement threshold not specified. Using the default FD threshold : ' num2str(FD_default_th)])
    end
    if isempty(DVARS_th)
        DVARS_th = DVARS_default_th;
        disp(['DVARS threshold not specified. Using the default DVARS threshold : ' num2str(DVARS_default_th)])
    end
else
    fig_flag = 0;
    if (nargin==4)
        DVARS_th = DVARS_default_th;
        disp(['DVARS threshold not specified. Using the default DVARS threshold : ' num2str(DVARS_default_th)])
    elseif ((nargin == 5) & isempty(FD_th))
        FD_th = FD_default_th;
        disp(['Framewise Displacement threshold not specified. Using the default FD threshold : ' num2str(FD_default_th)])
    end
end

disp(['Running motion scrubbing on ' char(fcfile) ' with FD threshold ' num2str(FD_th) ' and DVARS threshold ' num2str(DVARS_th)])

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % Framewise Displacement  % % % % % % % % % % % % % %
fd = load(rel_rms);
fd(1) = []; % Discard 1st frame

    % Plot FD
    if (fig_flag==1)
        figure; subplot(2,1,1); plot(fd);
        title('Framewise Displacement (in mm)');
        ylabel('FD (mm)')
        xlim = get(gca, 'XLim');
        for l = 1:numel(FD_th)
            line([xlim(1) xlim(2)], [FD_th(l) FD_th(l)], 'color', 'r');
        end
        set(gcf, 'PaperPositionMode', 'auto')
        clear l xlim
    end
    

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % DVARS % % % % % % % % % % % % % % % % % 

% Create brain mask from mc-data and get the mode value of mcdata within brain mask across entire runs
    [mc, mc_bin] = CreateBrainMask(mcfile, mask_th);
    mc_masked = mc(logical(repmat(mc_bin, [1 1 1 size(mc,4)])));
    mc_masked = reshape(mc_masked, [sum(mc_bin(:)==1) size(mc,4)]);
    mc_modenorm = mode(round(mc_masked(:))); % round up and then find mode for normalization

% Smooth fc-preprocessed data using fslmaths
    fc_smooth_file = [fcfile(1:end-7) '_sm' num2str(fwhm) '.nii.gz'];
    if ~exist(fc_smooth_file, 'file')
        [a b] = system(['fslmaths ' char(fcfile) ' -s ' num2str(sigma) ' ' char(fc_smooth_file)]);
        if (a == 1)
            error('Unable to smooth motion-corrected data')
        end
    end
    
% Calculate DVARS
    fc = MRIread(fc_smooth_file); % load fc-smoothed data
    fc = fc.vol;
    fc_norm = fc./mc_modenorm.*1000; % Normalize fc-smoothed data with mode of mcdata (within brain mask across entire runs)
    fc_norm = fc_norm(repmat(mc_bin, [1 1 1 size(fc_norm,4)])); % Get fc-smoothed data within the brain mask only
    fc_norm_reshape = reshape(fc_norm, [sum(mc_bin(:)==1) size(fc,4)]);
    dvars = CalculateDVARS(fc_norm_reshape);

    
    % Plot DVARS
    if (fig_flag==1)
        subplot(2,1,2); plot(dvars);
        title('DVARS');
        xlabel('Frame Number');
        ylabel('DVARS (x1000)');
        xlim = get(gca, 'XLim');
        for l = 1:numel(DVARS_th)
            line([xlim(1) xlim(2)], [DVARS_th(l)*1000 DVARS_th(l)*1000], 'color', 'r');
        end
        set(gcf, 'PaperPositionMode', 'auto');
        saveas(gcf, [outfilename '_MotionScrub.jpg']);
        clear l xlim
    end


    
    
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Save data
    if (fig_flag==1)
        outtxtfile = fopen([outfilename '_FD_DVARS.txt'], 'w+');
        fprintf(outtxtfile, '%f\t%f\n', [fd(:) dvars(:)./1000]');
        fclose all;
    end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 





% % % % % % % % % % % % % % Create mask % % % % % % % % % % % % % % % %
% Pad the first frame with 0
% FD and DVARS masks were augmented by also excluding 1-back and 2-forward
% frames. This means, if movement occurs between frame 1 and 2, frame
% 1,2,3,4 will be excluded/scrubbed
% If any of FD or DVARS fails (above threshold), that frames will be
% discarded

for i = 1:numel(FD_th)
    for j = 1:numel(DVARS_th)
        fd_mask = fd(:)<FD_th(i);
        dvars_mask = dvars(:)<(DVARS_th(j)*1000);
        % Augment mask by removing 1-frame back and 2-frames forward
        fd_aug = Create1FrameBack2FrameForwardMask(fd_mask);
        dvars_aug = Create1FrameBack2FrameForwardMask(dvars_mask);
        % Pad mask with 0 for the first frame; basically removing the first
        % frame
        dvars_aug = [0; dvars_aug];
        fd_aug = [0; fd_aug];
        % Do OR-operation of FD and DVARS augmented mask
        % i.e. frames are removed if any measure is above the threshold
        FrameIndex{i,j} = [fd_aug&dvars_aug];
        if (fig_flag==1)
            outfilename_index = fopen([outfilename '_FrameIndex_FD' num2str(FD_th(i)) '_DVARS' num2str(DVARS_th(j)) '.txt'], 'w+');
            fprintf(outfilename_index, '%d\n', FrameIndex{i,j});
            fclose all;
        end
        clear fd_mask dvars_mask dvars_aug fd_aug
    end
end

end

function aug_mask = Create1FrameBack2FrameForwardMask(mask)

mask = mask(:);
aug_mask = (mask & [mask(2:end); 1] & [1; mask(1:end-1)] & [1;1; mask(1:end-2)]);

end

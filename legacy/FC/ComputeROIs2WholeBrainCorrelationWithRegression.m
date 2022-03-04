function ComputeROIs2WholeBrainCorrelationWithRegression(output_file, ROI_timecourse_text, brain_timecourse_text, ROIs_list, brain_mask, ROI_regress_list, brain_regress_list, avg_sub_bool)

% type "ComputeROIs2WholeBrainCorrelationWithRegression" for help

if(nargin == 0)
  disp('ComputeROIs2WholeBrainCorrelationWithRegression output_file, ROI_timecourse_text, brain_timecourse_text, ROIs_list, brain_mask, ROI_regress_list, Brain_regress_list, avg_sub_bool');
  disp(' ');
  disp('ROI_timecourse_text and brain_timecourse_text are text files with each line corresponding to 1 subject. If subject has multiple runs, it still takes');
  disp('up 1 line separated by spaces. This is because we average across runs if we have multiple runs for individual subjects.'); 
  disp('For example, if varargin_text1 consists of two subjects, where subject 1 has 1 run and subject 2 has two runs, then varargin_text1 might look like:'); 
  disp('   <full_path>/subject1_run1_bold.nii.gz');
  disp('   <full_path>/subject2_run1_bold.nii.gz <full_path>/subject2_run2_bold.nii.gz');   
  disp(' ');
  disp('Passing in two lists is useful when you are computing fcMRI for example between the cerebrum and the cerebellum,');
  disp('so that ROI_timecourse_text might consist of fMRI data in surface space, and brain_timecourse_text consists of fMRI data in volume space.');
  disp('If you are performing fcMRI within the cerebrum, then ROI_timecourse_text might be the same as brain_timecourse_text.');
  disp(' ');
  disp(' ');
  disp('ROIs_list is a text file with each line corresponding to an ROI. ');
  disp('Each ROI should be a full path pointing to a surface or volume of the same size as the spatial dimension of each subject fMRI data.');
  disp('Each ROI should have extension ''nii.gz'', ''mgh'', ''mgz'' or ''label''. If the extension is nii.gz, mgh or mgz, then each ROI is assumed to be a ');  
  disp('a binary mask of zeros and ones. If the extension is label, then it follows the freesurfer label format');
  disp('Note that all the file types can represent both surface and volume data, as long as the dimensions are consistent with the fMRI data.');
  disp('For example, the FreeSurfer fsaverage5 surface has 10242 vertices. Thus if a nii.gz volume has dimensions 1 x 10242 x 1, then it can be treated like a surface'); 
  disp('ROI if the input data are surface data');
  disp('fcMRI for the ROI is computed by averaging the fMRI signal within the ROI and correlation with this averaged signal is computed');
  disp(' ');
  disp('For convenience, ROIs_list can also be just binary surfaces/volumes of type ''nii.gz'', ''mgh'' or ''mgz'' or ''label''');
  disp(' ');
  disp('brain_mask is a ''nii.gz'', ''mgh'', ''mgz'' or ''label'' surface/volume indicating the part of the brain we are interested in. If we are interested');
  disp('in the entire brain, brain_mask should be the string ''NONE''');
  disp(' ')
  disp('For example, if we are performing fcMRI on the surface between a single ROI consisting of the vertices 3, 5, 7 to the entire fsaverage5 mesh with 10242 vertices.');
  disp('Then we can create the following in matlab:');
  disp('   ROI = zeros(1, 10242); ROI([3 5 7]) = 1; save_mgh(ROI, ''ROI.mgh'', eye(4));');
  disp('Then when calling the code, ROIs_list is a text file with the full path to ROI.mgh and brain_mask = "NONE"');
  disp(' ');
  disp(' ');
  disp('ROI_regress_list, brain_regress_list are text files of binary masks for regressing out nuisance time series from the input fMRI volumes/surface data'); 
  disp('specified in ROI_timecourse_text and brain_timecourse_text respectively. Signal within each mask is averaged to become a signal to be regressed from the fMRI volume/surface data.');
  disp('If no regression is needed, then regress_list should be set to the string "NONE". The regression signals are jointly (rather than sequentially) regressed out.');
  disp('For example, in the case when we are computing fcMRI between a cortical ROI and cerebellum');
  disp('so that the ROI_timecourse_text consists of fmri data in surface space, brain_timecourse_text consists of fmri data in volume space, '); 
  disp('ROIs_list consists of ROIs in surface space and brain_mask is the full path to a cerebellar mask, we might be interested in regressing out signal from the visual');
  disp('cortex adjacent to the cerebellum. In this case, brain_regress_list is a text file consisting of the path to a binary mask of visual cortex adjacent to');
  disp('the cerebellum. For each of the fMRI volume specified in brain_regress_list, the code will average the fMRI time course within the binary mask of the');
  disp('visual cortex and regress the average time course from the same fMRI volume. In this case, ROI_regress_list = "NONE" because we are not regressing anything');
  disp('from the cerebrum.');
  disp(' ');
  disp(' ');
  disp('avg_sub_bool = 1 implies correlation should be averaged across multiple subjects');  
  disp('avg_sub_bool = 0 implies correlation is not averaged across multiple subjects');
  disp(' ');
  disp('If output_file is of the type ".mat", then the resulting fcMRI correlation is saved as a matlab matrix. ');
  disp('For example, if ROIs consists of N ROIs, brain_mask consists of M vertices/voxels, # subjects = S, avg_sub_bool = 0, then output is a N x M x S matrix.'); 
  disp('For example, if ROIs consists of N ROIs, brain_mask consists of M vertices/voxels, # subjects = S, avg_sub_bool = 1, then output is a N x M matrix.'); 
  disp(' ');
  disp('Since this is whole brain correlation, output_file can be of the type ''nii.gz'', ''mgz'', ''mgh'' if');
  disp('    (a)  There is one subject, output is a 4D surface/volume, where the size of the 4th dimension corresponds to the number of ROIs in ROIs_list.'); 
  disp('         The first 3 dimensions follow that of the spatial dimensions of the fMRI surfaces/volumes in brain_timecourse_text.'); 
  disp('         Each 3D frame is set to 0 except for the vertices/voxels of the brain_mask whose correlation is computed.');
  disp('    (b)  There is multiple subjects, avg_sub_bool = 1, output is a 4D surface/volume, where the size of the 4th dimension corresponds to the number of ROIs in ROIs_list.'); 
  disp('         The first 3 dimensions follow that of the spatial dimensions of the fMRI surfaces/volumes in brain_timecourse_text.'); 
  disp('         Each 3D frame is set to 0 except for the vertices/voxels of the brain_mask whose correlation is computed.');
  disp('    (c)  There is one ROI in ROIs_list, avg_sub_bool = 0, output is a 4D surface/volume, where the size of the 4th dimension corresponds to the number of subjects.'); 
  disp('         The first 3 dimensions follow that of the spatial dimensions of the fMRI surfaces/volumes in brain_timecourse_text.'); 
  disp('         Each 3D frame is set to 0 except for the vertices/voxels of the brain_mask whose correlation is computed.');
  disp(' ');
  disp('If there are multiple ROIs and multiple subjects and avg_sub_bool = 0, since we cannot have a 5D nifty volume, the output_file has to be of type .mat');
  return;
end


if(nargin < 8)
   avg_sub_bool = 0;
else
    if(ischar(avg_sub_bool))
        avg_sub_bool = str2double(avg_sub_bool);
    end
end

% read in both text files.
fid = fopen(ROI_timecourse_text, 'r');
i = 0;
while(1);
    tmp = fgetl(fid);
    if(tmp == -1)
        break
    else
        i = i + 1;
        ROIs_series{i} = tmp;
    end
end
fclose(fid);

% read in both text files
fid = fopen(brain_timecourse_text, 'r');
i = 0;
while(1);
    tmp = fgetl(fid);
    if(tmp == -1)
        break
    else
        i = i + 1;
        brain_series{i} = tmp;
    end
end
fclose(fid);

if(length(ROIs_series) ~= length(brain_series))
    error('ROI_timecourse_text not the same length as brain_timecourse_text');
end

% read ROIs_list
if(~isempty(strfind(ROIs_list, '.nii.gz')) || ~isempty(strfind(ROIs_list, '.mgz')) || ~isempty(strfind(ROIs_list, '.mgh')))
    tmp = MRIread(ROIs_list);
    ROIs_cell{1} = find(tmp.vol ~= 0);
elseif(~isempty(strfind(ROIs_list, '.label')))    
    tmp = read_label([], ROIs_list);
    ROIs_cell{1} = tmp(:, 1) + 1;
else
    fid = fopen(ROIs_list, 'r');
    i = 0;
    while(1);
        tmp = fgetl(fid);
        if(tmp == -1)
            break
        else
            i = i + 1;
            if(~isempty(strfind(tmp, '.txt')))
                ROIs_cell{i} = load(tmp);
            elseif(~isempty(strfind(tmp, '.nii.gz')) || ~isempty(strfind(tmp, '.mgz')) || ~isempty(strfind(tmp, '.mgh')))
                tmp = MRIread(tmp);
                ROIs_cell{i} = find(tmp.vol == 1);
            elseif(~isempty(strfind(tmp, '.label')))
                tmp = read_label([], tmp);
                ROIs_cell{i} = tmp(:, 1) + 1;
            else
                tmp = read_curv(tmp);
                ROIs_cell{i} = find(tmp == 1);
            end
        end
    end
    fclose(fid);
end

if(strcmp(brain_mask, 'NONE'))
    brain = [];
else
    if(~isempty(strfind(brain_mask, '.nii.gz')) || ~isempty(strfind(brain_mask, '.mgz')) || ~isempty(strfind(brain_mask, '.mgh')))
        brain = MRIread(brain_mask);
        brain = find(brain.vol(:) == 1);
    elseif(~isempty(strfind(brain_mask, '.label')))
        brain = read_label([], brain_mask);
        brain = brain(:, 1) + 1;
    else
        error(['Unable to read brain mask: ' brain_mask]);
    end
end    
        
if(strcmp(ROI_regress_list, 'NONE'))
    regress1 = 0;
else
    regress1 = 1;
    fid = fopen(ROI_regress_list, 'r');
    i = 0;
    while(1);
        tmp = fgetl(fid);
        if(tmp == -1)
            break
        else
            i = i + 1;
            regress_cell1{i} = MRIread(tmp);
        end
    end
    fclose(fid);
end

if(strcmp(brain_regress_list, 'NONE'))
    regress2 = 0;
else
    regress2 = 1;
    fid = fopen(brain_regress_list, 'r');
    i = 0;
    while(1);
        tmp = fgetl(fid);
        if(tmp == -1)
            break
        else
            i = i + 1;
            regress_cell2{i} = MRIread(tmp);
        end
    end
    fclose(fid);
end

log_file = [output_file '.log'];
delete(log_file);

% Check output: multiple ROIs and multiple subjects and avg_sub_bool = 0
if((~isempty(strfind(output_file, '.nii.gz')) || ~isempty(strfind(output_file, '.mgz')) || ~isempty(strfind(output_file, '.mgh'))))
    if(length(ROIs_cell) > 1 && length(ROIs_series) > 1 && avg_sub_bool == 0)
        error('Output cannot be of type .nii.gz / .mgz / .mgh when there are multiple ROIs, multiple subjects and avg_sub_bool = 0');
    end
end
    
    

% Compute correlation
for i = 1:length(ROIs_series)

    disp(num2str(i));
    system(['echo ' num2str(i) ' >> ' log_file]);

    C1 = textscan(ROIs_series{i}, '%s');
    C1 = C1{1};

    C2 = textscan(brain_series{i}, '%s');
    C2 = C2{1};

    for j = 1:length(C1)
        input = C1{j};
        input_series = MRIread(input);
        series1 = single(transpose(reshape(input_series.vol, size(input_series.vol, 1) * size(input_series.vol, 2) * size(input_series.vol, 3), size(input_series.vol, 4))));

        input = C2{j};
        input_series = MRIread(input);
        series2 = single(transpose(reshape(input_series.vol, size(input_series.vol, 1) * size(input_series.vol, 2) * size(input_series.vol, 3), size(input_series.vol, 4))));

        if(i == 1 && j == 1)
            if(isempty(brain))
                brain = 1:size(series2, 2);
            end
            
            if(avg_sub_bool == 1)
                corr_mat = zeros(length(ROIs_cell), length(brain));
            else
                corr_mat = zeros(length(ROIs_cell), length(brain), length(ROIs_series));
            end
        end
        
        % create series from ROIs
        t_series1 = zeros(size(series1, 1), length(ROIs_cell));
        for k = 1:length(ROIs_cell)
            t_series1(:, k) = mean(series1(:, ROIs_cell{k}), 2);
        end
        t_series2 = series2(:, brain);
        
        % regression
        if(regress1)
            regress_signal = zeros(size(series1, 1), length(regress_cell1));
            for k = 1:length(regress_cell1)
               regress_signal(:, k) = mean(series1(:, regress_cell1{k}.vol == 1), 2); 
            end
            
            % This replace the slow voxel by voxel regression using glmfit
            X = [ones(size(series1, 1), 1) regress_signal];
            pseudo_inverse = pinv(X);
            b = pseudo_inverse*t_series1;
            t_series1 = t_series1 - X*b;
        end
        
        if(regress2)
            regress_signal = zeros(size(series2, 1), length(regress_cell2));
            for k = 1:length(regress_cell2)
                regress_signal(:, k) = mean(series2(:, regress_cell2{k}.vol == 1), 2);
            end

            % This replace the slow voxel by voxel regression using glmfit
            X = [ones(size(series2, 1), 1) regress_signal];
            pseudo_inverse = pinv(X);
            b = pseudo_inverse*t_series2;
            t_series2 = t_series2 - X*b;
        end
        
        % normalize series (note that series are now of dimensions: T x N)
        t_series1 = bsxfun(@minus, t_series1, mean(t_series1, 1));
        t_series1 = bsxfun(@times, t_series1, 1./sqrt(sum(t_series1.^2, 1)));

        t_series2 = bsxfun(@minus, t_series2, mean(t_series2, 1));
        t_series2 = bsxfun(@times, t_series2, 1./sqrt(sum(t_series2.^2, 1)));
        
        % compute correlation
        sbj_corr_mat = t_series1' * t_series2;
        
        if(j == 1)
            sbj_z_mat = StableAtanh(sbj_corr_mat); % fisher-z transform
        else
            sbj_z_mat = sbj_z_mat + StableAtanh(sbj_corr_mat);
        end
    end
    sbj_z_mat = sbj_z_mat/length(C1);

    if(avg_sub_bool == 1)
        corr_mat = corr_mat + sbj_z_mat;
    else
        corr_mat(:, :, i) = tanh(sbj_z_mat);
    end
end
disp(['isnan: ' num2str(sum(isnan(corr_mat(:)))) ' out of ' num2str(numel(corr_mat))]);

if(avg_sub_bool == 1)
   corr_mat = corr_mat/length(ROIs_series);
   corr_mat = tanh(corr_mat);
end

% write out results
system(['echo Writing out results >> ' log_file]);
disp('Writing out results');



if(~isempty(strfind(output_file, '.mat')))
    save(output_file, 'corr_mat', '-v7.3');
elseif(~isempty(strfind(output_file, '.nii.gz')) || ~isempty(strfind(output_file, '.mgz')) || ~isempty(strfind(output_file, '.mgh')))
    if(length(ROIs_cell) > 1 && length(ROIs_series) > 1 && avg_sub_bool == 0)
        error('Output cannot be of type .nii.gz / .mgz / .mgh when there are multiple ROIs, multiple subjects and avg_sub_bool = 0');
    end
    
    output = input_series;
    spatial_size = size(input_series.vol);
    spatial_size = spatial_size(1:3);
    
    if(length(ROIs_cell) > 1) 
       output.vol = zeros([spatial_size length(ROIs_cell)]); 
    else
       if(avg_sub_bool == 0)
           if(length(ROIs_series) == 1) 
               output.vol = zeros(spatial_size);  
           else
               output.vol = zeros([spatial_size length(ROIs_series)]);  
           end
       else
           output.vol = zeros(spatial_size);  
       end
    end
    output.nframes = size(output.vol, 4);
    
    tmp = zeros(spatial_size);
    if(length(ROIs_cell) > 1) 
        for i = 1:length(ROIs_cell)
            tmp(brain) = squeeze(corr_mat(i, :));
            output.vol(:, :, :, i) = tmp;
        end
    else
        if(avg_sub_bool == 0)
            for i = 1:length(ROIs_series)
                tmp(brain) = squeeze(corr_mat(1, :, i));
                output.vol(:, :, :, i) = tmp;
            end
        else
            tmp(brain) = squeeze(corr_mat);
            output.vol(:, :, :, i) = tmp;
        end
        
    end
    
    MRIwrite(output, output_file);
else
    error('Does not handle output file that is not .mat, .nii.gz or .mgz or .mgh');
end

exit

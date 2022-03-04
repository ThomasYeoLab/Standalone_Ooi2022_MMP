function ComputeROIs2ROIsCorrelationWithRegression(output_file, varargin_text1, varargin_text2, ROIs1, ROIs2, regress_list1, regress_list2, all_comb_bool, avg_sub_bool)

% type "ComputeROIs2ROIsCorrelationWithRegression" for help

if(nargin == 0)
  disp('ComputeROIs2ROIsCorrelationWithRegression output_file varargin_text1 varargin_text2 ROIs1 ROIs2 regress_list1 regress_list2 all_comb_bool avg_sub_bool');
  disp(' ');
  disp('varargin_text1 and varargin_text2 are text files with each line corresponding to 1 subject. If subject has multiple runs, it still takes');
  disp('up 1 line separated by spaces. This is because we average across runs if we have multiple runs for individual subjects.'); 
  disp('For example, if varargin_text1 consists of two subjects, where subject 1 has 1 run and subject 2 has two runs, then varargin_text1 might look like:'); 
  disp('   <full_path>/subject1_run1_bold.nii.gz');
  disp('   <full_path>/subject2_run1_bold.nii.gz <full_path>/subject2_run2_bold.nii.gz');   
  disp(' ');
  disp('Passing in two lists is useful when you are computing fcMRI for example between the cerebrum and the cerebellum,');
  disp('so that varargin_text1 might consist of fMRI data in surface space, and varargin_text2 consists of fMRI data in volume space.');
  disp('If you are performing fcMRI within the cerebrum, then varargin_text1 might be the same as varargin_text2.');
  disp(' ');
  disp(' ');
  disp('ROIs1 and ROIs2 are text files with each line corresponding to an ROI. ');
  disp('Each ROI should be a full path pointing to a surface or volume of the same size as the spatial dimension of each subject fMRI data.');
  disp('Each ROI should have extension ''nii.gz'', ''mgh'', ''mgz'' or ''label''. If the extension is nii.gz, mgh or mgz, then each ROI is assumed to be a ');  
  disp('a binary mask of zeros and ones. If the extension is label, then it follows the freesurfer label format');
  disp('Note that all the file types can represent both surface and volume data, as long as the dimensions are consistent with the fMRI data.');
  disp('For example, the FreeSurfer fsaverage5 surface has 10242 vertices. Thus if a nii.gz volume has dimensions 1 x 10242 x 1, then it can be treated like a surface'); 
  disp('ROI if the input data are surface data');
  disp('fcMRI for the ROI is computed by averaging the fMRI signal within the ROI and correlation with this averaged signal is computed');
  disp(' ');
  disp('For convenience, ROIs1 and ROIs2 can also be just surfaces/volumes of type ''nii.gz'', ''mgh'' or ''mgz'' (but not of type label)');
  disp('In this case, the volumes/surfaces are assumed to be all zeros except for ''n'' INDIVIDUAL ROI voxels/vertices numbered from 1 to n');
  disp('(in other words, there are n non-zero voxels/vertices). fcMRI is performed on each vertex/voxel separately in order from 1 to n');
  disp('It should be obvious that when using this input option that one cannot specify ROIs consisting of more than 1 vertex/voxel');
  disp(' ')
  disp('For example, if we are performing fcMRI on the surface between vertices 5, 3, 7 and vertices 10, 8 on the fsaverage5 mesh with 10242 vertices.');
  disp('Then we can create the following in matlab:');
  disp('   mask1 = zeros(1, 10242); mask1([5 3 7]) = 1:3; save_mgh(mask1, ''ROI1.mgh'', eye(4));');
  disp('   mask2 = zeros(1, 10242); mask2([10 8]) = 1:2; save_mgh(mask2, ''ROI2.mgh'', eye(4));');
  disp('Then when calling the code, ROIs1 = "ROI1.mgh", ROIs2 = "ROI2.mgh"');
  disp(' ');
  disp('This option is useful when computing correlation for example between vertex 10 and the entire left fsaverage5 hemisphere.');
  disp('Then we can create the following in matlab:');
  disp('   mask1 = zeros(1, 10242); mask1(10) = 1; save_mgh(mask1, ''ROI1.mgh'', eye(4));');
  disp('   mask2 = 1:10242; save_mgh(mask2, ''ROI2.mgh'', eye(4));');
  disp('Then when calling the code, ROIs1 = "ROI1.mgh", ROIs2 = "ROI2.mgh"');
  disp('By using this option for inputing ROIs, one avoids the need to create a list of 10242 ROIs each consisting of a single vertex');
  disp(' ');
  disp(' *** Currently, both ROIs1 and ROIs2 must be lists or both ROIs1 and ROIs2 must be volumes/surfaces ***');
  disp([' *** Example ROIs based on Yeo et al. 2011 can be found ' getenv('CBIG_CODE_DIR') '/utilities/scripts/ComputeROIs2ROIsCorrelationWithRegression/Yeo2011_surface_seeds/ ***']);
  disp(['These ROIs were using the matlab utility CreateSingleVertexSurfaceROI (see generating script ' getenv('CBIG_CODE_DIR') '/utilities/scripts/ComputeROIs2ROIsCorrelationWithRegression/CreateYeo2011ROIs.csh)']);
  disp(' ');
  disp(' ');
  disp('If all_comb_bool = 1 then fcMRI is performed for all possible');
  disp('combinations of seeds provided by ROIs1 and ROIs2. So if ROIs1 consists of N ROIs, ROIs2 consists of M ROIs, we compute all N x M correlation.');
  disp('If all_comb_bool = 0 then fcMRI is performed for pairwise combinations of ROIs1 and ROIs2. In that case, the number of ROIs for ROIs1 and ROIs2');
  disp('should be the same, i.e., N = M');
  disp(' ');
  disp(' ');
  disp('regress_list1 and regress_list2 are text files of binary masks for regressing out nuisance time series from the input fMRI volumes/surface data'); 
  disp('specified in varargin_text1 and varargin_text2 respectively. Signal within each mask is averaged to become a signal to be regressed from the fMRI volume/surface data.');
  disp('If no regression is needed, then regress_list should be set to the string "NONE". The regression signals are jointly (rather than sequentially) regressed out.');
  disp('For example, in the case when we are computing fcMRI between cortex and cerebellum');
  disp('so that the varargin_text1 consists of fmri data in surface space, varargin_text2 consists of fmri data in volume space, '); 
  disp('ROIs1 consists of ROIs in surface space and ROIs2 consists of cerebellar ROIs, we might be interested in regressing out signal from the visual');
  disp('cortex adjacent to the cerebellar. In this case, regress_list2 is a text file consisting of the path to a binary mask of visual cortex adjacent to');
  disp('the cerebellum. For each of the fMRI volume specified in varargin_text2, the code will average the fMRI time course within the binary mask of the');
  disp('visual cortex and regress the average time course from the same fMRI volume. In this case, regress_list1 = "NONE" because we are not regressing anything');
  disp('from the cerebrum.');
  disp(' ');
  disp(' ');
  disp('avg_sub_bool = 1 implies correlation should be averaged across multiple subjects');  
  disp('avg_sub_bool = 0 implies correlation is not averaged across multiple subjects');
  disp(' ');
  disp(' ');
  disp('If output_file is of the type ".mat", then the resulting fcMRI correlation is saved as a matlab matrix. ');
  disp('For example, if ROIs1 consists of N ROIs, ROIs2 consists of M ROIs, all_comb_bool = 1, # subjects = S, avg_sub_bool = 0, then output is a N x M x S matrix.'); 
  disp('For example, if ROIs1 consists of N ROIs, ROIs2 consists of N ROIs, all_comb_bool = 0, # subjects = S, avg_sub_bool = 0, then output is a N x S matrix.'); 
  disp('For example, if ROIs1 consists of N ROIs, ROIs2 consists of N ROIs, all_comb_bool = 0, # subjects = S, avg_sub_bool = 1, then output is a N x 1 matrix.'); 
  disp(' ');
  disp('Output_file can also be of the type ''nii.gz'', ''mgz'', ''mgh'' if ');
  disp('    (a)  There is one subject, all_comb_bool = 1 and ROIs1, ROIs2 are passed it as single surface/volume (and not as lists).');
  disp('         In this case, output is a 4D surface/volume, where the size of the 4th dimension corresponds to the number of ROIs in ROIs1.'); 
  disp('         The first 3 dimensions follow that of the spatial dimensions of the fMRI surfaces/volumes in varargin_text2.'); 
  disp('         Each 3D frame is set to 0 except for the vertices/voxels of the ROIs2 surface/volume between 1:n whose correlation is computed.');
  disp('    (b)  There is multiple subjects, avg_sub_bool = 1, all_comb_bool = 1 and ROIs1, ROIs2 are passed it as single surface/volume (and not as lists).');
  disp('         In this case, output is a 4D surface/volume, where the size of the 4th dimension corresponds to the number of ROIs in ROIs1.'); 
  disp('         The first 3 dimensions follow that of the spatial dimensions of the fMRI surfaces/volumes in varargin_text2.'); 
  disp('         Each 3D frame is set to 0 except for the vertices/voxels of the ROIs2 surface/volume between 1:n whose correlation is computed.');
  return;
end


if(nargin < 8)
   all_comb_bool = 1;
else
    if(ischar(all_comb_bool))
        all_comb_bool = str2double(all_comb_bool);
    end
end

if(nargin < 9)
   avg_sub_bool = 0;
else
    if(ischar(avg_sub_bool))
        avg_sub_bool = str2double(avg_sub_bool);
    end
end

% read in both text files.
fid = fopen(varargin_text1, 'r');
i = 0;
while(1);
    tmp = fgetl(fid);
    if(tmp == -1)
        break
    else
        i = i + 1;
        varargin1{i} = tmp;
    end
end
fclose(fid);

% read in both text files
fid = fopen(varargin_text2, 'r');
i = 0;
while(1);
    tmp = fgetl(fid);
    if(tmp == -1)
        break
    else
        i = i + 1;
        varargin2{i} = tmp;
    end
end
fclose(fid);

if(length(varargin1) ~= length(varargin2))
    error('varargin1 not the same length as varargin2');
end

% read ROIs1
if(~isempty(strfind(ROIs1, '.nii.gz')) || ~isempty(strfind(ROIs1, '.mgz')) || ~isempty(strfind(ROIs1, '.mgh')))
    voxel_based_bool = 1;
    ROIs1_vol = MRIread(ROIs1);
    
    ROIs1_index = find(ROIs1_vol.vol ~= 0);
    if(max(ROIs1_vol.vol(ROIs1_vol.vol ~= 0)) == length(ROIs1_index))
        [Y, I] = sort(ROIs1_vol.vol(ROIs1_vol.vol ~= 0));
        ROIs1_index = ROIs1_index(I);
    end
else
    voxel_based_bool = 0;
    fid = fopen(ROIs1, 'r');
    i = 0;
    while(1);
        tmp = fgetl(fid);
        if(tmp == -1)
            break
        else
            i = i + 1;
            if(~isempty(strfind(tmp, '.txt')))
                ROIs1_cell{i} = load(tmp);
            elseif(~isempty(strfind(tmp, '.nii.gz')) || ~isempty(strfind(tmp, '.mgz')) || ~isempty(strfind(tmp, '.mgh')))
                tmp = MRIread(tmp);
                ROIs1_cell{i} = find(tmp.vol == 1);
            elseif(~isempty(strfind(tmp, '.label')))
                tmp = read_label([], tmp);
                ROIs1_cell{i} = tmp(:, 1) + 1;
            else
                tmp = read_curv(tmp);
                ROIs1_cell{i} = find(tmp == 1);
            end
        end
    end
    fclose(fid);
end

% read ROIs2
if(voxel_based_bool)
    if(isempty(strfind(ROIs2, '.nii.gz')) && ~isempty(strfind(ROIs2, '.mgz')) && ~isempty(strfind(ROIs2, '.mgh')))
       error('ROIs1 is a volumetric file but not ROIs2'); 
    end
    ROIs2_vol = MRIread(ROIs2);
    
    ROIs2_index = find(ROIs2_vol.vol ~= 0);
    if(max(ROIs2_vol.vol(ROIs2_vol.vol ~= 0)) == length(ROIs2_index))
        [Y, I] = sort(ROIs2_vol.vol(ROIs2_vol.vol ~= 0));
        ROIs2_index = ROIs2_index(I);
    end
else
    if(~isempty(strfind(ROIs2, '.nii.gz')) || ~isempty(strfind(ROIs2, '.mgz')) || ~isempty(strfind(ROIs2, '.mgh')))
        error('ROIs2 is a volumetric file but not ROIs1'); 
    end
    fid = fopen(ROIs2, 'r');
    i = 0;
    while(1);
        tmp = fgetl(fid);
        if(tmp == -1)
            break
        else
            i = i + 1;
            if(~isempty(strfind(tmp, '.txt')))
                ROIs2_cell{i} = load(tmp);
            elseif(~isempty(strfind(tmp, '.nii.gz')) || ~isempty(strfind(tmp, '.mgz')) || ~isempty(strfind(tmp, '.mgh')))
                tmp = MRIread(tmp);
                ROIs2_cell{i} = find(tmp.vol == 1);
            elseif(~isempty(strfind(tmp, '.label')))
                tmp = read_label([], tmp);
                ROIs2_cell{i} = tmp(:, 1) + 1;
            else
                tmp = read_curv(tmp);
                ROIs2_cell{i} = find(tmp == 1);
            end
        end
    end
    fclose(fid);
end

if(strcmp(regress_list1, 'NONE'))
    regress1 = 0;
else
    regress1 = 1;
    fid = fopen(regress_list1, 'r');
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

if(strcmp(regress_list2, 'NONE'))
    regress2 = 0;
else
    regress2 = 1;
    fid = fopen(regress_list2, 'r');
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

% allocate space
if(avg_sub_bool == 1)
    if(all_comb_bool)
        if(voxel_based_bool)
            corr_mat = zeros(nnz(ROIs1_vol.vol), nnz(ROIs2_vol.vol));
        else
            corr_mat = zeros(length(ROIs1_cell), length(ROIs2_cell));
        end
    else
        if(voxel_based_bool)
            if(nnz(ROIs1_vol.vol) ~= nnz(ROIs2_vol.vol))
                error('ROIs1 does not have equal number of non-zero elements as ROIs2');
            end
            corr_mat = zeros(nnz(ROIs1_vol.vol), 1);
        else
            if(length(ROIs1_cell) ~= length(ROIs2_cell))
                error('ROIs1_cell not the same length as ROIs2_cell');
            end
            corr_mat = zeros(length(ROIs1_cell), length(varargin1));
        end
    end
else
    if(all_comb_bool)
        if(voxel_based_bool)
            corr_mat = zeros(nnz(ROIs1_vol.vol), nnz(ROIs2_vol.vol), length(varargin1));
        else
            corr_mat = zeros(length(ROIs1_cell), length(ROIs2_cell), length(varargin1));
        end
    else
        if(voxel_based_bool)
            if(nnz(ROIs1_vol.vol) ~= nnz(ROIs2_vol.vol))
                error('ROIs1 does not have equal number of non-zero elements as ROIs2');
            end
            corr_mat = zeros(nnz(ROIs1_vol.vol), length(varargin1));
        else
            if(length(ROIs1_cell) ~= length(ROIs2_cell))
                error('ROIs1_cell not the same length as ROIs2_cell');
            end
            corr_mat = zeros(length(ROIs1_cell), length(varargin1));
        end
    end
end

% Compute correlation
for i = 1:length(varargin1)

    disp(num2str(i));
    system(['echo ' num2str(i) ' >> ' log_file]);

    C1 = textscan(varargin1{i}, '%s');
    C1 = C1{1};

    C2 = textscan(varargin2{i}, '%s');
    C2 = C2{1};

    for j = 1:length(C1)
        input = C1{j};
        input_series = MRIread(input);
        series1 = single(transpose(reshape(input_series.vol, size(input_series.vol, 1) * size(input_series.vol, 2) * size(input_series.vol, 3), size(input_series.vol, 4))));

        input = C2{j};
        input_series = MRIread(input);
        series2 = single(transpose(reshape(input_series.vol, size(input_series.vol, 1) * size(input_series.vol, 2) * size(input_series.vol, 3), size(input_series.vol, 4))));

        % create series from ROIs
        if(voxel_based_bool)
            t_series1 = series1(:, ROIs1_index); 
            t_series2 = series2(:, ROIs2_index);
        else
            t_series1 = zeros(size(series1, 1), length(ROIs1_cell));
            for k = 1:length(ROIs1_cell)
                t_series1(:, k) = mean(series1(:, ROIs1_cell{k}), 2);
            end

            t_series2 = zeros(size(series2, 1), length(ROIs2_cell));
            for k = 1:length(ROIs2_cell)
                t_series2(:, k) = mean(series2(:, ROIs2_cell{k}), 2);
            end
        end
        
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
            
%             for k = 1:size(t_series1, 2)
%                [b, dev, stats] = glmfit(regress_signal, t_series1(:, k));
%                t_series1(:, k) = stats.resid; 
%             end
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
            
%             for k = 1:size(t_series2, 2)
%                 [b, dev, stats] = glmfit(regress_signal, t_series2(:, k));
%                 t_series2(:, k) = stats.resid;
%             end
        end
        
        % normalize series (note that series are now of dimensions: T x N)
        t_series1 = bsxfun(@minus, t_series1, mean(t_series1, 1));
        t_series1 = bsxfun(@times, t_series1, 1./sqrt(sum(t_series1.^2, 1)));

        t_series2 = bsxfun(@minus, t_series2, mean(t_series2, 1));
        t_series2 = bsxfun(@times, t_series2, 1./sqrt(sum(t_series2.^2, 1)));
        
        % compute correlation
        if(all_comb_bool)
            sbj_corr_mat = t_series1' * t_series2;
        else
            sbj_corr_mat = transpose(sum(t_series1 .* t_series2, 1));
        end
        
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
        if(all_comb_bool)
            corr_mat(:, :, i) = tanh(sbj_z_mat);
        else
            corr_mat(:, i) = tanh(sbj_z_mat);
        end
    end
end
disp(['isnan: ' num2str(sum(isnan(corr_mat(:)))) ' out of ' num2str(numel(corr_mat))]);

if(avg_sub_bool == 1)
   corr_mat = corr_mat/length(varargin1);
   corr_mat = tanh(corr_mat);
end

% write out results
system(['echo Writing out results >> ' log_file]);
disp('Writing out results');

if(~isempty(strfind(output_file, '.mat')))
    save(output_file, 'corr_mat', '-v7.3');
elseif(~isempty(strfind(output_file, '.nii.gz')) || ~isempty(strfind(output_file, '.mgz')) || ~isempty(strfind(output_file, '.mgh')))
    if(length(varargin1) > 1 && avg_sub_bool == 0)
        error('When saving output as a volume and not averaging across subjects, cannot handle multiple subjects because unable to save a 5D volume using MRIwrite');
    end
    
    if(~voxel_based_bool || ~all_comb_bool)
        error('When saving output as a volume, requires voxel_based_bool = 1 and all_comb_bool = 1');
    end
    
    output = ROIs2_vol;
    output.vol = zeros([size(ROIs2_vol.vol) nnz(ROIs1_vol.vol)]);
    tmp = zeros(size(ROIs2_vol.vol));
    for i = 1:nnz(ROIs1_vol.vol)
        tmp(ROIs2_index) = squeeze(corr_mat(i, :, :));
        output.vol(:, :, :, i) = tmp;
    end
    MRIwrite(output, output_file);
else
    error('Does not handle output file that is not .mat, .nii.gz or .mgz or .mgh');
end

exit

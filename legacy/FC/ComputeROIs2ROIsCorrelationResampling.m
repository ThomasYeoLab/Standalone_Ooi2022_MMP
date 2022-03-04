function ComputeROIs2ROIsCorrelationResampling(output_file, varargin_text1, varargin_text2, ROIs1, ROIs2, regress_list1, regress_list2, num_samples)

% type "ComputeROIs2ROIsCorrelationResampling" for help

if(nargin == 0)
  disp('ComputeROIs2ROIsCorrelationResampling output_file varargin_text1 varargin_text2 ROIs1 ROIs2 regress_list1 regress_list2');
  disp(' ');
  disp('varargin_text1 and varargin_text2 are text files with one line corresponding to the subject.'); 
  disp('For example, varargin_text1 might look like:'); 
  disp('   <full_path>/subject_run1_bold.nii.gz <full_path>/subject_run2_bold.nii.gz');   
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
  disp(' ');
  disp('fcMRI is performed for all possible');
  disp('combinations of seeds provided by ROIs1 and ROIs2. So if ROIs1 consists of N ROIs, ROIs2 consists of M ROIs, we compute all N x M correlation.');
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
  disp('The output_file must be of the type ".mat". The resulting fcMRI correlation is saved as a matlab matrix N x M x # resamples. ');
  disp(' ');
  return;
end

rand('twister', 5489);

if(nargin < 8)
   num_samples = 1000;
else
    if(ischar(num_samples))
        num_samples = str2double(num_samples);
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

% read ROIs2
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
corr_mat = zeros(length(ROIs1_cell), length(ROIs2_cell), num_samples);

% Compute correlation
if(length(varargin1) > 1)
   error('Only allow for one subject');
end

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
   
    T = size(t_series1, 1);
    for i = 1:num_samples 
	t1 = t_series1(ceil(T.*rand(T, 1)), :);
	t2 = t_series2(ceil(T.*rand(T, 1)), :);

	% normalize series (note that series are now of dimensions: T x N)
	t1 = bsxfun(@minus, t1, mean(t1, 1));
	t1 = bsxfun(@times, t1, 1./sqrt(sum(t1.^2, 1)));

	t2 = bsxfun(@minus, t2, mean(t2, 1));
	t2 = bsxfun(@times, t2, 1./sqrt(sum(t2.^2, 1)));
	
	% compute correlation
	sbj_corr_mat = t_series1' * t_series2;
	
	if(j == 1)
	    corr_mat(:, :, i) = StableAtanh(sbj_corr_mat); % fisher-z transform
	else
	    corr_mat(:, :, i) = corr_mat(:, :, i) + StableAtanh(sbj_corr_mat);
	end
    end
end
corr_mat = corr_mat/length(C1);
corr_mat = tanh(corr_mat);
disp(['isnan: ' num2str(sum(isnan(corr_mat(:)))) ' out of ' num2str(numel(corr_mat))]);


% write out results
system(['echo Writing out results >> ' log_file]);
disp('Writing out results');

if(~isempty(strfind(output_file, '.mat')))
    save(output_file, 'corr_mat', '-v7.3');
else
    error('only save out as mat');
end

exit

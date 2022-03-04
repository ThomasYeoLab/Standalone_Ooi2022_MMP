function ComputeROIs2ROIsCorrelation(output_file, varargin_text1, varargin_text2, ROIs1, ROIs2, all_comb_bool)

% ComputeROIs2ROIsCorrelation(output_file, varargin_text1, varargin_text2, ROIs1, ROIs2, all_comb_bool)

if(nargin < 6)
   all_comb_bool = 1;
else
    if(ischar(all_comb_bool))
        all_comb_bool = str2double(all_comb_bool);
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
        elseif(~isempty(strfind(tmp, '.nii.gz')))
            tmp = MRIread(tmp);
            ROIs1_cell{i} = find(tmp.vol == 1);
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
        elseif(~isempty(strfind(tmp, '.nii.gz')))
            tmp = MRIread(tmp);
            ROIs2_cell{i} = find(tmp.vol == 1);
        else
            tmp = read_curv(tmp);
            ROIs2_cell{i} = find(tmp == 1);
        end
    end
end
fclose(fid);

log_file = [output_file '.log'];
delete(log_file);

% allocate space
if(all_comb_bool)
    corr_mat = zeros(length(ROIs1_cell), length(ROIs2_cell), length(varargin1));
else
    if(length(ROIs1_cell) ~= length(ROIs2_cell))
        error('ROIs1_cell not the same length as ROIs2_cell');
    end
    corr_mat = zeros(length(ROIs1_cell), length(varargin1));
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
        t_series1 = zeros(size(series1, 1), length(ROIs1_cell));
        for k = 1:length(ROIs1_cell)
            t_series1(:, k) = mean(series1(:, ROIs1_cell{k}), 2);
        end
        
        t_series2 = zeros(size(series2, 1), length(ROIs2_cell));
        for k = 1:length(ROIs2_cell)
            t_series2(:, k) = mean(series2(:, ROIs2_cell{k}), 2);
        end
        
        % normalize series (note that series are now of dimensions: T x N)
        t_series1 = bsxfun(@minus, t_series1, mean(t_series1, 1));
        t_series1 = bsxfun(@times, t_series1, 1./sqrt(sum(t_series1.^2, 1)));

        t_series2 = bsxfun(@minus, t_series2, mean(t_series2, 1));
        t_series2 = bsxfun(@times, t_series2, 1./sqrt(sum(t_series2.^2, 1)));
        
        % comput correlation
        if(all_comb_bool)
            sbj_corr_mat = t_series1' * t_series2;
        else
            sbj_corr_mat = sum(t_series1 .* t_series2, 1);
        end
        
        if(j == 1)
            sbj_z_mat = StableAtanh(sbj_corr_mat); % fisher-z transform
        else
            sbj_z_mat = sbj_z_mat + StableAtanh(sbj_corr_mat);
        end
    end
    sbj_z_mat = sbj_z_mat/length(C1);


    if(all_comb_bool)
        corr_mat(:, :, i) = tanh(sbj_z_mat);
    else
        corr_mat(:, i) = tanh(sbj_z_mat);
    end
end
disp(['isnan: ' num2str(sum(isnan(corr_mat(:)))) ' out of ' num2str(numel(corr_mat))]);

% write out results
system(['echo Writing out results >> ' log_file]);
disp('Writing out results');
save(output_file, 'corr_mat', '-v7.3');
exit

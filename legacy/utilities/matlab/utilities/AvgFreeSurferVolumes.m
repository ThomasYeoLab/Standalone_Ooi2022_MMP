function AvgFreeSurferVolumes(varargin_text, output_file)

% This function is the duplication of CBIG_AvgFreeSurferVolumes.m. This function will be removed later
fprintf('WARNING: This function is the duplication of CBIG_AvgFreeSurferVolumes.m. This function will be removed later.\n');

% read in files
fid = fopen(varargin_text, 'r');
i = 0;
while(1);
   tmp = fscanf(fid, '%s\n', 1);
   if(isempty(tmp))
       break
   else
       i = i + 1;
       varargin{i} = tmp;
   end
end
fclose(fid);

tic
for i = 1:length(varargin)
  disp([num2str(i) ': ' varargin{i}]);
    x = MRIread(varargin{i});
    if(sum(isnan(x.vol(:))) > 0)
        disp(['Warning: ' varargin{i} ' contains ' num2str(sum(isnan(x.vol(:)))) ' isnan .']);
    end
    
    if(i == 1)
        output = x;
    else
        output.vol = output.vol + x.vol;
    end
end
toc
clear x;
output.vol = output.vol/length(varargin);
MRIwrite(output, output_file);
%exit

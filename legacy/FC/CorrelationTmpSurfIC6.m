function CorrelationTmpSurfIC6(seed_file, output, varargin)

seed = MRIread(seed_file);
index = find(seed.vol ~= 0);

fmri = [];
for i = 1:length(varargin)
  fmri1 = MRIread(varargin{i});
  fmri = [fmri reshape(fmri1.vol, numel(seed.vol), size(fmri1.vol, 4))]; 
end
seed_signal = mean(fmri(index, :), 1);

corr_val = corr(seed_signal', fmri');

write_curv(output, corr_val, int32(81920));
exit

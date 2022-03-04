function output = SimpleCluster

load rest_state.mat

mask = MRIread('graymask4mm_sym.nii.gz');
mask_index = find(mask.vol(:) ~= 0);


tic, clusters_results = direcClus(series, 40, 0, 10); toc
[Y, cidx] = max(clusters_results.r, [], 2); 

output = mask;
output.vol(mask_index) = cidx;
output = output.vol;
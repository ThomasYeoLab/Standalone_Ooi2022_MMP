function fsl_preprocess_plot_slicer(output_name)

curr_im = imread('sla');

for frame = {'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'}
    tmp = imread(['sl' frame{1}]);
    curr_im = cat(2, curr_im, tmp);
end

imwrite(curr_im, output_name);
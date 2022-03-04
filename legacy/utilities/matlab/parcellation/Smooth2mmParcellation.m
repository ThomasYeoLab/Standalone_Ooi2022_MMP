function Smooth2mmParcellation(input_file, output_file, exit_flag)

% sd is in terms of number of voxels.

sd = 1;
win_size = sd*5;

x = MRIread(input_file);
if(mod(win_size, 2) == 0)
   win_size = win_size + 1; 
end

[a, hostname] = system('hostname -d');
if(strfind(hostname, 'nmr.mgh'))
    mask = MRIread('/autofs/space/pgolland_002/users/ythomas/randy/code/FC/ROI/graymask2mm_wosubcort_sym_cons.nii.gz');
else
    mask = MRIread('/ncf/cnl/20/users/ythomas/code/FC/ROI/graymask2mm_wosubcort_sym_cons.nii.gz');
end

out = mask;
if(length(size(x.vol)) == 3)
    num_labels = max(x.vol(:));
    vol = zeros([size(x.vol) num_labels]);
    for i = 1:num_labels
        vol(:, :, :, i) = smooth3(double(x.vol == i), 'gaussian', win_size, sd);
    end
else
    vol = zeros(size(x.vol));
    for i = 1:size(vol, 4)
        vol(:, :, :, i) = smooth3(squeeze(x.vol(:, :, :, i)), 'gaussian', win_size, sd);
    end
end
    
[tmp, tmp2] = max(vol, [], 4);
out.vol = reshape(tmp2, size(out.vol));
out.vol(sum(vol, 4)  == 0) = 0;


out.vol(mask.vol == 0) = 0;
MRIwrite(out, output_file);

if(exit_flag)
     exit
end

function TransformFSaverage5SurfFiles2FS2mm(lh_input_file, rh_input_file, output_file, FS_mask)

if(~strcmp(FS_mask, 'NONE'))
    mask = MRIread(FS_mask);
end
lh_surf = MRIread(lh_input_file); lh_surf = reshape(lh_surf.vol, numel(lh_surf.vol(:, :, :, 1)), size(lh_surf.vol, 4));
rh_surf = MRIread(rh_input_file); rh_surf = reshape(rh_surf.vol, numel(rh_surf.vol(:, :, :, 1)), size(rh_surf.vol, 4));

index = MRIread('/autofs/cluster/nexus/12/users/ythomas/data/GSP/scripts/CorrespondenceFreeSurferVolSurfSpace/coord_vol2surf/1000sub.FSL_MNI152.1mm.full_vertex_map.500.fsaverage5.nii.gz');
pos_index = find(index.vol > 0);
neg_index = find(index.vol < 0);
if(sum(index.vol == 0) > 0)
   error('There are index with 0 values'); 
end

output = index;
output.vol = zeros([size(index.vol) size(lh_surf, 2)]);
dummy = zeros(size(index.vol));
for i = 1:size(lh_surf, 2)
    dummy(pos_index) = lh_surf(index.vol(pos_index), i);
    dummy(neg_index) = rh_surf(abs(index.vol(neg_index)), i);
    
    if(~strcmp(FS_mask, 'NONE'))
        dummy(mask.vol == 0) = 0;
    end
    output.vol(:, :, :, i) = dummy;
end
MRIwrite(output, output_file);

exit
function combined_corr = GrabBothHemiWithinBetweenNetworksCorr(lh2lh, rh2rh, lh2rh, lh_roi_txt, rh_roi_txt, region_list)

if(~exist('region_list', 'var'))
   region_list = {'Vis', 'SomMot', 'DorsAttn', 'SalVentAttn', 'Limbic', 'Cont', 'Default'};
end

count = 0;
fid = fopen(lh_roi_txt, 'r');
while(1)
   tmp = fgetl(fid);
   if(tmp == -1)
      break; 
   else
      count = count + 1;
      rois{count} = tmp;
   end
end

fid = fopen(rh_roi_txt, 'r');
while(1)
   tmp = fgetl(fid);
   if(tmp == -1)
      break; 
   else
      count = count + 1;
      rois{count} = tmp;
   end
end

rh2lh = zeros([size(lh2rh, 2) size(lh2rh, 1) size(lh2rh, 3)]);
for i = 1:size(lh2rh, 3)
   rh2lh(:, :, i) = transpose(squeeze(lh2rh(:, :, i))); 
end

full_corr = [lh2lh lh2rh; rh2lh rh2rh];
combined_corr = zeros([length(region_list) length(region_list) size(lh2rh, 3)]);
for i = 1:length(region_list)
   for j = 1:length(region_list)
       
       indexi = [];
       for k = 1:length(rois)
           if(strfind(rois{k}, region_list{i}))
               indexi = [indexi; k];
           end
       end
       
       indexj = [];
       for k = 1:length(rois)
           if(strfind(rois{k}, region_list{j}))
               indexj = [indexj; k];
           end
       end
       
       tmp_corr = full_corr(indexi, indexj, :);
       
       if(i == j)
           [a, b] = meshgrid(1:size(tmp_corr, 1), 1:size(tmp_corr, 2));
           
           for k = 1:size(tmp_corr, 3)
               tmp = squeeze(tmp_corr(:, :, k));
               combined_corr(i, j, k) = mean(tmp(a < b));
           end
       else
           for k = 1:size(tmp_corr, 3)
               tmp = squeeze(tmp_corr(:, :, k));
               combined_corr(i, j, k) = mean(tmp(:));
           end
       end
   end
end




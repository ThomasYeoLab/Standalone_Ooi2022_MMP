function [lh2lh_corr, rh2rh_corr, lh2rh_corr] = GrabWithinBetweenNetworksCorr(lh2lh, rh2rh, lh2rh, lh_roi_txt, rh_roi_txt, region_list)

if(~exist('region_list', 'var'))
   region_list = {'Vis', 'SomMot', 'DorsAttn', 'SalVentAttn', 'Limbic', 'Cont', 'Default'};
end


fid = fopen(lh_roi_txt, 'r');
count = 0;
while(1)
   tmp = fgetl(fid);
   if(tmp == -1)
      break; 
   else
      count = count + 1;
      lh_rois{count} = tmp;
   end
end

fid = fopen(rh_roi_txt, 'r');
count = 0;
while(1)
   tmp = fgetl(fid);
   if(tmp == -1)
      break; 
   else
      count = count + 1;
      rh_rois{count} = tmp;
   end
end

lh2lh_corr = zeros([length(region_list) length(region_list) size(lh2lh, 3)]);
for i = 1:length(region_list)
   for j = 1:length(region_list)
       
       indexi = [];
       for k = 1:length(lh_rois)
           if(strfind(lh_rois{k}, region_list{i}))
               indexi = [indexi; k];
           end
       end
       
       indexj = [];
       for k = 1:length(lh_rois)
           if(strfind(lh_rois{k}, region_list{j}))
               indexj = [indexj; k];
           end
       end
       
       tmp_corr = lh2lh(indexi, indexj, :);
       
       if(i == j)
           [a, b] = meshgrid(1:size(tmp_corr, 1), 1:size(tmp_corr, 2));
           
           for k = 1:size(tmp_corr, 3)
               tmp = squeeze(tmp_corr(:, :, k));
               lh2lh_corr(i, j, k) = mean(tmp(a < b));
           end
       else
           for k = 1:size(tmp_corr, 3)
               tmp = squeeze(tmp_corr(:, :, k));
               lh2lh_corr(i, j, k) = mean(tmp(:));
           end
       end
   end
end

rh2rh_corr = zeros([length(region_list) length(region_list) size(rh2rh, 3)]);
for i = 1:length(region_list)
   for j = 1:length(region_list)
       
       indexi = [];
       for k = 1:length(rh_rois)
           if(strfind(rh_rois{k}, region_list{i}))
               indexi = [indexi; k];
           end
       end
       
       indexj = [];
       for k = 1:length(rh_rois)
           if(strfind(rh_rois{k}, region_list{j}))
               indexj = [indexj; k];
           end
       end
       
       tmp_corr = rh2rh(indexi, indexj, :);
       
       if(i == j)
           [a, b] = meshgrid(1:size(tmp_corr, 1), 1:size(tmp_corr, 2));
           
           for k = 1:size(tmp_corr, 3)
               tmp = squeeze(tmp_corr(:, :, k));
               rh2rh_corr(i, j, k) = mean(tmp(a < b));
           end
       else
           for k = 1:size(tmp_corr, 3)
               tmp = squeeze(tmp_corr(:, :, k));
               rh2rh_corr(i, j, k) = mean(tmp(:));
           end
       end
   end
end

lh2rh_corr = zeros([length(region_list) length(region_list) size(lh2rh, 3)]);
for i = 1:length(region_list)
   for j = 1:length(region_list)
       
       indexi = [];
       for k = 1:length(lh_rois)
           if(strfind(lh_rois{k}, region_list{i}))
               indexi = [indexi; k];
           end
       end
       
       indexj = [];
       for k = 1:length(rh_rois)
           if(strfind(lh_rois{k}, region_list{j}))
               indexj = [indexj; k];
           end
       end
       
       tmp_corr = lh2rh(indexi, indexj, :);
       for k = 1:size(tmp_corr, 3)
           tmp = squeeze(tmp_corr(:, :, k));
           lh2rh_corr(i, j, k) = mean(tmp(:));
       end
   end
end





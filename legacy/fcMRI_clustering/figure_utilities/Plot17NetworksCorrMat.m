function Plot17NetworksCorrMat(fig_num, corr_mat, xhemi, yhemi, clow, chigh, color_map)

if(~exist('color_map', 'var'))
    cyan_black = [linspace(0, 0, 32)' linspace(255, 0, 32)' linspace(255, 0, 32)'];
    black_red   = [linspace(0, 255, 32)' linspace(0, 0, 32)' linspace(0, 0, 32)'];
    color_map = [cyan_black; black_red]/255;
end

if(~exist('clow', 'var'))
    clow = -1;
end

if(~exist('chigh', 'var'))
    chigh = 1;
end

if(~exist('xhemi', 'var'))
    xhemi = 'lh';
end

if(~exist('yhemi', 'var'))
    yhemi = 'lh';
end

xlabel_txt = fullfile(getenv('CODE_DIR'), 'fcMRI_clustering', '1000subjects_reference', [xhemi '.Yeo2011_17Networks_N1000.split_components.txt']);
ylabel_txt = fullfile(getenv('CODE_DIR'), 'fcMRI_clustering', '1000subjects_reference', [yhemi '.Yeo2011_17Networks_N1000.split_components.txt']);

Xlabels = textread(xlabel_txt, '%s');
for i = 1:length(Xlabels)
   label = basename(Xlabels{i});
   Xlabels{i} = label(15:end-6);
   Xlabels{i} = strrep(Xlabels{i}, '_', '\_');
end

Ylabels = textread(ylabel_txt, '%s');
for i = 1:length(Ylabels)
   label = basename(Ylabels{i});
   Ylabels{i} = label(15:end-6);
end

h = figure(fig_num); gpos = get(h, 'Position');
gpos(3) = 1150; gpos(4) = 1300; set(h, 'Position', gpos);
disp(['max val: ' num2str(max(corr_mat(:))) ', min val: ' num2str(min(corr_mat(:)))]);
imagesc(corr_mat, [clow chigh]);

set(gca, 'Position', [0.050    0.030    0.7750    0.7750]);
set(gca, 'YTick', 1:length(Ylabels));
set(gca, 'YTickLabel', Ylabels);
set(gca, 'YAxisLocation', 'right');
set(gca, 'YDir', 'normal');
set(gca, 'XTick', []);
text(1:length(Xlabels), zeros(1, length(Xlabels))+length(Ylabels)+0.75, Xlabels, 'HorizontalAlignment','left', 'rotation', 90, 'FontSize', 10, 'FontName', 'San Serif')
set(gca, 'FontSize', 10);
set(gca, 'FontName', 'San Serif');
colormap(color_map); 
colorbar('Location', 'SouthOutside');



function Plot17NetworksSqCorrMat(fig_num, corr_mat, clow, chigh, color_map)

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

h = figure(fig_num); gpos = get(h, 'Position');
gpos(3) = 1150; gpos(4) = 1150; set(h, 'Position', gpos);
imagesc(corr_mat, [clow chigh]);
set(gca, 'YDir', 'normal');
colormap(color_map); 
axis square; axis off;

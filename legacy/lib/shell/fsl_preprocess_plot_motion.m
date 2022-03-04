function fsl_preprocess_plot_motion

load mc.par

% MCFLIRT estimated rotations (radians)
figure; hold on;
plot(mc(:, 1), 'r');
plot(mc(:, 2), 'g');
plot(mc(:, 3), 'b');
legend('x', 'y', 'z', 'Location', 'Best');
set(gca, 'FontSize', 14);
title('MCFLIRT estimated rotations (radians)');
print(gcf, 'mc_rot.jpeg', '-djpeg');

% MCFLIRT estimated translations (mm)
figure; hold on;

plot(mc(:, 4), 'r');
plot(mc(:, 5), 'g');
plot(mc(:, 6), 'b');
legend('x', 'y', 'z', 'Location', 'Best');
set(gca, 'FontSize', 14);
title('MCFLIRT estimated translations (mm)');
print(gcf, 'mc_trans.jpeg', '-djpeg');

% MCFLIRT estimated mean displacement (mm)
figure; hold on;


load mc_abs.rms
plot(mc_abs, 'r');

load mc_rel.rms
plot(mc_rel, 'g');

legend('absolute', 'relative', 'Location', 'Best');
set(gca, 'FontSize', 14);
title('MCFLIRT estimated mean displacement (mm)');
print(gcf, 'mc_disp.jpeg', '-djpeg');

close all

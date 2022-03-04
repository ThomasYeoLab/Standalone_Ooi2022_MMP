classdef test_CBIG_DrawSurfaceDataAsAnnotation < matlab.unittest.TestCase
% Written by Nanbo Sun, Zhang Shaoshi and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test_fsaverage_pos(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'draw_surface_data_as_annotation', 'CBIG_DrawSurfaceDataAsAnnotation');
            mkdir(fullfile(cur_dir, 'output'))
            % load input
            x = MRIread(fullfile(CBIG_CODE_DIR, 'utilities', 'matlab', 'figure_utilities', 'draw_surface_data_as_annotation', 'sample', 'sample_vol.nii.gz'));
            surface_template = 'fsaverage';
            [lh_data, rh_data] = CBIG_ProjectMNI2fsaverage_Ants(x, surface_template);
            abs_path_to_lh_ref_annot = fullfile(getenv('FREESURFER_HOME'), 'subjects', surface_template, 'label', 'lh.aparc.annot');
            abs_path_to_rh_ref_annot = fullfile(getenv('FREESURFER_HOME'), 'subjects', surface_template, 'label', 'rh.aparc.annot');
            ref_medialwall_label = 0;
            abs_path_to_output_dir = fullfile(cur_dir, 'output');
            label = 'component';
            colorscheme = 'parula';
            discretization_res = 28;
            min_thresh = 1e-5;
            max_thresh = 5e-5;
            CBIG_DrawSurfaceDataAsAnnotation(lh_data, rh_data, ...
                abs_path_to_lh_ref_annot, abs_path_to_rh_ref_annot, ref_medialwall_label, ...
                surface_template, abs_path_to_output_dir, label, ...
                colorscheme, discretization_res, min_thresh, max_thresh)
            % compare the output with correct output
            ref_img = imread(fullfile(cur_dir, 'ref_output', 'component.grid.png'));
            img = imread(fullfile(cur_dir, 'output', 'component.grid.png'));
            ref_img_size = size(ref_img);
            img_resize = imresize(img, ref_img_size(1:2));
            ref_img_gray = rgb2gray(ref_img);
            img_resize_gray = rgb2gray(img_resize);
            cor = corr(double(ref_img_gray(:)), double(img_resize_gray(:)));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo DrawSurfaceDataAsAnnotation, fsaverage_pos...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', 'component.grid.png'), fullfile(cur_dir, 'ref_output', 'component.grid.png'))
                % delete output
                rmdir(fullfile(cur_dir, 'output'), 's')
            else              
                message1 = ['This unit test use CBIG_ProjectMNI2fsaverage_Ants to generate' ...
                 ' input, please check it at first'];
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % delete output
                rmdir(fullfile(cur_dir, 'output'), 's')
            end
        end
        
        function test_fsaverage_pos_neg(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'draw_surface_data_as_annotation', 'CBIG_DrawSurfaceDataAsAnnotation');
            mkdir(fullfile(cur_dir, 'output'))
            % load input
            x = MRIread(fullfile(cur_dir, 'input', 'factor3.nii.gz'));
            surface_template = 'fsaverage';
            [lh_data, rh_data] = CBIG_ProjectMNI2fsaverage_Ants(x, surface_template);
            abs_path_to_lh_ref_annot = fullfile(getenv('FREESURFER_HOME'), 'subjects', surface_template, 'label', 'lh.aparc.annot');
            abs_path_to_rh_ref_annot = fullfile(getenv('FREESURFER_HOME'), 'subjects', surface_template, 'label', 'rh.aparc.annot');
            ref_medialwall_label = 0;
            abs_path_to_output_dir = fullfile(cur_dir, 'output');
            label = 'component';
            colorscheme = 'jet';
            discretization_res = 28;
            min_thresh = 0;
            max_thresh = 0.38;
            CBIG_DrawSurfaceDataAsAnnotation(lh_data, rh_data, ...
                abs_path_to_lh_ref_annot, abs_path_to_rh_ref_annot, ref_medialwall_label, ...
                surface_template, abs_path_to_output_dir, label, ...
                colorscheme, discretization_res, min_thresh, max_thresh)
            % compare the output with correct output
            ref_img = imread(fullfile(cur_dir, 'ref_output', 'component.grid.tmp.png'));
            img = imread(fullfile(cur_dir, 'output', 'tmp', 'component.grid.tmp.png'));
            ref_img_size = size(ref_img);
            img_resize = imresize(img, ref_img_size(1:2));
            ref_img_gray = rgb2gray(ref_img);
            img_resize_gray = rgb2gray(img_resize);
            cor = corr(double(ref_img_gray(:)), double(img_resize_gray(:)));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo DrawSurfaceDataAsAnnotation, fsaverage_pos_neg...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', 'tmp', 'component.grid.tmp.png'), fullfile(cur_dir, 'ref_output', 'component.grid.tmp.png'))
                % delete output
                rmdir(fullfile(cur_dir, 'output'), 's')
            else             
                message1 = ['This unit test use CBIG_ProjectMNI2fsaverage_Ants to generate' ...
                 ' input, please check it at first'];
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % delete output
                rmdir(fullfile(cur_dir, 'output'), 's')
            end
        end
    end
end
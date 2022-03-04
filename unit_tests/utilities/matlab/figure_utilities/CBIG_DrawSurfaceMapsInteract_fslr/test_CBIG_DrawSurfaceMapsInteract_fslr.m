classdef test_CBIG_DrawSurfaceMapsInteract_fslr < matlab.unittest.TestCase
% Written by Zhang Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test_metric_data_32k_inflated(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'CBIG_DrawSurfaceMapsInteract_fslr');
            mkdir(fullfile(cur_dir, 'output'))
            % generate input and run the function
            mri = MRIread(fullfile(cur_dir, 'input', 'topic1.nii.gz'));
            fs_mesh_name = 'fsaverage';
            [lh_data, rh_data] = CBIG_ProjectMNI2fsaverage_Ants(mri, fs_mesh_name);
            [lh_fsLR_32k_data,rh_fsLR_32k_data,lh_fsLR_164k_data,rh_fsLR_164k_data] = ...
            CBIG_project_fsaverage2fsLR(lh_data, rh_data, fs_mesh_name, 'metric', fullfile(cur_dir, 'tmp'));
            fslr_mesh_name = 'fs_LR_32k';
            surf_type = 'inflated';
            min_thresh = 7.5e-6;
            max_thresh = 1.5e-5;
            out_name = 'topic1_fslr32k_inflated.png';
            CBIG_DrawSurfaceMapsInteract_fslr(lh_fsLR_32k_data, rh_fsLR_32k_data, fslr_mesh_name, surf_type, min_thresh, max_thresh);
            set(gcf, 'PaperPositionMode', 'auto')
            print(gcf, '-dpng', fullfile(cur_dir, 'output', out_name))
            close all
            % compare the output with correct output
            ref_img = imread(fullfile(cur_dir, 'ref_output', out_name));
            img = imread(fullfile(cur_dir, 'output', out_name));
            ref_img_size = size(ref_img);
            img_resize = imresize(img, ref_img_size(1:2));
            ref_img_gray = rgb2gray(ref_img);
            img_resize_gray = rgb2gray(img_resize);
            cor = corr(double(ref_img_gray(:)), double(img_resize_gray(:)));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for DrawSurfaceMapsInteract_fslr, metric_data_32k_inflated...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', out_name), fullfile(cur_dir, 'ref_output', out_name))
                delete(fullfile(cur_dir, 'output', out_name))
            else             
                message1 = ['This unit test use CBIG_ProjectMNI2fsaverage_Ants and CBIG_project_fsaverage2fsLR to generate' ...
                 ' input, please check it at first'];
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % remove the output directory
                delete(fullfile(cur_dir, 'output', out_name))
            end
        end
        
        function test_metric_data_32k_veryinflated(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'CBIG_DrawSurfaceMapsInteract_fslr');
            mkdir(fullfile(cur_dir, 'output'))
            % generate input and run the function
            mri = MRIread(fullfile(cur_dir, 'input', 'topic1.nii.gz'));
            fs_mesh_name = 'fsaverage';
            [lh_data, rh_data] = CBIG_ProjectMNI2fsaverage_Ants(mri, fs_mesh_name);
            [lh_fsLR_32k_data,rh_fsLR_32k_data,lh_fsLR_164k_data,rh_fsLR_164k_data] = ...
            CBIG_project_fsaverage2fsLR(lh_data, rh_data, fs_mesh_name, 'metric', fullfile(cur_dir, 'tmp'));
            fslr_mesh_name = 'fs_LR_32k';
            surf_type = 'very_inflated';
            min_thresh = 7.5e-6;
            max_thresh = 1.5e-5;
            out_name = 'topic1_fslr32k_veryinflated.png';
            CBIG_DrawSurfaceMapsInteract_fslr(lh_fsLR_32k_data, rh_fsLR_32k_data, fslr_mesh_name, surf_type, min_thresh, max_thresh);
            set(gcf, 'PaperPositionMode', 'auto')
            print(gcf, '-dpng', fullfile(cur_dir, 'output', out_name))
            close all
            % compare the output with correct output
            ref_img = imread(fullfile(cur_dir, 'ref_output', out_name));
            img = imread(fullfile(cur_dir, 'output', out_name));
            ref_img_size = size(ref_img);
            img_resize = imresize(img, ref_img_size(1:2));
            ref_img_gray = rgb2gray(ref_img);
            img_resize_gray = rgb2gray(img_resize);
            cor = corr(double(ref_img_gray(:)), double(img_resize_gray(:)));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for DrawSurfaceMapsInteract_fslr, metric_data_32k_veryInflated...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', out_name), fullfile(cur_dir, 'ref_output', out_name))
                delete(fullfile(cur_dir, 'output', out_name))
            else            
                message1 = ['This unit test use CBIG_ProjectMNI2fsaverage_Ants and CBIG_project_fsaverage2fsLR to generate' ...
                ' input, please check it at first'];
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % remove the output directory
                delete(fullfile(cur_dir, 'output', out_name))
            end
        end
        
        function test_metric_data_32k_midthickness_orig(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'CBIG_DrawSurfaceMapsInteract_fslr');
            mkdir(fullfile(cur_dir, 'output'))
            % generate input and run the function
            mri = MRIread(fullfile(cur_dir, 'input', 'topic1.nii.gz'));
            fs_mesh_name = 'fsaverage';
            [lh_data, rh_data] = CBIG_ProjectMNI2fsaverage_Ants(mri, fs_mesh_name);
            [lh_fsLR_32k_data,rh_fsLR_32k_data,lh_fsLR_164k_data,rh_fsLR_164k_data] = ...
            CBIG_project_fsaverage2fsLR(lh_data, rh_data, fs_mesh_name, 'metric', fullfile(cur_dir, 'tmp'));
            fslr_mesh_name = 'fs_LR_32k';
            surf_type = 'midthickness_orig';
            min_thresh = 7.5e-6;
            max_thresh = 1.5e-5;
            out_name = 'topic1_fslr32k_midthickness_orig.png';
            CBIG_DrawSurfaceMapsInteract_fslr(lh_fsLR_32k_data, rh_fsLR_32k_data, fslr_mesh_name, surf_type, min_thresh, max_thresh);
            set(gcf, 'PaperPositionMode', 'auto')
            print(gcf, '-dpng', fullfile(cur_dir, 'output', out_name))
            close all
            % compare the output with correct output
            ref_img = imread(fullfile(cur_dir, 'ref_output', out_name));
            img = imread(fullfile(cur_dir, 'output', out_name));
            ref_img_size = size(ref_img);
            img_resize = imresize(img, ref_img_size(1:2));
            ref_img_gray = rgb2gray(ref_img);
            img_resize_gray = rgb2gray(img_resize);
            cor = corr(double(ref_img_gray(:)), double(img_resize_gray(:)));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for DrawSurfaceMapsInteract_fslr, metric_data_32k_midthickness_orig...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', out_name), fullfile(cur_dir, 'ref_output', out_name))
                delete(fullfile(cur_dir, 'output', out_name))
            else            
                message1 = ['This unit test use CBIG_ProjectMNI2fsaverage_Ants and CBIG_project_fsaverage2fsLR to generate' ...
                ' input, please check it at first'];
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % remove the output directory
                delete(fullfile(cur_dir, 'output', out_name))
            end
        end
        
        function test_label_data(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'CBIG_DrawSurfaceMapsInteract_fslr');
            mkdir(fullfile(cur_dir, 'output'))
            % generate input and run the function
            FREESURFER_HOME = getenv('FREESURFER_HOME');
            fs_mesh_name = 'fsaverage';
            lh_annot = fullfile(FREESURFER_HOME, 'subjects', fs_mesh_name, 'label', 'lh.Yeo2011_17Networks_N1000.annot');
            rh_annot = fullfile(FREESURFER_HOME, 'subjects', fs_mesh_name, 'label', 'rh.Yeo2011_17Networks_N1000.annot');
            [lh_labels, lh_colortable] = CBIG_read_annotation(lh_annot);
            [rh_labels, rh_colortable] = CBIG_read_annotation(rh_annot);
            [lh_fsLR_32k_data,rh_fsLR_32k_data,lh_fsLR_164k_data,rh_fsLR_164k_data] = ...
            CBIG_project_fsaverage2fsLR(lh_labels, rh_labels, 'fsaverage', 'label', fullfile(cur_dir, 'tmp'));
            mesh_name = 'fs_LR_32k';
            surf_type = 'very_inflated';
            min_thresh = min(lh_fsLR_32k_data);
            max_thresh = max(lh_fsLR_32k_data);
            colors = lh_colortable.table(:, 1:3);
            out_name = '17Networks_fslr32k.png';
            CBIG_DrawSurfaceMapsInteract_fslr(lh_fsLR_32k_data, rh_fsLR_32k_data, mesh_name, surf_type, min_thresh, max_thresh, colors);
            set(gcf, 'PaperPositionMode', 'auto')
            print(gcf, '-dpng', fullfile(cur_dir, 'output', out_name))
            close all
            % compare the output with correct output
            ref_img = imread(fullfile(cur_dir, 'ref_output', out_name));
            img = imread(fullfile(cur_dir, 'output', out_name));
            ref_img_size = size(ref_img);
            img_resize = imresize(img, ref_img_size(1:2));
            ref_img_gray = rgb2gray(ref_img);
            img_resize_gray = rgb2gray(img_resize);
            cor = corr(double(ref_img_gray(:)), double(img_resize_gray(:)));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for DrawSurfaceMapsInteract_fslr, label_data...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', out_name), fullfile(cur_dir, 'ref_output', out_name))
                delete(fullfile(cur_dir, 'output', out_name))
            else            
                message1 = ['This unit test use CBIG_read_annotation and CBIG_project_fsaverage2fsLR to generate' ...
                ' input, please check it at first'];
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % remove the output directory
                delete(fullfile(cur_dir, 'output', out_name))
            end
        end
    end
end
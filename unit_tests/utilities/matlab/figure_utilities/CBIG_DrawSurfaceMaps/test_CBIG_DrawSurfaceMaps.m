classdef test_CBIG_DrawSurfaceMaps < matlab.unittest.TestCase
% Written by Nanbo Sun, Zhang Shaoshi and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test_fsaverage_mesh(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));           
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'CBIG_DrawSurfaceMaps');
            mkdir(fullfile(cur_dir, 'output'));
            % generate input and run the function
            mri = MRIread(fullfile(cur_dir, 'input', 'topic1.nii.gz'));
            mesh_name = 'fsaverage';
            [lh_data, rh_data] = CBIG_ProjectMNI2fsaverage_Ants(mri, mesh_name);
            surf_type = 'inflated';
            min_thresh = 7.5e-6;
            max_thresh = 1.5e-5;
            out_name = 'topic1_fsaverage.png';
            h = CBIG_DrawSurfaceMaps(lh_data, rh_data, mesh_name, surf_type, min_thresh, max_thresh);
            set(h, 'PaperPositionMode', 'auto')
            print(h, '-dpng', fullfile(cur_dir, 'output', out_name))
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
                disp('Replacing unit test reference results fo DrawSurfaceMaps, fsaverage_mesh...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', out_name), fullfile(cur_dir, 'ref_output', out_name))
                delete(fullfile(cur_dir, 'output', out_name))
            else
                message1 = 'This unit test use CBIG_ProjectMNI2fsaverage_Ants to generate input, please check it at first';
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % remove the output directory
                delete(fullfile(cur_dir, 'output', out_name))
            end
        end
        
        function test_fsaverage6_mesh(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));           
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'CBIG_DrawSurfaceMaps');
            mkdir(fullfile(cur_dir, 'output'));
            % generate input and run the function
            mri = MRIread(fullfile(cur_dir, 'input/topic1.nii.gz'));
            mesh_name = 'fsaverage6';
            [lh_data, rh_data] = CBIG_ProjectMNI2fsaverage_Ants(mri, mesh_name);
            surf_type = 'sphere';
            min_thresh = 7.5e-6;
            max_thresh = 1.5e-5;
            out_name = 'topic1_fsaverage6.png';
            h = CBIG_DrawSurfaceMaps(lh_data, rh_data, mesh_name, surf_type, min_thresh, max_thresh);
            set(h, 'PaperPositionMode', 'auto')
            print(h, '-dpng', fullfile(cur_dir, 'output', out_name))
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
                disp('Replacing unit test reference results fo DrawSurfaceMaps, fsaverage6_mesh...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', out_name), fullfile(cur_dir, 'ref_output', out_name))
                delete(fullfile(cur_dir, 'output', out_name))
            else           
                message1 = 'This unit test use CBIG_ProjectMNI2fsaverage_Ants to generate input, please check it at first';
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % remove the output directory
                delete(fullfile(cur_dir, 'output', out_name))
            end
        end
        
        function test_fsaverage5_mesh(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));           
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'CBIG_DrawSurfaceMaps');
            mkdir(fullfile(cur_dir, 'output'));
            % generate input and run the function
            mri = MRIread(fullfile(cur_dir, 'input', 'topic1.nii.gz'));
            mesh_name = 'fsaverage5';
            [lh_data, rh_data] = CBIG_ProjectMNI2fsaverage_Ants(mri, mesh_name);
            surf_type = 'white';
            min_thresh = 7.5e-6;
            max_thresh = 1.5e-5;
            out_name = 'topic1_fsaverage5.png';
            h = CBIG_DrawSurfaceMaps(lh_data, rh_data, mesh_name, surf_type, min_thresh, max_thresh);
            set(h, 'PaperPositionMode', 'auto')
            print(h, '-dpng', fullfile(cur_dir, 'output', out_name))
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
                disp('Replacing unit test reference results fo DrawSurfaceMaps, fsaverage5_mesh...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', out_name), fullfile(cur_dir, 'ref_output', out_name))
                delete(fullfile(cur_dir, 'output', out_name))
            else             
                message1 = 'This unit test use CBIG_ProjectMNI2fsaverage_Ants to generate input, please check it at first';
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);               
                assert(cor >= 0.95, [message2 message1])
                % remove the output directory
                delete(fullfile(cur_dir, 'output', out_name))
            end
        end
        
        function test_parcellation_input(testCase)
            % create output folder
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));           
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'figure_utilities', 'CBIG_DrawSurfaceMaps');
            mkdir(fullfile(cur_dir, 'output'));
            % generate input and run the function
            FREESURFER_HOME = getenv('FREESURFER_HOME');
            mesh_name = 'fsaverage';
            surf_type = 'inflated';
            lh_annot = fullfile(FREESURFER_HOME, 'subjects', mesh_name, 'label', 'lh.Yeo2011_17Networks_N1000.annot');
            rh_annot = fullfile(FREESURFER_HOME, 'subjects', mesh_name, 'label', 'rh.Yeo2011_17Networks_N1000.annot');
            [lh_labels, lh_colortable] = CBIG_read_annotation(lh_annot);
            [rh_labels, rh_colortable] = CBIG_read_annotation(rh_annot);
            out_name = '17Networks_parcellation.png';
            h = CBIG_DrawSurfaceMaps(lh_labels, rh_labels, mesh_name, surf_type, ...
                min([lh_labels; rh_labels]), max([lh_labels; rh_labels]), lh_colortable.table(:, 1:3));
            set(h, 'PaperPositionMode', 'auto')
            print(h, '-dpng', fullfile(cur_dir, 'output', out_name))
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
                disp('Replacing unit test reference results fo DrawSurfaceMaps, parcellation...')
                disp(['Correlation:' num2str(cor)]);
                copyfile(fullfile(cur_dir, 'output', out_name), fullfile(cur_dir, 'ref_output', out_name))
                delete(fullfile(cur_dir, 'output', out_name))
            else            
                message1 = 'This unit test use CBIG_read_annotation to generate input, please check it at first';
                message2 = sprintf('correlation between image and reference: %f \nCheck the images in %s \n', ...
                    cor, cur_dir);
                assert(cor >= 0.95, [message2 message1])
                % remove the output directory
                delete([cur_dir '/output/' out_name])
            end
        end
    end
end
classdef test_TrisurfMeshData < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function infTest(testCase)
            
            % get the current output
            file_env = getenv('CBIG_CODE_DIR');
            replace_unit_test = load(fullfile(file_env, 'unit_tests', 'replace_unittest_flag'));
            file_path = fullfile(file_env, 'unit_tests', 'external_packages', ...
                'SD', 'SDv1.5.1-svn593', 'AnalysisTools', 'TrisurfMeshData');
            input_dir = fullfile(file_path, 'input');
            output_dir = fullfile(file_path, 'output');
            ref_dir = fullfile(file_path, 'ref_output');
            mkdir(output_dir);
            
            load(fullfile(input_dir, 'TrisurfMeshData_Test.mat'));
            yeo_7network_fs5 = load(fullfile(file_env, 'stable_projects', ...
                'brain_parcellation', 'Yeo2011_fcMRI_clustering', ...
                '1000subjects_reference', '1000subjects_clusters007_ref.mat'));           
            new_figure = uint8(zeros(240, 320));
            TrisurfMeshData(meshM_inflated_rh, yeo_7network_fs5.rh_labels, new_figure);
            shading flat;
            axis off;
            set(gcf, 'PaperPositionMode', 'auto')
            print(gcf, '-dpng', fullfile(output_dir, 'TrisurfMesh_Temp_inf.png'));
            close all
                      
            % process ref image
            ref_img = imread(fullfile(ref_dir,'TrisurfMeshData_Output_inf.png'));
            img = imread(fullfile(output_dir, 'TrisurfMesh_Temp_inf.png'));
            ref_img_size = size(ref_img);
            img_resize = imresize(img,ref_img_size(1:2));
            ref_img_gray = rgb2gray(ref_img);
            img_resize_gray = rgb2gray(img_resize);
            cor = CBIG_corr(double(ref_img_gray(:)),double(img_resize_gray(:)));
            
            % replace unit test if flag is 1
            if replace_unit_test
                disp("Replacing unit test for MARS_TrisurfMeshData, infTest");
                % display differences
                disp(['Correlation between new and old image is ' num2str(cor) ] );            
                
                % save and load new output file
                copyfile(fullfile(output_dir, 'TrisurfMesh_Temp_inf.png'), fullfile(ref_dir,'TrisurfMeshData_Output_inf.png'));
                img = imread(fullfile(output_dir, 'TrisurfMesh_Temp_inf.png'));
                ref_img_size = size(ref_img);
                img_resize = imresize(img,ref_img_size(1:2));
                ref_img_gray = rgb2gray(ref_img);
                img_resize_gray = rgb2gray(img_resize);
                cor = CBIG_corr(double(ref_img_gray(:)),double(img_resize_gray(:)));
            end

            % compare the current output with expected output
            message1 = sprintf('(correlation between ref and image) result off by %f \n', cor);
            message2 = sprintf('Check the images in %s \n', file_path);
            assert(cor>=0.95, [message1 message2])
            
            rmdir(fullfile(file_path, 'output'),'s')
             
        end
        
        function sphTest(testCase)
            
            % get the current output
            file_env = getenv('CBIG_CODE_DIR');
            replace_unit_test = load(fullfile(file_env, 'unit_tests', 'replace_unittest_flag'));
            file_path = fullfile(file_env, 'unit_tests', 'external_packages', ...
                'SD', 'SDv1.5.1-svn593', 'AnalysisTools', 'TrisurfMeshData');
            input_dir = fullfile(file_path, 'input');
            output_dir = fullfile(file_path, 'output');
            ref_dir = fullfile(file_path, 'ref_output');
            mkdir(output_dir);
            
            load(fullfile(input_dir, 'TrisurfMeshData_Test.mat'));
            yeo_7network_fs5 = load(fullfile(file_env, 'stable_projects', ...
                'brain_parcellation', 'Yeo2011_fcMRI_clustering', ...
                '1000subjects_reference', '1000subjects_clusters007_ref.mat'));           
            new_figure = uint8(zeros(240, 320));
            TrisurfMeshData(meshM_sphere_lh, yeo_7network_fs5.lh_labels, new_figure);
            shading flat;
            axis off;
            set(gcf, 'PaperPositionMode', 'auto')
            print(gcf, '-dpng', fullfile(output_dir, 'TrisurfMesh_Temp_sph.png'));
            close all
            
            % process ref image
            ref_img = imread(fullfile(ref_dir, 'TrisurfMeshData_Output_sph.png'));
            img = imread(fullfile(output_dir, 'TrisurfMesh_Temp_sph.png'));
            ref_img_size = size(ref_img);
            img_resize = imresize(img,ref_img_size(1:2));
            ref_img_gray = rgb2gray(ref_img);
            img_resize_gray = rgb2gray(img_resize);
            cor = CBIG_corr(double(ref_img_gray(:)),double(img_resize_gray(:)));
            
            % replace unit test if flag is 1
            if replace_unit_test
                disp("Replacing unit test for MARS_TrisurfMeshData, sphTest");
                % display differences
                disp(['Correlation between new and old image is ' num2str(cor) ] );            
                
                % save and load new output file
                copyfile(fullfile(output_dir, 'TrisurfMesh_Temp_sph.png'), fullfile(ref_dir,'TrisurfMeshData_Output_sph.png'));
                img = imread(fullfile(output_dir, 'TrisurfMesh_Temp_sph.png'));
                ref_img_size = size(ref_img);
                img_resize = imresize(img,ref_img_size(1:2));
                ref_img_gray = rgb2gray(ref_img);
                img_resize_gray = rgb2gray(img_resize);
                cor = CBIG_corr(double(ref_img_gray(:)),double(img_resize_gray(:)));
            end

            % compare the current output with expected output
            message1 = sprintf('(correlation between ref and image) result off by %f \n', cor);
            message2 = sprintf('Check the images in %s \n', file_path);
            assert(cor>=0.95, [message1 message2])
            
            rmdir(fullfile(file_path, 'output'),'s')
             
        end
    end
end

classdef test_CBIG_ComputeNeighborhood < matlab.unittest.TestCase
%
% Target function:
%                 neighborhood_cell=CBIG_ComputeNeighborhood(hemi, mesh_file, radius, surf_type)
%
% Case design:
%                 Case 1 = compute lh neighborhood on 'inflated'
%                 'fsaverage5' surface, with 'radius' 5
%
%                 Case 2 = compute lh neighborhood on 'sphere'
%                 'fsaverage5' surface, with 'radius' 3
%
%                 Case 3 = compute rh neighborhood on 'inflated'
%                 'fsaverage5' surface, with 'radius' 5
%
%                 Case 4 = compute rh neighborhood on 'white'
%                 'fsaverage5' surface, with 'radius' 3
%
%                 ('fsaverage6' and 'fsaverage7' are not tested because they
%                 take too long to run)
%
% Written by Yang Qing, Zhang Shaoshi and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test_LH_fs5_inflated_r5_Case(testCase)
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            UnitTestDir = fullfile(CBIG_CODE_DIR, 'unit_tests');
            FolderStructure = fullfile('utilities', 'matlab', 'surf', 'CBIG_ComputeNeighborhood');
            
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, ...
                'output', 'LH_fs5_inflated_r5_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);            
            
            % parameter setting
            hemi = 'lh';
            mesh_file = 'fsaverage5';
            radius = '5';
            surf_type = 'inflated';
            
            % generate new neighborhood cell
            cd(OutputDir); % function will automatically save result in working dir, so first cd to OutputDir
            new_neighborhood_cell = CBIG_ComputeNeighborhood(hemi, mesh_file, radius, surf_type);
            
            for i = 1: 10242 % to save space, ref result is converted to int32; so here also convert new result
                new_neighborhood_cell{i} = int32(new_neighborhood_cell{i});
            end
            
            % check and replace result
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ComputeNeighborhood, test_LH_fs5_inflated_r5_Case...');
                ref_neighborhood_cell = new_neighborhood_cell;
                save(fullfile(ReferenceDir, 'ref_neighborhood_cell_lh_fs5_inflated_r5.mat'), 'ref_neighborhood_cell');
            else
                % load reference result
                load(fullfile(ReferenceDir, 'ref_neighborhood_cell_lh_fs5_inflated_r5.mat')); % load in: ref_neighborhood_cell
                assert(isequaln(new_neighborhood_cell, ref_neighborhood_cell), ...
                    'result neighborhood_cell is different!');
            
                % remove intermediate output data (IMPORTANT)
                rmdir(OutputDir, 's');
            end
        
        end        
        
        
        function test_LH_fs5_sphere_r3_Case(testCase)
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            UnitTestDir = fullfile(CBIG_CODE_DIR, 'unit_tests');
            FolderStructure = fullfile('utilities', 'matlab', 'surf', 'CBIG_ComputeNeighborhood');
            
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, ...
                'output', 'LH_fs6_sphere_r2_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);            
            
            % parameter setting
            hemi = 'lh';
            mesh_file = 'fsaverage5';
            radius = '3';
            surf_type = 'sphere';
            
            % generate new neighborhood cell
            cd(OutputDir); % function will automatically save result in working dir, so first cd to OutputDir
            new_neighborhood_cell = CBIG_ComputeNeighborhood(hemi, mesh_file, radius, surf_type);
            
            for i = 1: 10242 % to save space, ref result is converted to int32; so here also convert new result
                new_neighborhood_cell{i} = int32(new_neighborhood_cell{i});
            end
            
            % check and replace result
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ComputeNeighborhood, test_LH_fs5_shpere_r3_Case...');
                ref_neighborhood_cell = new_neighborhood_cell;
                save(fullfile(ReferenceDir, 'ref_neighborhood_cell_lh_fs5_sphere_r3.mat'), 'ref_neighborhood_cell');
            else
                % load reference result
                load(fullfile(ReferenceDir, 'ref_neighborhood_cell_lh_fs5_sphere_r3.mat')); % load in: ref_neighborhood_cell                
                assert(isequaln(new_neighborhood_cell, ref_neighborhood_cell), ...
                    'result neighborhood_cell is different!');
            
                % remove intermediate output data (IMPORTANT)
                rmdir(OutputDir, 's');
            end
        
        end        
        
        
        function test_RH_fs5_inflated_r5_Case(testCase)
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            UnitTestDir = fullfile(CBIG_CODE_DIR, 'unit_tests');
            FolderStructure = fullfile('utilities', 'matlab', 'surf', 'CBIG_ComputeNeighborhood');
            
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, ...
                'output', 'RH_fs5_inflated_r5_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);            
            
            % parameter setting
            hemi = 'rh';
            mesh_file = 'fsaverage5';
            radius = '5';
            surf_type = 'inflated';
            
            % generate new neighborhood cell
            cd(OutputDir); % function will automatically save result in working dir, so first cd to OutputDir
            new_neighborhood_cell = CBIG_ComputeNeighborhood(hemi, mesh_file, radius, surf_type);
            
            for i = 1: 10242 % to save space, ref result is converted to int32; so here also convert new result
                new_neighborhood_cell{i} = int32(new_neighborhood_cell{i});
            end
            
            % check and replace result
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ComputeNeighborhood, test_RH_fs5_inflated_r5_Case...');
                ref_neighborhood_cell = new_neighborhood_cell;
                save(fullfile(ReferenceDir, 'ref_neighborhood_cell_rh_fs5_inflated_r5.mat'), 'ref_neighborhood_cell');
            else
                % load reference result
                load(fullfile(ReferenceDir, 'ref_neighborhood_cell_rh_fs5_inflated_r5.mat')); % load in: ref_neighborhood_cell                
                assert(isequaln(new_neighborhood_cell, ref_neighborhood_cell), ...
                    'result neighborhood_cell is different!');
            
                % remove intermediate output data (IMPORTANT)
                rmdir(OutputDir, 's');
            end
        
        end       
        
        
        function test_RH_fs5_white_r3_Case(testCase)
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            UnitTestDir = fullfile(CBIG_CODE_DIR, 'unit_tests');
            FolderStructure = fullfile('utilities', 'matlab', 'surf', 'CBIG_ComputeNeighborhood');
            
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, ...
                'output', 'RH_fs7_white_r1_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);
            
            
            % parameter setting
            hemi = 'rh';
            mesh_file = 'fsaverage5';
            radius = '3';
            surf_type = 'white';
            
            % generate new neighborhood cell
            cd(OutputDir); % function will automatically save result in working dir, so first cd to OutputDir
            new_neighborhood_cell = CBIG_ComputeNeighborhood(hemi, mesh_file, radius, surf_type);
            
            for i = 1: 10242 % to save space, ref result is converted to int32; so here also convert new result
                new_neighborhood_cell{i} = int32(new_neighborhood_cell{i});
            end
            
            % check and replace result
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ComputeNeighborhood, test_RH_fs5_white_r3_Case...');
                ref_neighborhood_cell = new_neighborhood_cell;
                save(fullfile(ReferenceDir, 'ref_neighborhood_cell_rh_fs5_white_r3.mat'), 'ref_neighborhood_cell');
            else
                % load reference result
                load(fullfile(ReferenceDir, 'ref_neighborhood_cell_rh_fs5_white_r3.mat')); % load in: ref_neighborhood_cell                
                assert(isequaln(new_neighborhood_cell, ref_neighborhood_cell), ...
                    'result neighborhood_cell is different!');
            
                % remove intermediate output data (IMPORTANT)
                rmdir(OutputDir, 's');
            end
        
        end
        
    end
end

classdef test_CBIG_ComputeNormalVectorsCaret < matlab.unittest.TestCase
%
% Target function:
%                 surface_normals = CBIG_ComputeNormalVectorsCaret(mesh, avg_neighbor_bool)
%
% Case design:
%                 Case 1 = Compute normal vectors for each vertex in "lh" 
%                 fsaverage5 mesh; the normals are NOT smoothed
%
%                 Case 2 = Compute normal vectors for each vertex in "rh" 
%                 fsaverage5 mesh; the normals are smoothed
%
% Written by Yang Qing, Zhang Shaoshi and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


    methods (Test)
        function test_lh_NonAvg_Case(testCase)
           
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            UnitTestDir = fullfile(CBIG_CODE_DIR, 'unit_tests');
            FolderStructure = fullfile('utilities', 'matlab', 'surf', 'CBIG_ComputeNormalVectorsCaret');
            
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
                   
            % load reference result
            load(fullfile(ReferenceDir, 'ref_surface_normals_lh_NonAvg.mat')); % load in ref_surface_normals

            % load input surface mesh data
            load(fullfile(UnitTestDir, 'external_packages', 'SD', 'SDv1.5.1-svn593', 'BasicTools', ...
                'MARS_computeLogOdds', 'input', 'lh_fs5_MARS_sbjMesh.mat')); % load in lh fsaverage5 mesh: lh
            
            % parameter setting
            avg_neighbor_bool = 0;
            
            % generate new results
            surface_normals = CBIG_ComputeNormalVectorsCaret(lh, avg_neighbor_bool);
            
            % check and replace surface_normals
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ComputeNormalVectorsCaret, lh_NonAvg_Case...');
                disp(['Total error: ' num2str(sum(sum(abs(surface_normals - ref_surface_normals))))]);
                ref_surface_normals = surface_normals;
                save(fullfile(ReferenceDir, 'ref_surface_normals_lh_NonAvg.mat'), 'ref_surface_normals');              
            else
                assert(isequal(size(surface_normals), size(ref_surface_normals)), ...
                    'result surface_normals is different')

                assert(all(all(abs(surface_normals - ref_surface_normals) < 1e-12)), ...
                    sprintf('surface_normals result off by %f (sum absolute difference)',...
                    sum(sum(abs(surface_normals - ref_surface_normals)))));
            end
        
        end
    end
    
    methods (Test)
        function test_rh_Avg_Case(testCase)
            
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            UnitTestDir = fullfile(CBIG_CODE_DIR, 'unit_tests');
            FolderStructure = fullfile('utilities', 'matlab', 'surf', 'CBIG_ComputeNormalVectorsCaret');
            
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
                   
            % load reference result
            load(fullfile(ReferenceDir, 'ref_surface_normals_rh_Avg.mat')); % load in ref_surface_normals

            % load input surface mesh data
            load(fullfile(UnitTestDir, 'external_packages', 'SD', 'SDv1.5.1-svn593', 'BasicTools', ...
                'MARS_computeLogOdds', 'input', 'rh_fs5_MARS_sbjMesh.mat')); % load in lh fsaverage5 mesh: rh
            
            % parameter setting
            avg_neighbor_bool = 1;
            
            % generate new results
            surface_normals = CBIG_ComputeNormalVectorsCaret(rh, avg_neighbor_bool);
            
            % check and replace surface_normals
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ComputeNormalVectorsCaret, rh_Avg_Case...');
                disp(['Total error: ' num2str(sum(sum(abs(surface_normals - ref_surface_normals))))]);
                ref_surface_normals = surface_normals;
                save(fullfile(ReferenceDir, 'ref_surface_normals_rh_Avg.mat'), 'ref_surface_normals');              
            else            
                assert(isequal(size(surface_normals), size(ref_surface_normals)), ...
                    'result surface_normals is different')

                assert(all(all(abs(surface_normals - ref_surface_normals) < 1e-12)), ...
                    sprintf('surface_normals result off by %f (sum absolute difference)',...
                    sum(sum(abs(surface_normals - ref_surface_normals)))));
            end
        end
    end
    
end

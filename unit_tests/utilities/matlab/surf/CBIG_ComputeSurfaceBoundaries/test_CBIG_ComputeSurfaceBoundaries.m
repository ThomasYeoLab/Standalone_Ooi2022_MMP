classdef test_CBIG_ComputeSurfaceBoundaries < matlab.unittest.TestCase
%
% Target function:
%                 BoundaryVec = CBIG_ComputeSurfaceBoundaries(mesh, labels)
%
% Case design:
%                 Case 1 = Compute two-vertex thick boundary from labels in
%                 "lh" fsaverage5 mesh
%
%                 Case 2 = Compute two-vertex thick boundary from labels in
%                 "rh" fsaverage5 mesh
%
% Written by Yang Qing, Zhang Shaoshi and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


    methods (Test)
        function test_lh_Case(testCase)
            
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            UnitTestDir = fullfile(CBIG_CODE_DIR, 'unit_tests');
            FolderStructure = fullfile('utilities', 'matlab', 'surf', 'CBIG_ComputeSurfaceBoundaries');
            
            InputDir = fullfile(UnitTestDir, FolderStructure, 'input');
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
                   
            % load reference result
            load(fullfile(ReferenceDir, 'ref_BoundaryVec_lh.mat')); % load in ref_BoundaryVec

            % load input surface mesh data
            load(fullfile(UnitTestDir, 'external_packages', 'SD', 'SDv1.5.1-svn593', 'BasicTools', ...
                'MARS_computeLogOdds', 'input', 'lh_fs5_MARS_sbjMesh.mat')); % load in lh fsaverage5 mesh: lh
            % load input parcellation labels
            load(fullfile(InputDir, 'lh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % lh_labels
            
            % compute new result
            BoundaryVec = CBIG_ComputeSurfaceBoundaries(lh, lh_labels);
            
            % check boundaryVec
            diff = sum(ref_BoundaryVec ~= BoundaryVec);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ComputeSurfaceBoundaries, lh_Case...');
                disp(['Difference: ' num2str(diff)]);
                ref_BoundaryVec = BoundaryVec;
                save(fullfile(ReferenceDir, 'ref_BoundaryVec_lh.mat'), 'ref_BoundaryVec');
            else
                assert(diff == 0, sprintf('BoundaryVec result off by %d vertices',diff));
            end
        end
    end
    
    methods (Test)
        function test_rh_Case(testCase)
            
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            UnitTestDir = fullfile(CBIG_CODE_DIR, 'unit_tests');
            FolderStructure = fullfile('utilities', 'matlab', 'surf', 'CBIG_ComputeSurfaceBoundaries');
            
            InputDir = fullfile(UnitTestDir, FolderStructure, 'input');
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
                   
            % load reference result
            load(fullfile(ReferenceDir, 'ref_BoundaryVec_rh.mat')); % load in ref_BoundaryVec

            % load input surface mesh data
            load(fullfile(UnitTestDir, 'external_packages', 'SD', 'SDv1.5.1-svn593', 'BasicTools', ...
                'MARS_computeLogOdds', 'input', 'rh_fs5_MARS_sbjMesh.mat')); % load in lh fsaverage5 mesh: rh
            % load input parcellation labels
            load(fullfile(InputDir, 'rh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % rh_labels
            
            % compute new result
            BoundaryVec = CBIG_ComputeSurfaceBoundaries(rh, rh_labels);
            
            % check boundaryVec
            diff = sum(ref_BoundaryVec ~= BoundaryVec);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ComputeSurfaceBoundaries, rh_Case...');
                disp(['Difference: ' num2str(diff)]);
                ref_BoundaryVec = BoundaryVec;
                save(fullfile(ReferenceDir, 'ref_BoundaryVec_rh.mat'), 'ref_BoundaryVec');
            else            
                assert(diff == 0, sprintf('BoundaryVec result off by %d vertices',diff));
            end
        end
    end
    
end

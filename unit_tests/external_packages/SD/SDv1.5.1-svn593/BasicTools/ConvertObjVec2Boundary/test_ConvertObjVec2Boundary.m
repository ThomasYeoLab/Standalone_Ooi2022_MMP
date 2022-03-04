classdef test_ConvertObjVec2Boundary < matlab.unittest.TestCase
%
% Target function:
%                 [boundaryVec] = ConvertObjVec2Boundary(MARS_sbjMesh, objVec)
%
% Case design:
%                 Case 1 = Compute boundary for the input object in "lh" 
%                 fsaverage5 mesh
%
%                 Case 2 = Compute boundary for the input object in "lh" 
%                 fsaverage5 mesh
%
% Written by Yang Qing and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


    methods (Test)
        function test_LH_Case(testCase)
            
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'ConvertObjVec2Boundary');
                   
            % load reference result
            load(fullfile(ref_dir, 'ref_output', 'ref_boundaryVec_lh.mat')); % load in ref_BoundaryVec

            % load input surface mesh data
            % load in lh fsaverage5 mesh: lh
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_computeLogOdds', 'input', 'lh_fs5_MARS_sbjMesh.mat'));
            
            % create input object
            % (this function only takes value 1 as the object, other values
            % will not be considered)
            objVec = (lh.MARS_label == 1); 
                        
            % compute new result
            boundaryVec = ConvertObjVec2Boundary(lh, objVec);
            
            % check boundaryVec
            diff = sum(ref_boundaryVec ~= boundaryVec);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_ConvertObjVec2Boundary, test_LH_Case...');
                disp(['Total error: ' num2str(diff)]);
                ref_boundaryVec = boundaryVec;
                save(fullfile(ref_dir, 'ref_output', 'ref_boundaryVec_lh.mat'), 'ref_boundaryVec');
            else
                assert(diff == 0, sprintf('BoundaryVec result off by %d vertices',diff));
            end
        end
        
        function test_RH_Case(testCase)
            
            % path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'ConvertObjVec2Boundary');
                   
            % load reference result
            load(fullfile(ref_dir, 'ref_output', 'ref_boundaryVec_rh.mat')); % load in ref_BoundaryVec

            % load input surface mesh data
            % load in lh fsaverage5 mesh: rh
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_computeLogOdds', 'input', 'rh_fs5_MARS_sbjMesh.mat'));
            
            % create input object
            % (this function only takes value 1 as the object, other values
            % will not be considered)
            objVec = (rh.MARS_label == 1); 
                        
            % compute new result
            boundaryVec = ConvertObjVec2Boundary(rh, objVec);
            
            % check boundaryVec
            diff = sum(ref_boundaryVec ~= boundaryVec);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_ConvertObjVec2Boundary, test_RH_Case...');
                disp(['Total error: ' num2str(diff)]);
                ref_boundaryVec = boundaryVec;
                save(fullfile(ref_dir, 'ref_output', 'ref_boundaryVec_rh.mat'), 'ref_boundaryVec');
            else
                assert(diff == 0, sprintf('BoundaryVec result off by %d vertices',diff));
            end
        end
    end
    
end

          
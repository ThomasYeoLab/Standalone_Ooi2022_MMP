classdef test_read_curv < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testLeftHemisphere(testCase)
            %load ref output
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'read_curv');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'));
            % input arguments
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'lh';
            params.SUBJECT = 'fsaverage6';
            params.data_filename_cell = {'sulc', 'curv'};
            
            for i = 1:length(params.data_filename_cell)                
                newResult(i,:) = read_curv(...
                    [params.SUBJECTS_DIR '/' params.SUBJECT '/surf/' params.hemi '.' params.data_filename_cell{i}]);   
            end
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_read_curv, testLeftHemisphere...');
                if ~isequal(size(newResult) , size(expectedResult))
                    disp('fields of the output structure are different');
                end
                abserror = abs(newResult - expectedResult);
                disp(['Total error : ' num2str(sum(sum(abserror)))]);
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'), 'expectedResult'); 
            else    
                assert(isequal(size(newResult) , size(expectedResult)), 'size of output is different')
                assert(all(all(abs(newResult - expectedResult) < 1e-6)), ...
                    sprintf('output off by %f', sum(sum(abs(newResult - expectedResult)))));
            end
        end
        
        function testRightHemisphere(testCase)
            %load ref output
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'read_curv');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'));
            % input arguments
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'rh';
            params.SUBJECT = 'fsaverage';
            params.data_filename_cell = {'sulc', 'curv'};
            for i = 1:length(params.data_filename_cell)                
                newResult(i,:) = read_curv(...
                    [params.SUBJECTS_DIR '/' params.SUBJECT '/surf/' params.hemi '.' params.data_filename_cell{i}]);   
            end
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_read_curv, testRightHemisphere...');
                if ~isequal(size(newResult) , size(expectedResult))
                    disp('fields of the output structure are different');
                end
                abserror = abs(newResult - expectedResult);
                disp(['Total error : ' num2str(sum(sum(abserror)))]);
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult'); 
            else    
                assert(isequal(size(newResult) , size(expectedResult)), 'size of output is different')
                assert(all(all(abs(newResult - expectedResult) < 1e-6)), ...
                    sprintf('output off by %f', sum(sum(abs(newResult - expectedResult)))));
            end
     
        end
    end

end
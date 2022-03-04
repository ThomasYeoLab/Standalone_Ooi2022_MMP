classdef test_fread3 < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testLeftHemisphere(testCase)
            % input arguments
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'fread3');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'));
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'lh';
            params.SUBJECT = 'fsaverage6';            
            params.data_filename_cell = {'sulc', 'curv'};

            fname = fullfile(params.SUBJECTS_DIR, params.SUBJECT, 'surf', strcat(params.hemi, '.', ...
                params.data_filename_cell{1}));
            fid = fopen(fname, 'rb', 'b') ;
            newResult = fread3(fid);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_fread3, testLeftHemisphere...');
                disp(['Old result is ' num2str(expectedResult)]);
                disp(['New result is ' num2str(newResult)]);
                abserror = abs(expectedResult - newResult);
                disp(['Absolute error is ' num2str(abserror)]);
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'), 'expectedResult');
            else
                assert(isequal(newResult , expectedResult), 'output is different')
            end
        end
        
        function testRightHemisphere(testCase)
            % input arguments
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'fread3');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'));
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'rh';
            params.SUBJECT = 'fsaverage6';            
            params.data_filename_cell = {'sulc', 'curv'};
            
            fname = fullfile(params.SUBJECTS_DIR, params.SUBJECT, 'surf', strcat(params.hemi, '.', ...
                params.data_filename_cell{1}));
            fid = fopen(fname, 'rb', 'b') ;
            newResult = fread3(fid) ;
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_fread3, testRightHemisphere...');
                disp(['Old result is ' num2str(expectedResult)]);
                disp(['New result is ' num2str(newResult)]);
                abserror = abs(expectedResult - newResult);
                disp(['Absolute error is ' num2str(abserror)]);
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult');
            else
                assert(isequal(newResult , expectedResult), 'output is different')
            end
 
        end
    end

end

classdef test_MARS_simpleAverageData < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        % test data as 2D matrix with sigma_sq as a number
        function normalCase(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_simpleAverageData');
            
            % get the current output using artificial data
            load(fullfile(ref_dir, 'input', 'normalCase_input.mat'));
            load(fullfile(ref_dir, 'input', 'meshM.mat'));
            ads = MARS_simpleAverageData(meshM,data,0);
            load(fullfile(ref_dir, 'ref_output', 'normalCase_output.mat'));

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_simpleAverageData, normalCase...');
                abserror = abs(ads - ad);
                disp(['Total error (ad): ' num2str(sum(sum(abserror)))]);
                ad = ads;
                save(fullfile(ref_dir, 'ref_output', 'normalCase_output.mat'), 'ad');
            else
                % compare the current output with expected output
                assert(size(ads,1) == 1,'no. of rows must be 1')
                assert(size(ads,2) == 163842,'no. of columns must be 163842')
                assert(all(all(abs(ads-ad) < 1e-6)),sprintf('result off by %f',sum(sum(abs(ads-ad)))))
            end
        end
        
        % test data as 3D matrix with sigma_sq as a number
        function data3DCase(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_simpleAverageData');

            % get the current output using artificial data
            load(fullfile(ref_dir, 'input', 'data3DCase_input.mat'));
            load(fullfile(ref_dir, 'input', 'meshM.mat'));
            ads2 = MARS_simpleAverageData(meshM,data2,0);
            load(fullfile(ref_dir, 'ref_output', 'data3DCase_output.mat'));

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_simpleAverageData, data3DCase...');
                abserror = abs(ads2 - ad2);
                disp(['Total error (ad): ' num2str(sum(sum(sum(abserror))))]);
                ad2 = ads2;
                save(fullfile(ref_dir, 'ref_output', 'data3DCase_output.mat'), 'ad2');
            else
                % compare the current output with expected output
                assert(size(ads2,1) == 2,'no. of 1st dimension must be 3')
                assert(size(ads2,2) == 2,'no. of 2nd dimension must be 5')
                assert(size(ads2,3) == 163842,'no. of 3rd dimension must be 163842')
                assert(all(all(all(abs(ads2-ad2) < 1e-6))),sprintf('result off by %f',sum(sum(sum(abs(ads2-ad2))))))
            end
        end
        
        % test data as 2D matrix with sigma_sq as a vector
        function sigmasqCase(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_simpleAverageData');

            % get the current output using artificial data
            load(fullfile(ref_dir, 'input', 'normalCase_input.mat'));
            load(fullfile(ref_dir, 'input', 'meshM.mat'));
            sigma_sq = [0.5161 0.9294 0.6418 0.2807 0.6947];
            ads3 = MARS_simpleAverageData(meshM,data,sigma_sq);
            load(fullfile(ref_dir, 'ref_output', 'sigmasqCase_output.mat'));

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_simpleAverageData, sigmasqCase...');
                abserror = abs(ads3 - ad3);
                disp(['Total error: ' num2str(sum(sum(abserror)))]);
                ad3 = ads3;
                save(fullfile(ref_dir, 'ref_output', 'sigmasqCase_output.mat'), 'ad3');
            else
                % compare the current output with expected output
                assert(size(ads3,1) == 1,'no. of rows must be 1')
                assert(size(ads3,2) == 163842,'no. of columns must be 163842')
                assert(all(all(abs(ads3-ad3) < 1e-6)),sprintf('result off by %f',sum(sum(abs(ads3-ad3)))))
            end             
        end
        
        % test data as 3D matrix with sigma_sq as a vector
        function combineCase(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_simpleAverageData');

            % get the current output using artificial data
            load(fullfile(ref_dir, 'input', 'data3DCase_input.mat'));
            load(fullfile(ref_dir, 'input', 'meshM.mat'));
            sigma_sq = [0.5161 0.9294 0.6418 0.2807 0.6947];
            ads4 = MARS_simpleAverageData(meshM,data2,sigma_sq);
            load(fullfile(ref_dir, 'ref_output', 'combineCase_output.mat'));

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_simpleAverageData, combineCase...');
                abserror = abs(ads4 - ad4);
                disp(['Total error: ' num2str(sum(sum(sum(abserror))))]);
                ad4 = ads4;
                save(fullfile(ref_dir, 'ref_output', 'combineCase_output.mat'), 'ad4');
            else
            % compare the current output with expected output
                assert(size(ads4,1) == 2,'no. of 1st dimension must be 3')
                assert(size(ads4,2) == 2,'no. of 2nd dimension must be 5')
                assert(size(ads4,3) == 163842,'no. of 3rd dimension must be 163842')
                assert(all(all(all(abs(ads4-ad4) < 1e-6))),sprintf('result off by %f',sum(sum(sum(abs(ads4-ad4))))))
            end
        end
    end
    
end

classdef test_CBIG_corrected_resampled_ttest_kfoldCV < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function Test(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            a = [0.2,0.3;0.1,0.4;0.04,0.37;0.12,0.23];
            b = 0.5;
            cs = CBIG_corrected_resampled_ttest_kfoldCV(a,b);
            
            if replace_unittest_flag
                % replace reference result
                c = cs;
                save('ref_output/result.mat','c')
            else
                % load reference result as c
                %c = 0.0821433;
                load('ref_output/result.mat');
                
                % compare the current output with expected output
                assert(size(cs,1) == 1,'no. of rows must be 1')
                assert(size(cs,2) == 1,'no. of columns must be 1')
                assert(all(all(abs(cs-c) < 1e-6)),sprintf('result off by %f',sum(sum(abs(cs-c)))))
            end
        end

    end
    
end

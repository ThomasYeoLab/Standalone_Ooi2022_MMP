classdef test_CBIG_corrected_resampled_ttest < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function Test(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            acc = [0.2, 0.3, 0.1, 0.4, 0.04];
            portion = 1/4;
            thr = 0.5;
            p_out = CBIG_corrected_resampled_ttest(acc, portion, thr);
            
            if replace_unittest_flag
                % replace reference result
                p_ref = p_out;
                save('ref_output/result.mat','p_ref')
            else
                % load reference result as p_ref
                % p_ref = 0.040692783;
                load('ref_output/result.mat');
                % compare the current output with expected output
                assert(size(p_out,1) == 1,'no. of rows must be 1')
                assert(size(p_out,2) == 1,'no. of columns must be 1')
                assert(all(all(abs(p_out-p_ref) < 1e-6)),sprintf('result off by %f',sum(sum(abs(p_out-p_ref)))))
            end
        end

    end
    
end
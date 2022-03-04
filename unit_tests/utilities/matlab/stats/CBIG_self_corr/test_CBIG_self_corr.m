classdef test_CBIG_self_corr < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function matrixCase(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            load('input/input.mat','am');
            bms = CBIG_self_corr(am);
            
            if replace_unittest_flag
                % replace reference result
                bm = bms;
                save('ref_output/output.mat','bm')
            else
                load('ref_output/output.mat','bm');

                % compare the current output with expected output
                assert(size(bms,1) == 40,'no. of rows must be 40')
                assert(size(bms,2) == 40,'no. of columns must be 40')
                assert(all(all(abs(bms-bm) < 1e-6)),sprintf('result off by %f',sum(sum(abs(bms-bm)))))
            end
        end
        
    end
    
end

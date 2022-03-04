classdef test_CBIG_nancorr < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        % test input matrix case
        function inputMatrix(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            a = [[0.41,0.63,0.52];[0.03,0.29,0.35];[0.89,nan,0.83];[0.54,0.66,0.26];[nan,0.07,0.30]];
            b = [[nan,0.46,0.51];[0.39,0.04,0.89];[0.37,0.28,0.58];[0.09,0.37,0.91];[0.37,0.18,nan]];
            c = CBIG_nancorr(a,b);
            
            if replace_unittest_flag
                % replace reference result
                result = c;
                save('ref_output/result.mat','result')
            else
                % load reference result as result
                load('ref_output/result.mat');
                
                % compare the current output with expected output
                assert(size(c,1) == 3,'no. of rows must be 3')
                assert(size(c,2) == 3,'no. of columns must be 3')
                assert(all(all(abs(c-result) < 1e-8)),sprintf('result off by %f',sum(sum(abs(c-result)))))
            end
        end
                
    end
    
end

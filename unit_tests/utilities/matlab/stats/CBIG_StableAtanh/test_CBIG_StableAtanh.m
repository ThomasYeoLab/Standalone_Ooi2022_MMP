classdef test_CBIG_StableAtanh < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function Test(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
                        
            % get the current output using artificial data
            load('input/input.mat');
            bs = CBIG_StableAtanh(a);
            
            if replace_unittest_flag
                % replace reference result
                b = bs;
                save('ref_output/output.mat','b')
            else
                load('ref_output/output.mat');

                % compare the current output with expected output
                assert(size(bs,1) == 20,'no. of rows must be 20')
                assert(size(bs,2) == 20,'no. of columns must be 20')
                assert(all(all(abs(bs-b) < 10e-6)),sprintf('Atanh result off by %f',sum(sum(abs(bs-b)))))
            end
        end
        
        
    end
    
end

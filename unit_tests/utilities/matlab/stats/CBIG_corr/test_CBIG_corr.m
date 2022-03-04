classdef test_CBIG_corr < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        % test input matrix case
        function inputMatrix(testCase)
            
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            a = [[0.41,0.63,0.52];[0.03,0.29,0.35];[0.89,0.08,0.83];[0.54,0.66,0.26];[0.18,0.07,0.30]];
            b = [[0.55,0.46,0.51];[0.39,0.04,0.89];[0.37,0.28,0.58];[0.09,0.37,0.91];[0.37,0.18,0.48]];
            c = CBIG_corr(a,b);
                
            if replace_unittest_flag
                % replace reference result
                result = c;
                save('ref_output/matCase_output.mat','result')
            else
                % load reference result
                %result = [[-0.199035,-0.199306,0.413296];[0.576907,0.641142,0.226743];[-0.185683,0.390675,-0.432059]]';
                load('ref_output/matCase_output.mat')
                
                % compare the current output with expected output
                assert(size(c,1) == 3,'no. of rows must be 3')
                assert(size(c,2) == 3,'no. of columns must be 3')
                assert(all(all(abs(c-result) < 1e-6)),sprintf('result off by %f',sum(sum(abs(c-result)))))
            end
        end
        
        % test input vector case
        function inputVector(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            a = [0.45,0.34,0.45,0.89,0.09,0.61];
            b = [0.18,0.89,0.61,0.72,0.34,0.07];
            c = CBIG_corr(a',b');
            
            if replace_unittest_flag
                result = c;
                save('ref_output/vecCase_output.mat','result')
            else
                % load result
                %result = 0.108548;
                load('ref_output/vecCase_output.mat')
                
                % compare the current output with expected output
                assert(size(c,1) == 1,'no. of rows must be 1')
                assert(size(c,2) == 1,'no. of columns must be 1')
                assert(all(all(abs(c-result) < 1e-6)),sprintf('result off by %f',sum(sum(abs(c-result)))))
            end
        end
        
    end
    
end

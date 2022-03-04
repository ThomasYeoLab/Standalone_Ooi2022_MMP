classdef test_CBIG_components_subgraphs < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function Test(testCase)
            % read the replace_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            addpath(fullfile(CBIG_CODE_DIR, 'unit_tests'));
                       
            fileID = fopen('replace_unittest_flag','r');
            replace_flag = fscanf(fileID,'%d');
            
            % load the input data
            load('input/a.mat');
            [b,c] = CBIG_components_subgraphs(a); 
                
            if replace_flag == 0
                % load the output data b
                load('ref_output/result.mat');
                result_c = 357.5;

                % compare the current output with expected output
                assert(size(b,1) == 30,'no. of rows must be 30')
                assert(size(b,2) == 30,'no. of columns must be 30')
                assert(all(all(abs(b-result) < 10e-6)),'adj result is not correct')
                assert(abs(result_c-c) < 10e-6,sprintf('sz_link result off by %f',abs(result_c-c)))
            else
				result = b;
                save('ref_output/result.mat', 'result');
            end
            rmpath(fullfile(CBIG_CODE_DIR, 'unit_tests'));
        end
        
        
    end
    
end
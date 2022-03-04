classdef test_CBIG_nanmean < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        % test input matrix case with only one input
        function matrixdim1Case(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
                        
            % get the current output using artificial data
            load('input/mat_input.mat');
            bs = CBIG_nanmean(a);
            
            if replace_unittest_flag
                % replace reference result
                b = bs;
                save('ref_output/matCase1_output.mat','b')
            else
                load('ref_output/matCase1_output.mat');

                % compare the current output with expected output
                assert(size(bs,1) == 1,'no. of rows must be 1')
                assert(size(bs,2) == 30,'no. of columns must be 30')
                assert(all(all(abs(bs-b) < 1e-6)),sprintf('result off by %f',sum(sum(abs(bs-b)))))
            end
        end
        
        % test input vector case with only one input
        function vectordim1Case(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            load('input/vect_input.mat');
            bvs = CBIG_nanmean(av);
            
            if replace_unittest_flag
                % replace reference result
                bv = bvs;
                save('ref_output/vectCase_output.mat','bv')
            else
                load('ref_output/vectCase_output.mat');

                % compare the current output with expected output
                assert(size(bvs,1) == 1,'no. of rows must be 1')
                assert(size(bvs,2) == 1,'no. of columns must be 1')
                assert(all(all(abs(bvs-bv) < 1e-6)),sprintf('result off by %f',sum(sum(abs(bvs-bv)))))
            end 
        end
        
        % test input matrix case with two inputs
        function matrixdim2Case(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            load('input/mat_input.mat');
            bs2 = CBIG_nanmean(a,2);
            
            if replace_unittest_flag
                % replace reference result
                b2 = bs2;
                save('ref_output/matCase2_output.mat','b2')
            else
                load('ref_output/matCase2_output.mat');

                % compare the current output with expected output
                assert(size(bs2,1) == 30,'no. of rows must be 30')
                assert(size(bs2,2) == 1,'no. of columns must be 1')
                assert(all(all(abs(bs2-b2) < 1e-6)),sprintf('result off by %f',sum(sum(abs(bs2-b2)))))
            end
        end
               
        
    end
    
end

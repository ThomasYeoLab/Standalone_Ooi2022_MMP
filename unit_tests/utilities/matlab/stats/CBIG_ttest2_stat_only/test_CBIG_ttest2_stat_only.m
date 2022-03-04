classdef test_CBIG_ttest2_stat_only < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        % test input matrix case
        function matrixCase(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            load('input/mat_input.mat','am','bm'); 
            tms = CBIG_ttest2_stat_only(am,bm);
            
            if replace_unittest_flag
                % replace reference result
                tm = tms;
                save('ref_output/mat_output.mat','tm')
            else
                load('ref_output/mat_output.mat','tm');

                % compare the current output with expected output
                assert(size(tms,1) == 1,'no. of rows must be 1')
                assert(size(tms,2) == 20,'no. of columns must be 20')
                assert(all(all(abs(tms-tm) < 10e-6)),sprintf('t-test result off by %f',sum(sum(abs(tms-tm)))))
            end
        end
        
        % test input vector case
        function vectorCase(testCase)
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            % get the current output using artificial data
            load('input/vect_input.mat','av','bv'); 
            tvs = CBIG_ttest2_stat_only(av,bv);
            
            if replace_unittest_flag
                % replace reference result
                tv = tvs;
                save('ref_output/vect_output.mat','tv')
            else 
                load('ref_output/vect_output.mat','tv');

                % compare the current output with expected output
                assert(size(tvs,1) == 1,'no. of rows must be 1')
                assert(size(tvs,2) == 1,'no. of columns must be 1')
                assert(all(all(abs(tvs-tv) < 10e-6)),sprintf('t-test result off by %f',sum(sum(abs(tvs-tv)))))
            end
        end        
        
    end
    
end

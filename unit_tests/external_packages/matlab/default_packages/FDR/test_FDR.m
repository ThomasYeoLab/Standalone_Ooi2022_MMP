classdef test_FDR < matlab.unittest.TestCase
% Written by Leon Ooi and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function Test(testCase)

            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                'matlab', 'default_packages', 'FDR');
            
            % get the current output using artificial data
            load(fullfile(ref_dir, 'input', 'input.mat'));
            b = 0.05;
            cs = FDR(a,b);
            load(fullfile(ref_dir, 'ref_output', 'output.mat'));

            % replace unit test if flag is 1
            if replace_unit_test
                disp("Replacing unit test for FDR");
                % display differences
                disp(['Old length is [' num2str(length(c)) ']'] );
                disp(['New length is [' num2str(length(cs)) ']']);
                disp(['Sum of absolute difference in result is ' num2str(sum(sum(abs(cs-c)))) ]);              
                
                % save and load new output file
                c = cs;
                output_file = fullfile(ref_dir, 'ref_output','output.mat');
                save(output_file, 'c');
                load(output_file);
            end
            
            % compare the current output with expected output
            assert(length(cs) == 501,'length must be 501')
            assert(all(all(abs(cs-c) < 1e-10)),sprintf('result off by %f',sum(sum(abs(cs-c)))))
             
        end

    end
    
end

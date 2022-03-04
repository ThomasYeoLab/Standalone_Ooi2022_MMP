classdef test_MARS_AverageData < matlab.unittest.TestCase
% Written by He Tong and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        % define the function name based on your test, please give meaningful names
        function testNormalCase(testCase)
        	% get dir
        	CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
        	ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', ...
                'SDv1.5.1-svn593', 'BasicTools', 'MARS_AverageData');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
        	% get input and run function
        	input_file = fullfile(ref_dir, 'input', 'input.mat');
            load(input_file);
            avg_data_test = MARS_AverageData(mesh_input, data, total_var, num_iter);

            % get output and compare output based on size and result
			output_file = fullfile(ref_dir, 'ref_output','output.mat');
            load(output_file);
            
            % replace unit test if flag is 1
            if replace_unit_test
                % display differences
                disp("Replacing unit test for MARS_AverageData");
                disp(['Old field size is [' num2str(size(avg_data_test)) ']'] );
                disp(['New field size is [' num2str(size(avg_data)) ']']);
                disp(['Sum of absolute difference in avg_data result is ' num2str(sum(sum(abs(avg_data_test - avg_data)))) ]);              
                
                % save and load new output file
                avg_data = avg_data_test;
                output_file = fullfile(ref_dir, 'ref_output','output.mat');
                save(output_file,'avg_data');
                load(output_file);
            end
            
            assert(isequal(size(avg_data_test), size(avg_data)), 'avg_data output size is not matching')
            assert(all(all(abs(avg_data_test - avg_data) < 1e-6)), sprintf('(sum absolute difference) avg_data result off by %f', sum(sum(abs(avg_data_test - avg_data)))));
        end
    end

end
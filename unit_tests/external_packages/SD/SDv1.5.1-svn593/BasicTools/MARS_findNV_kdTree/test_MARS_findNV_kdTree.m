classdef test_MARS_findNV_kdTree < matlab.unittest.TestCase
% Written by He Tong and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        % define the function name based on your test, please give meaningful names
        function testNormalCase(testCase)
            % get dir
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_findNV_kdTree');

            % get input and run function
            input_file = fullfile(ref_dir, 'input', 'input.mat');
            load(input_file);
            [NVs_test, distances_test] = MARS_findNV_kdTree(TestPoints, ReferencePts);
            output_file = fullfile(ref_dir, 'ref_output', 'output.mat');
            load(output_file);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_findNV_kdTree...');
                abserror = abs(NVs_test - NVs);
                disp(['Total error (NVs): ' num2str(sum(sum(abserror)))]);
                abserror = abs(distances_test - distances);
                disp(['Total error (distances): ' num2str(sum(sum(abserror)))]);
                NVs = NVs_test;
                distances = distances_test;
                save(fullfile(ref_dir, 'ref_output', 'output.mat'), 'NVs', 'distances');
            else
                % compare output based on size and result
                assert(isequal(size(NVs_test), size(NVs)), 'NVs output size is not matching')
                assert(isequal(size(distances_test), size(distances)), 'distances output size is not matching')
                assert(all(all(abs(NVs_test - NVs) < 1e-6)), ...
                    sprintf('(sum absolute difference) NVs result off by %f', sum(sum(abs(NVs_test - NVs)))));
                assert(all(all(abs(distances_test - distances) < 1e-6)), ...
                    sprintf('(sum absolute difference) distances result off by %f', ...
                    sum(sum(abs(distances_test - distances)))));
            end
        end
    end

end
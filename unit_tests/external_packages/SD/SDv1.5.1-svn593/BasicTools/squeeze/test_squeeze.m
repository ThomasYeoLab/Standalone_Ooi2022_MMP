classdef test_squeeze < matlab.unittest.TestCase
% Written by He Tong and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        % define the function name based on your test, please give meaningful names
        function test3DInputCase(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'squeeze');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_3DInputCase.mat'));
            a = [[0.41 0.63 0.52]; [0.03 0.29 0.35]; [0.89 0.08 0.83]; [0.54 0.66 0.26]; [0.18 0.07 0.30]];
            a(:, :, 2) = [[0.55 0.46 0.51]; [0.39 0.04 0.89]; [0.90 0.90 0.86]; [0.53 0.74 0.97]; [0.28 0.21 0.54]];
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_squeeze, test3DInputCase...');
                c = squeeze(a(:, 1, :));
                if size(size(c), 2) ~= 2
                    disp('output must be 2 dimensional');
                end
                if size(c, 1) ~= 5
                    disp('no. of rows must be 5');
                end
                if size(c, 2) ~= 2
                    disp('no. of cols must be 2');
                end
                abserror = abs(c - expectedResult1);
                disp(['Absolute error (' '3DInputCase 1st case' '): ' num2str(sum(sum(abserror)))]);
                c = squeeze(a(1, :, :));
                if size(size(c), 2) ~= 2
                    disp('output must be 2 dimensional');
                end
                if size(c, 1) ~= 3
                    disp('no. of rows must be 3');
                end
                if size(c, 2) ~= 2
                    disp('no. of cols must be 2');
                end
                abserror = abs(c - expectedResult2);
                disp(['Absolute error (' '3DInputCase 2nd case' '): ' num2str(sum(sum(abserror)))]);
                expectedResult1 = squeeze(a(:, 1, :));
                expectedResult2 = squeeze(a(1, :, :));
                % save new reference result
                save(fullfile(...
                    cur_dir, 'ref_output', 'expectedResult_3DInputCase.mat'), 'expectedResult1', 'expectedResult2');
            else
                c = squeeze(a(:, 1, :));
                assert(size(size(c), 2) == 2, 'output must be 2 dimensional')
                assert(size(c, 1) == 5, 'no. of rows must be 5')
                assert(size(c, 2) == 2, 'no. of cols must be 2')
                assert(all(all(abs(c - expectedResult1) < 1e-6)), ...
                    sprintf('(sum absolute difference) result off by %f', sum(sum(abs(expectedResult1 - c)))));
                c = squeeze(a(1, :, :));
                assert(size(size(c), 2) == 2, 'output must be 2 dimensional')
                assert(size(c, 1) == 3, 'no. of rows must be 3')
                assert(size(c, 2) == 2, 'no. of cols must be 2')
                assert(all(all(abs(c - expectedResult2) < 1e-6)), ...
                    sprintf('(sum absolute difference) result off by %f', sum(sum(abs(expectedResult2 - c)))));
            end
        end

        function test4DInputCase(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'squeeze');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_4DInputCase.mat'));
            a = [[0.41 0.63 0.52]; [0.03 0.29 0.35]; [0.89 0.08 0.83]; [0.54 0.66 0.26]; [0.18 0.07 0.30]];
            a(:, :, 2) = [[0.55 0.46 0.51]; [0.39 0.04 0.89]; [0.90 0.90 0.86]; [0.53 0.74 0.97]; [0.28 0.21 0.54]];
            a(:, :, :, 2) = a;
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_squeeze, test4DInputCase...');
                c = squeeze(a(1, :, 2, :));
                if size(size(c), 2) ~= 2
                    disp('output must be 2 dimensional');
                end
                if size(c, 1) ~= 3
                    disp('no. of rows must be 3');
                end
                if size(c, 2) ~= 2
                    disp('no. of cols must be 2');
                end
                abserror = abs(c - expectedResult);
                disp(['Absolute error (' '4DInputCase' '): ' num2str(sum(sum(abserror)))]);
                expectedResult = c;
                % save new reference result
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_4DInputCase.mat'), 'expectedResult')
            else
                c = squeeze(a(1, :, 2, :));
                assert(size(size(c), 2) == 2, 'output must be 2 dimensional')
                assert(size(c, 1) == 3, 'no. of rows must be 3')
                assert(size(c, 2) == 2, 'no. of cols must be 2')
                assert(all(all(abs(c - expectedResult) < 1e-6)), ...
                    sprintf('(sum absolute difference) result off by %f', sum(sum(abs(expectedResult - c)))));
            end
        end

        function test2DInputCase(testCase)
            % Test for 2D matrix
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'squeeze');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_2DInputCase.mat'));
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_squeeze, test2DInputCase...');
                c = squeeze(a);
                if size(size(c), 2) ~= 2
                    disp('output must be 2 dimensional');
                end
                if size(c, 1) ~= 5
                    disp('no. of rows must be 5');
                end
                if size(c, 2) ~= 3
                    disp('no. of cols must be 3');
                end
                abserror = abs(c - a);
                disp(['Absolute error (' '2DInputCase' '): ' num2str(sum(sum(abserror)))]);
                a = c;
                % save new reference result
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_2DInputCase.mat'), 'a')
            else
                c = squeeze(a);
                assert(size(size(c), 2) == 2, 'output must be 2 dimensional')
                assert(size(c, 1) == 5, 'no. of rows must be 5')
                assert(size(c, 2) == 3, 'no. of cols must be 3')
                assert(all(all(abs(c - a) < 1e-6)), ...
                    sprintf('(sum absolute difference) result off by %f', sum(sum(abs(a - c)))));
            end
        end

        function testArrayInputCase(testCase)
            % Test for array
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'squeeze');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_ArrayInputCase.mat'));
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_squeeze, testArrayInputCase...');
                c = squeeze(a);
                if size(size(c), 2) ~= 2
                    disp('output must be 2 dimensional');
                end
                if size(c, 1) ~= 1
                    disp('no. of rows must be 1');
                end
                if size(c, 2) ~= 3
                    disp('no. of cols must be 3');
                end
                abserror = abs(c - a);
                disp(['Absolute error (' 'ArrayInputCase' '): ' num2str(sum(sum(abserror)))]);
                a = c;
                % save new reference result
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_ArrayInputCase.mat'), 'a')
            else
                c = squeeze(a);
                assert(size(size(c), 2) == 2, 'output must be 2 dimensional')
                assert(size(c, 1) == 1, 'no. of rows must be 1')
                assert(size(c, 2) == 3, 'no. of cols must be 3')
                assert(all(all(abs(c - a) < 1e-6)), ...
                    sprintf('(sum absolute difference) result off by %f', sum(sum(abs(a - c)))));
            end
        end
    end

end
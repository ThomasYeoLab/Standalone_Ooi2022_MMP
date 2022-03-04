classdef test_munkres < matlab.unittest.TestCase

    methods (Test)
        function testSmallMatrix(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            [assignment, cost] = munkres(magic(5));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of munkres, testSamllMatrix...')
                assignment_true = assignment;
                cost_true = cost;
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testSmallMatrix_assignment.mat'), 'assignment_true');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testSmallMatrix_cost.mat'), 'cost_true');
            else   
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testSmallMatrix_assignment.mat'));
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testSmallMatrix_cost.mat'));
                assert(all(assignment == assignment_true), 'wrong assignment'); 
                assert(cost == cost_true, 'wrong cost');
            end
        end

        function testLargeMatrix(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            rng(0, 'twister');
            A = rand(400);

            [assignment, cost] = munkres(A);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of munkres, testLrageMatrix...')
                cost_true = cost;
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testLargeMatrix_cost.mat'), 'cost_true');
            else 
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testLargeMatrix_cost.mat'));
                mae = abs(cost - cost_true);
                assert(mae < 1e-9, sprintf('off by %.9f', mae)); 
            end
        end

        function testRectMatrix(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            rng(0, 'twister');
            A = rand(10,7);

            [assignment, cost] = munkres(A);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of munkres, testRectMatrix...')
                assignment_true = assignment;
                cost_true = cost;
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testRectMatrix_assignment.mat'), 'assignment_true');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testRectMatrix_cost.mat'), 'cost_true');
            else 
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testRectMatrix_assignment.mat'));
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testRectMatrix_cost.mat'));
                assert(all(assignment == assignment_true), 'wrong assignment');
                mae = abs(cost - cost_true);
                assert(mae < 1e-9, 'wrong cost');
            end
        end

        function testRectMatrixWithInfCosts(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            rng(0, 'twister');
            A = rand(5, 3);
            A(A>0.7) = Inf;

            [assignment, cost] = munkres(A);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of munkres, testRectMatrixWithInfCosts...')
                assignment_true = assignment;
                cost_true = cost;
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testRectMatrixWithInfCosts_assignment.mat'), 'assignment_true');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testRectMatrixWithInfCosts_cost.mat'), 'cost_true');
            else 
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testRectMatrixWithInfCosts_assignment.mat'));
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'others', 'munkres', 'ref_output', 'testRectMatrixWithInfCosts_cost.mat'));
                assert(all(assignment == assignment_true), 'wrong assignment');
                mae = abs(cost - cost_true);
                assert(mae < 1e-9, 'wrong cost');
            end
        end
    end

end

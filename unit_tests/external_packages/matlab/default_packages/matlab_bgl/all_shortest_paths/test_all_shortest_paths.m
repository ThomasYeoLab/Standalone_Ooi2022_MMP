classdef test_all_shortest_paths < matlab.unittest.TestCase

    methods (Test)
        function testBasic(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            i = [4 1 3 1 4 2 5 1 2]';
            j = [1 2 2 3 3 4 4 5 5]';
            k = [2 3 4 8 -5 1 6 -4 7]';
            A = sparse(i, j, k);

            if(replace_unittest_flag)
                disp('Replacing unit test reference results of all_shortest_paths, testBasic...')
                D_true = all_shortest_paths(A);
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', 'testBasic.mat'), 'D_true');
            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', 'testBasic.mat'))
                
                D = all_shortest_paths(A);
                assert(all(all(D == D_true)), 'alg=auto: failed');

                D = all_shortest_paths(A, 'algname','johnson');
                assert(all(all(D == D_true)), 'alg=johnson failed');

                D = all_shortest_paths(A, 'algname','floyd_warshall');
                assert(all(all(D == D_true)), 'alg=floyd_warshall failed');
            end
        end

        function testNonReachableVertex(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            A = sparse([1 1; 0 1]);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of all_shortest_paths, testNonReachableVertex...')
                D_true = all_shortest_paths(A, 'inf', 5, 'algname', 'johnson');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', ...
                    'testNonReachableVertex.mat'), 'D_true');
            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', ...
                    'testNonReachableVertex.mat'))
                
                D = all_shortest_paths(A, 'inf', 5, 'algname', 'johnson');
                assert(all(all(D == D_true)), 'alg=johnson, inf=5 failed')

                D = all_shortest_paths(A, 'inf', 5, 'algname', 'floyd_warshall');
                assert(any(any(D == D_true)), 'alg=floyd_warshall, inf=5 failed');
            end
        end

        function testEdgeWeightedGraph(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            i = [4 1 3 1 4 2 5 1 2]';
            j = [1 2 2 3 3 4 4 5 5]';
            k = [2 3 4 8 -5 1 6 -4 7]';
            A = sparse(i, j, k);

            if(replace_unittest_flag)
                disp('Replacing unit test reference results of all_shortest_paths, testEdgeWeightedGraph...')
                D_true = all_shortest_paths(A, 'edge_weight', 'matrix');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', ...
                    'testEdgeWeightedGraph.mat'), 'D_true');
            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', ...
                    'testEdgeWeightedGraph.mat'))
                
                D = all_shortest_paths(A, 'edge_weight', 'matrix');
                assert(all(all(D == D_true)), 'weight=matrix failed');

                v = nonzeros(A');
                D = all_shortest_paths(spones(A), 'edge_weight', v);
                assert(all(all(D == D_true)), 'weight=matrix failed');

                try
                    bc = all_shortest_paths(A, 'edge_weight', rand(2,1));
                    error('all_shortest_paths(weight=rand(2,1)) did not report an error');    
                catch
                end
            end
        end

        function testPredecessorMatrix(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            i = [4 1 3 1 4 2 5 1 2]';
            j = [1 2 2 3 3 4 4 5 5]';
            k = [2 3 4 8 -5 1 6 -4 7]';
            A = sparse(i, j, k);

            if(replace_unittest_flag)
                disp('Replacing unit test reference results of all_shortest_paths, testPredecessorMatrix...')
                [D_true, P_true] = all_shortest_paths(A, 'algname', 'floyd_warshall');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', ...
                    'testPredecessorMatrix_D.mat'), 'D_true');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', ...
                    'testPredecessorMatrix_P.mat'), 'P_true');
            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', ...
                    'testPredecessorMatrix_D.mat'));
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'all_shortest_paths', 'ref_output', ...
                    'testPredecessorMatrix_P.mat'));

                for i=1:size(A,1)
                    [d, p] = shortest_paths(A, i);
                    assert(all(D_true(i,:) == d'), 'incorrect distance; error may be due to bug from shortest_paths function');
                    assert(all(P_true(i,:) == p), 'incorrect predecessor; error may be due to bug from shortest_paths function');
                end
            end
        end

    end

end

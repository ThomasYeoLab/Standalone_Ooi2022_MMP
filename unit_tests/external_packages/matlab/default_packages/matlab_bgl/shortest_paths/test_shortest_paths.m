classdef test_shortest_paths < matlab.unittest.TestCase

    methods (Test)
        function testGeneral(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            i = [5 1 3 1 2 2 3 5 3 4]';
            j = [1 2 2 3 3 4 4 4 5 5]';
            k = [3 3 1 5 2 6 4 7 6 4]';
            A = sparse(i, j, k);
            src = 1;
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of shortest_paths, testGeneral...')
                D_true = shortest_paths(A, src);
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', 'testGeneral.mat'), 'D_true');
            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', 'testGeneral.mat'));
                D = shortest_paths(A, src);
                assert(all(all(D == D_true)), 'algorithm=auto');
                
                D = shortest_paths(A, src, 'algname','dijkstra');
                assert(all(all(D == D_true)), 'algorithm=dijkstra failed');
                
                D = shortest_paths(A, src, 'algname','bellman_ford');
                assert(all(all(D == D_true)), 'algorithm=bellman_ford failed');
            end
        end

        function testBellmanFord(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            i = [1 1 3]';
            j = [2 3 2]';
            k = [3 -1 10]';
            A = sparse(i, j, k);
            src = 1;
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of shortest_paths, testBellmanFord...')
                [D_true, pred_true] = shortest_paths(A, src, 'algname','bellman_ford');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testBellmanFord_D.mat'), 'D_true');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testBellmanFord_pred.mat'), 'pred_true');
            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testBellmanFord_D.mat'));
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testBellmanFord_pred.mat'));
                
                [D, pred] = shortest_paths(A, src);
                % auto equivalent to bellman-ford when there are negative edges
                assert(all(all(D == D_true)), 'algorithm=auto');
                assert(all(all(pred == pred_true)), 'algorithm=auto');

                [D, pred] = shortest_paths(A, src, 'algname','bellman_ford');
                assert(all(all(D == D_true)), 'algorithm=bellman_ford failed');
                assert(all(all(pred == pred_true)), 'algorithm=bellman_ford');

                try
                    [D, pred] = shortest_paths(A, src, 'algname','dijkstra');
                    assert(false, 'must raise error when using dijkstra with negative edges');    
                catch
                end
            end
        end

        function testNonReachableVertex(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            A = sparse([1 0; 0 1]);
            src = 1;

            if(replace_unittest_flag)
                disp('Replacing unit test reference results of shortest_paths, testNonReachableVertex...')
                D_true_inf5 = shortest_paths(A, src, 'inf', 5, 'algname', 'dijkstra');
                D_true_inf10 = shortest_paths(A, src, 'inf', 10, 'algname', 'dijkstra');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testNonReachableVertex_inf5.mat'), 'D_true_inf5');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testNonReachableVertex_inf10.mat'), 'D_true_inf10');
            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testNonReachableVertex_inf5.mat'));
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testNonReachableVertex_inf10.mat'));
                
                D = shortest_paths(A, src, 'inf', 5, 'algname', 'dijkstra');
                assert(all(all(D == D_true_inf5)), 'dijkstra, inf=5 failed')

                D = shortest_paths(A, src, 'inf', 10, 'algname', 'dijkstra');
                assert(all(all(D == D_true_inf10)), 'dijkstra, inf=10 failed')

                D = shortest_paths(A, src, 'inf', 5, 'algname', 'bellman_ford');
                assert(any(any(D == D_true_inf5)), 'bellman_ford, inf=5 failed');

                D = shortest_paths(A, src, 'inf', 10, 'algname', 'bellman_ford');
                assert(any(any(D == D_true_inf10)), 'bellman_ford, inf=10 failed');
            end
        end

        function testEdgeWeightedGraph(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            i = [4 1 3 1 4 2 5 1 2]';
            j = [1 2 2 3 3 4 4 5 5]';
            k = [2 3 4 8 5 1 6 4 7]';
            A = sparse(i, j, k);
            src = 1;

            if(replace_unittest_flag)
                disp('Replacing unit test reference results of shortest_paths, testEdgeWeightedGraph...')
                D_true = shortest_paths(A, src, 'edge_weight', 'matrix');
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testEdgeWeightedGraph.mat'), 'D_true');

            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', ...
                    'matlab', 'default_packages', 'matlab_bgl' ,'shortest_paths', 'ref_output', ...
                    'testEdgeWeightedGraph.mat'));
                D = shortest_paths(A, src, 'edge_weight', 'matrix');
                assert(all(all(D == D_true)), 'weight=matrix failed');

                v = nonzeros(A');
                D = shortest_paths(spones(A), src, 'edge_weight', v);
                assert(all(all(D == D_true)), 'weight=double vector failed');

                try
                    bc = shortest_paths(A, src, 'edge_weight', rand(2,1));
                    error('must raise error when dimensions disagree');    
                catch
                end
            end
        end

    end

end

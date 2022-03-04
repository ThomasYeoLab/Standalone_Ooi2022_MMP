classdef test_MARS_NNInterpolate_kdTree < matlab.unittest.TestCase
% Written by He Tong and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        % define the function name based on your test, please give meaningful names
        function testLHCase(testCase)
            % get dir
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_NNInterpolate_kdTree');

            % get input and run function
            input_file = fullfile(ref_dir, 'input', 'input.mat');
            load(input_file, 'points');
            params.SUBJECTS_DIR = fullfile(CBIG_CODE_DIR, 'data', 'example_data', 'CoRR_HNU', 'subj01_FS');
            params.hemi = 'lh';
            params.SUBJECT = 'subj01_sess1_FS';
            params.read_surface = @MARS2_readSbjMesh;
            params.radius = 100;
            params.unfoldBool = 0;
            params.flipFacesBool = 1;
            params.surf_filename = 'sphere.reg';
            
            mesh_input = MARS2_readSbjMesh(params);
            rng(1, 'twister');
            data = 200 * (rand(5, size(mesh_input.vertices, 2), 'single') - 0.5);
            
            [vals_test, seedVertices_test] = MARS_NNInterpolate_kdTree(points, mesh_input, data);

            % get output and compare output based on size and result
            output_file = fullfile(ref_dir, 'ref_output', 'output_lh.mat');
            load(output_file);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_NNInterpolate_kdTree, testLHCase...');
                abserror = abs(vals_test - vals);
                disp(['Total error (vals): ' num2str(sum(sum(abserror)))]);
                abserror = abs(seedVertices_test - seedVertices);
                disp(['Total error (seedVertices): ' num2str(sum(sum(abserror)))]);
                vals = vals_test;
                seedVertices = seedVertices_test;
                save(fullfile(ref_dir, 'ref_output', 'output_lh.mat'), 'vals', 'seedVertices');
            else
                assert(isequal(size(vals_test), size(vals)), 'vals output size is not matching')
                assert(isequal(size(seedVertices_test), size(seedVertices)), ...
                    'seedVertices output size is not matching')
                assert(all(all(abs(vals_test - vals) < 1e-6)), ...
                    sprintf('(sum absolute difference) vals result off by %f', sum(sum(abs(vals_test - vals)))));
                assert(all(all(abs(seedVertices_test - seedVertices) < 1e-6)), ...
                    sprintf('(sum absolute difference) seedVertices result off by %f', ...
                    sum(sum(abs(seedVertices_test - seedVertices)))));
            end
        end
        
        function testRHCase(testCase)
            % get dir
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', 'BasicTools', 'MARS_NNInterpolate_kdTree');

            % get input and run function
            input_file = fullfile(ref_dir, 'input', 'input.mat');
            load(input_file, 'points');
            params.SUBJECTS_DIR = fullfile(CBIG_CODE_DIR, 'data', 'example_data', 'CoRR_HNU', 'subj01_FS');
            params.hemi = 'rh';
            params.SUBJECT = 'subj01_sess1_FS';
            params.read_surface = @MARS2_readSbjMesh;
            params.radius = 100;
            params.unfoldBool = 0;
            params.flipFacesBool = 1;
            params.surf_filename = 'sphere.reg';
            
            mesh_input = MARS2_readSbjMesh(params);
            rng(1, 'twister');
            data = 200 * (rand(5, size(mesh_input.vertices, 2), 'single') - 0.5);
            
            [vals_test, seedVertices_test] = MARS_NNInterpolate_kdTree(points, mesh_input, data);

            % get output and compare output based on size and result
            output_file = fullfile(ref_dir, 'ref_output', 'output_rh.mat');
            load(output_file);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_NNInterpolate_kdTree, testRHCase...');
                abserror = abs(vals_test - vals);
                disp(['Total error (vals): ' num2str(sum(sum(abserror)))]);
                abserror = abs(seedVertices_test - seedVertices);
                disp(['Total error (seedVertices): ' num2str(sum(sum(abserror)))]);
                vals = vals_test;
                seedVertices = seedVertices_test;
                save(fullfile(ref_dir, 'ref_output', 'output_rh.mat'), 'vals', 'seedVertices');
            else
                assert(isequal(size(vals_test), size(vals)), 'vals output size is not matching')
                assert(isequal(size(seedVertices_test), size(seedVertices)), ...
                    'seedVertices output size is not matching')
                assert(all(all(abs(vals_test - vals) < 1e-6)), ....
                    sprintf('(sum absolute difference) vals result off by %f', sum(sum(abs(vals_test - vals)))));
                assert(all(all(abs(seedVertices_test - seedVertices) < 1e-6)), ...
                    sprintf('(sum absolute difference) seedVertices result off by %f', ...
                    sum(sum(abs(seedVertices_test - seedVertices)))));
            end
        end
    end

end
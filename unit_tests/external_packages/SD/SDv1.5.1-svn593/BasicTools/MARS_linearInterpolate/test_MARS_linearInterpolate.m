classdef test_MARS_linearInterpolate < matlab.unittest.TestCase
% Written by He Tong and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        % define the function name based on your test, please give meaningful names        
        function testLHCase(testCase)
            % get dir
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_linearInterpolate');

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
            
            [vals_test, NViF_test, NF_test] = MARS_linearInterpolate(points, mesh_input, data);
            
            % get output and compare output based on size and result
            output_file = fullfile(ref_dir, 'ref_output', 'output_lh.mat');
            load(output_file);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_linearInterpolate, testLHCase...');
                abserror = abs(vals_test - vals);
                disp(['Total error (vals): ' num2str(sum(sum(abserror)))]);
                abserror = abs(NViF_test - NViF);
                disp(['Total error (NViF): ' num2str(sum(sum(abserror)))]);
                abserror = abs(NF_test - NF);
                disp(['Total error (NF): ' num2str(sum(sum(abserror)))]);
                vals = vals_test;
                NViF = NViF_test;
                NF = NF_test;
                save(fullfile(ref_dir, 'ref_output', 'output_lh.mat'), 'vals', 'NViF', 'NF');
            else
                assert(isequal(size(vals_test), size(vals)), 'vals output size is not matching')
                assert(isequal(size(NViF_test), size(NViF)), 'NViF output size is not matching')
                assert(isequal(size(NF_test), size(NF)), 'NF output size is not matching')
                assert(all(all(abs(vals_test - vals) < 1e-6)), ...
                    sprintf('(sum absolute difference) vals result off by %f', sum(sum(abs(vals_test - vals)))));
                assert(all(all(abs(NViF_test - NViF) < 1e-6)), ...
                    sprintf('(sum absolute difference) NViF result off by %f', sum(sum(abs(NViF_test - NViF)))));
                assert(all(all(abs(NF_test - NF) < 1e-6)), ...
                    sprintf('(sum absolute difference) NF result off by %f', sum(sum(abs(NF_test - NF)))));
            end
        end
        
        function testRHCase(testCase)
            % get dir
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', 'BasicTools', 'MARS_linearInterpolate');

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
            
            [vals_test, NViF_test, NF_test] = MARS_linearInterpolate(points, mesh_input, data);
            
            % get output and compare output based on size and result
            output_file = fullfile(ref_dir, 'ref_output', 'output_rh.mat');
            load(output_file);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_linearInterpolate, testRHCase...');
                abserror = abs(vals_test - vals);
                disp(['Total error (vals): ' num2str(sum(sum(abserror)))]);
                abserror = abs(NViF_test - NViF);
                disp(['Total error (NViF): ' num2str(sum(sum(abserror)))]);
                abserror = abs(NF_test - NF);
                disp(['Total error (NF): ' num2str(sum(sum(abserror)))]);
                vals = vals_test;
                NViF = NViF_test;
                NF = NF_test;
                save(fullfile(ref_dir, 'ref_output', 'output_rh.mat'), 'vals', 'NViF', 'NF');
            else
                assert(isequal(size(vals_test), size(vals)), 'vals output size is not matching')
                assert(isequal(size(NViF_test), size(NViF)), 'NViF output size is not matching')
                assert(isequal(size(NF_test), size(NF)), 'NF output size is not matching')
                assert(all(all(abs(vals_test - vals) < 1e-6)), ...
                    sprintf('(sum absolute difference) vals result off by %f', sum(sum(abs(vals_test - vals)))));
                assert(all(all(abs(NViF_test - NViF) < 1e-6)), ...
                    sprintf('(sum absolute difference) NViF result off by %f', sum(sum(abs(NViF_test - NViF)))));
                assert(all(all(abs(NF_test - NF) < 1e-6)), ...
                    sprintf('(sum absolute difference) NF result off by %f', sum(sum(abs(NF_test - NF)))));
            end
        end
    end

end
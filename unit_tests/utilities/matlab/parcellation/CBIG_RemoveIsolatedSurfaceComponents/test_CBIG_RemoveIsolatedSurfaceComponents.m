classdef test_CBIG_RemoveIsolatedSurfaceComponents < matlab.unittest.TestCase

    methods (Test)
        function test_fslr_thrs1(testCase)
            % there is NO option to replace unit test reference output result here
            % since this test passes only if the output is identical to the input file

            in = load(fullfile('input', 'RemoveIsolatedSurfComp_parc.mat'));

            lh_mesh_fslr_32k = CBIG_read_fslr_surface('lh', 'fs_LR_32k', 'inflated');
            rh_mesh_fslr_32k = CBIG_read_fslr_surface('rh', 'fs_LR_32k', 'inflated');

            out.lh_labels = CBIG_RemoveIsolatedSurfaceComponents(...
                lh_mesh_fslr_32k, in.lh_labels, 1);
            out.rh_labels = CBIG_RemoveIsolatedSurfaceComponents(...
                rh_mesh_fslr_32k, in.rh_labels, 1);

            % threshold == 1 should give output identical as input
            assert(all(in.lh_labels == out.lh_labels));
            assert(all(in.rh_labels == out.rh_labels));
        end

        function test_fslr_thrs5(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));

            in = load(fullfile('input', 'RemoveIsolatedSurfComp_parc.mat'));
            ground_truth = load(fullfile('ref_output', 'RemoveIsolatedSurfComp_fslr_thr5.mat'));

            lh_mesh_fslr_32k = CBIG_read_fslr_surface('lh', 'fs_LR_32k', 'inflated');
            rh_mesh_fslr_32k = CBIG_read_fslr_surface('rh', 'fs_LR_32k', 'inflated');

            lh_labels = CBIG_RemoveIsolatedSurfaceComponents(...
                lh_mesh_fslr_32k, in.lh_labels, 5);
            rh_labels = CBIG_RemoveIsolatedSurfaceComponents(...
                rh_mesh_fslr_32k, in.rh_labels, 5);

            % threshold > 1 should give output different from input
            assert(any(in.lh_labels ~= lh_labels));
            assert(any(in.rh_labels ~= rh_labels));

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for CBIG_RemoveIsolatedSurfaceComponents...');
                sprintf('There are %d lh labels that are different with the reference results.', sum(ground_truth.lh_labels ~= lh_labels));
                sprintf('There are %d lh labels that are different with the reference results.', sum(ground_truth.rh_labels ~= rh_labels));
                save(fullfile('ref_output', 'RemoveIsolatedSurfComp_fslr_thr5.mat'), 'lh_labels','rh_labels');
            else
                assert(all(ground_truth.lh_labels == lh_labels));
                assert(all(ground_truth.rh_labels == rh_labels));
            end
        end

        function test_fslr_thrs10(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));

            in = load(fullfile('input', 'RemoveIsolatedSurfComp_parc.mat'));
            ground_truth = load(fullfile('ref_output', 'RemoveIsolatedSurfComp_fslr_thr10.mat'));

            lh_mesh_fslr_32k = CBIG_read_fslr_surface('lh', 'fs_LR_32k', 'inflated');
            rh_mesh_fslr_32k = CBIG_read_fslr_surface('rh', 'fs_LR_32k', 'inflated');

            lh_labels = CBIG_RemoveIsolatedSurfaceComponents(...
                lh_mesh_fslr_32k, in.lh_labels, 10);
            rh_labels = CBIG_RemoveIsolatedSurfaceComponents(...
                rh_mesh_fslr_32k, in.rh_labels, 10);

            % threshold > 1 should give output different from input
            assert(any(in.lh_labels ~= lh_labels));
            assert(any(in.rh_labels ~= rh_labels));

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for CBIG_RemoveIsolatedSurfaceComponents...');
                sprintf('There are %d lh labels that are different with the reference results.', sum(ground_truth.lh_labels ~= lh_labels));
                sprintf('There are %d lh labels that are different with the reference results.', sum(ground_truth.rh_labels ~= rh_labels));
                save(fullfile('ref_output', 'RemoveIsolatedSurfComp_fslr_thr10.mat'), 'lh_labels','rh_labels');
            else
                assert(all(ground_truth.lh_labels == lh_labels));
                assert(all(ground_truth.rh_labels == rh_labels));
            end
        end

    end

end

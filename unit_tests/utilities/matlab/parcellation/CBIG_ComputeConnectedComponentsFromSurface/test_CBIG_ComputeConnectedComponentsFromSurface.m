classdef test_CBIG_ComputeConnectedComponentsFromSurface < matlab.unittest.TestCase

    methods (Test)
        function test_fslr(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));

            in = load(fullfile('input', 'RemoveIsolatedSurfComp_parc.mat'));
            ref_data = load(fullfile('ref_output', 'ComputeConnectedCompFromSurf_fslr.mat'));

            lh_mesh_fslr_32k = CBIG_read_fslr_surface('lh', 'fs_LR_32k', 'inflated');
            rh_mesh_fslr_32k = CBIG_read_fslr_surface('rh', 'fs_LR_32k', 'inflated');

            [lh_ci, lh_sizes, lh_label_id] = CBIG_ComputeConnectedComponentsFromSurface(...
                lh_mesh_fslr_32k, in.lh_labels);
            [rh_ci, rh_sizes, rh_label_id] = CBIG_ComputeConnectedComponentsFromSurface(...
                rh_mesh_fslr_32k, in.rh_labels);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for CBIG_ComputeConnectedComponentsFromSurface...');
                sprintf('There are %d lh components with wrong IDs.\n', sum(lh_label_id ~= ref_data.lh_label_id));
                sprintf('There are %d rh components with wrong IDs.\n', sum(rh_label_id ~= ref_data.rh_label_id));

                %% print lh error margins
                lh_wrong_comp_counter = 0;
                lh_comp_wrong_size_counter = 0;
                for i = 1:length(lh_ci)
                    lh_wrong_comp_counter = lh_wrong_comp_counter + sum(lh_ci{i} ~= ref_data.lh_ci{i});
                    lh_comp_wrong_size_counter = lh_comp_wrong_size_counter + sum(lh_sizes{i} ~= ref_data.lh_sizes{i});
                end
                sprintf('There are %d lh components with wrong delineation.\n', lh_wrong_comp_counter);
                sprintf('There are %d lh components of wrong sizes.\n', lh_comp_wrong_size_counter);
                
                %% print rh error margins
                rh_wrong_comp_counter = 0;
                rh_comp_wrong_size_counter = 0;
                for i = 1:length(rh_ci)
                    rh_wrong_comp_counter = rh_wrong_comp_counter + sum(rh_ci{i} ~= ref_data.rh_ci{i});
                    rh_comp_wrong_size_counter = rh_comp_wrong_size_counter + sum(rh_sizes{i} ~= ref_data.rh_sizes{i});
                end
                sprintf('There are %d rh components with wrong delineation.\n', rh_wrong_comp_counter);
                sprintf('There are %d rh components of wrong sizes.\n', rh_comp_wrong_size_counter);
                clear ref_data

                save(fullfile('ref_output', 'ComputeConnectedCompFromSurf_fslr.mat'), 'lh_ci','rh_ci', 'lh_sizes', 'rh_sizes', 'lh_label_id', 'rh_label_id');
            else
                assert(all(lh_label_id == ref_data.lh_label_id), 'lh with wrong IDs; error may be due to bug in CBIG_read_fslr_surface');
                for i = 1:length(lh_ci)
                    assert(all(lh_ci{i} == ref_data.lh_ci{i}), 'lh with wrong delineation of components; error may be due to bug in CBIG_read_fslr_surface');
                    assert(all(lh_sizes{i} == ref_data.lh_sizes{i}), 'lh have components of wrong sizes; error may be due to bug in CBIG_read_fslr_surface');
                end

                assert(all(rh_label_id == ref_data.rh_label_id)), 'rh with wrong IDs; error may be due to bug in CBIG_read_fslr_surface';
                for i = 1:length(rh_ci)
                    assert(all(rh_ci{i} == ref_data.rh_ci{i}), 'rh with wrong number of connected components; error may be due to bug in CBIG_read_fslr_surface');
                    assert(all(rh_sizes{i} == ref_data.rh_sizes{i}), 'rh has components of wrong sizes; error may be due to bug in CBIG_read_fslr_surface');
                end
            end

        end

    end

end

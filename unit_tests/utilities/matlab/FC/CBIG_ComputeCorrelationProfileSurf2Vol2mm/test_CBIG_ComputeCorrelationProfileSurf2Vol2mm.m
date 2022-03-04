classdef test_CBIG_ComputeCorrelationProfileSurf2Vol2mm < matlab.unittest.TestCase
% Written by Siyi Tang, Jingwei Li and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods(Test)
        function testNoRegression(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeCorrelationProfileSurf2Vol2mm');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            seed_mesh = 'fsaverage5';
            target = 'fsaverage6';
            threshold = '0.1';
            
            Yeo2011_cluster = fullfile(ref_dir, 'input', '1000subjects_clusters017_ref.mat');
            clustered = load(Yeo2011_cluster);
            ind = [find(clustered.lh_labels==15); find(clustered.rh_labels==15)];
            ind = cellstr(num2str(ind));
            
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            output_file = fullfile(output_dir, 'output_noRegression.mat');
            mask_file = fullfile(CBIG_CODE_DIR, 'data', 'templates', 'volume', ...
                'FSL_MNI152_masks', 'SubcorticalLooseMask_MNI1mm_sm6_MNI2mm_bin0.2.nii.gz');
            input_file_txt = fullfile(ref_dir, 'input', 'volList.txt');
            seed_file_txt = fullfile(ref_dir, 'input', 'surfList.txt');
            regress_bool = 0;
            CBIG_ComputeCorrelationProfileSurf2Vol2mm(seed_mesh, target, output_file, threshold, ...
                mask_file, input_file_txt, seed_file_txt, regress_bool, ind{:})
            
            ref = load(fullfile(ref_dir, 'ref_output', 'output_noRegression.mat'));
            output = load(output_file);
            
            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeCorrelationProfileSurf2Vol2mm, testNoRegression")
                % display differences
                disp(['Old size of correlation profile matrix is [ ' num2str(size(ref.surf2vol_correlation_profile)) ' ]' ])
                disp(['New size of correlation profile matrix is [ ' num2str(size(output.surf2vol_correlation_profile)) ' ]' ])
                disp(['Max abs diff of correlation profile matrix is ' ...
                    num2str(max(max(abs(ref.surf2vol_correlation_profile - output.surf2vol_correlation_profile)))) ])
                            
                % save and load new results
                ref_output_dir = fullfile(ref_dir, 'ref_output');
                ref_output_file = fullfile(ref_output_dir, 'output_noRegression.mat');
                CBIG_ComputeCorrelationProfileSurf2Vol2mm(seed_mesh, target, ref_output_file, threshold, ...
                mask_file, input_file_txt, seed_file_txt, regress_bool, ind{:});
                output = load(output_file);
            end
            
            assert(isequal(size(ref.surf2vol_correlation_profile), size(output.surf2vol_correlation_profile)), ...
                'Output correlation profile matrix is of wrong size.');
            assert(all(all(abs(ref.surf2vol_correlation_profile - output.surf2vol_correlation_profile) < 1e-12)), ...
                sprintf('Output correlation profile matris differed from reference result by (max abs diff) %f.', ...
                max(max(abs(ref.surf2vol_correlation_profile - output.surf2vol_correlation_profile)))));
            
            rmdir(output_dir, 's');
        end
    end
    
end
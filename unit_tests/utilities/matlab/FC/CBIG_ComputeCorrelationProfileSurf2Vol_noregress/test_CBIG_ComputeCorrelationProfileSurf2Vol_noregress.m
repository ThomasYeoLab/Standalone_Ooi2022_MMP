classdef test_CBIG_ComputeCorrelationProfileSurf2Vol_noregress < matlab.unittest.TestCase
% Written by Siyi Tang and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods(Test)
        function testSurf2Vol(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeCorrelationProfileSurf2Vol_noregress');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            seed_mesh = 'fsaverage5';
            target = 'fsaverage6';
            threshold = '0.1';
            
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            output_file = fullfile(output_dir, ['output.' seed_mesh '.target' target '.thresh' threshold '.mat']);
            mask_file = fullfile(CBIG_CODE_DIR, 'data', 'templates', 'volume', ...
                'FSL_MNI152_masks', 'SubcorticalLooseMask_MNI1mm_sm6_MNI2mm_bin0.2.nii.gz');
            input_file_txt = fullfile(ref_dir, 'input', 'volList.txt');
            seed_file_txt = fullfile(ref_dir, 'input', 'surfList.txt');
            CBIG_ComputeCorrelationProfileSurf2Vol_noregress(seed_mesh, target, output_file, ...
                threshold, mask_file, input_file_txt, seed_file_txt)
            
            ref = load(fullfile(ref_dir, 'ref_output', ['output.' seed_mesh '.target' target '.thresh' threshold '.mat']));
            output = load(output_file);
            output.profile_size = size(output.surf2vol_correlation_profile);
            output.surf2vol_correlation_profile = output.surf2vol_correlation_profile([1:1000, 20301:21300], :);
            
            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeCorrelationProfileSurf2Vol_noregress, testSurf2Vol")
                % display differences
                disp(['Old size of correlation profile matrix is [ ' num2str(ref.profile_size) ' ]' ])
                disp(['New size of correlation profile matrix is [ ' num2str(output.profile_size) ' ]' ])
                disp(['Max abs diff of correlation profile matrix is ' ...
                    num2str(max(max(abs(ref.surf2vol_correlation_profile - output.surf2vol_correlation_profile)))) ])
                
                % save and load new results
                ref_output_dir = fullfile(ref_dir, 'ref_output');
                ref_output_file = fullfile(ref_output_dir, ['output.' seed_mesh '.target' target '.thresh' threshold '.mat']);
                CBIG_ComputeCorrelationProfileSurf2Vol_noregress(seed_mesh, target, ref_output_file, ...
                threshold, mask_file, input_file_txt, seed_file_txt)
            
                ref_full = load(fullfile(ref_dir, 'ref_output', ['output.' seed_mesh '.target' target '.thresh' threshold '.mat']));
                surf2vol_correlation_profile = ref_full.surf2vol_correlation_profile([1:1000, 20301:21300], :);
                profile_size = size(ref_full.surf2vol_correlation_profile); 
                save(ref_output_file, 'surf2vol_correlation_profile', 'profile_size');
                ref = load(fullfile(ref_dir, 'ref_output', ['output.' seed_mesh '.target' target '.thresh' threshold '.mat']));
            end
            
            assert(isequal(ref.profile_size, output.profile_size), ...
                'Output correlation profile matrix is of wrong size.');
            assert(all(all(abs(ref.surf2vol_correlation_profile - output.surf2vol_correlation_profile) < 1e-12)), ...
                sprintf('Output correlation profile matris differed from reference result by (max abs diff) %f.', ...
                max(max(abs(ref.surf2vol_correlation_profile - output.surf2vol_correlation_profile)))));
            
            rmdir(output_dir, 's');
        end
    end
    
end
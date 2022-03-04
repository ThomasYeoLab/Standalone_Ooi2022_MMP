classdef test_CBIG_ComputeCorrelationProfileVol2Vol2mm < matlab.unittest.TestCase
% Written by Siyi Tang and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods(Test)
        function testVol2Vol(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeCorrelationProfileVol2Vol2mm');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            threshold = '0.1';
            mask_file = fullfile(CBIG_CODE_DIR, 'data', 'templates', 'volume', ...
                'FSL_MNI152_masks', 'SubcorticalLooseMask_MNI1mm_sm6_MNI2mm_bin0.2.nii.gz');
            input_file_txt = fullfile(ref_dir, 'input', 'volList.txt');
            roi_file = fullfile(ref_dir, 'input', 'MNI2mm_aseg_lh_hippocampus.nii.gz');
            regress_bool = 0;
            
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            output_file = fullfile(output_dir, ['Vol2Vol.thresh' threshold '.mat']);
            
            CBIG_ComputeCorrelationProfileVol2Vol2mm(output_file, threshold, mask_file, input_file_txt, roi_file, regress_bool)
            
            ref = load(fullfile(ref_dir, 'ref_output', ['Vol2Vol.thresh' threshold '.mat']));
            output = load(output_file);
            
            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeCorrelationProfileVol2Vol2mm, testVol2Vol")
                % display differences
                disp(['Old size of correlation profile is [ ' num2str(size(ref.vol2vol_correlation_profile)) ' ]' ])
                disp(['New size of correlation profile is [ ' num2str(size(output.vol2vol_correlation_profile)) ' ]' ])
                disp(['Max abs diff of correlation profile is ' ...
                    num2str(max(max(abs(ref.vol2vol_correlation_profile - output.vol2vol_correlation_profile)))) ])
                            
                % save and load new results
                ref_output_dir = fullfile(ref_dir, 'ref_output');
                ref_output_file = fullfile(ref_output_dir, ['Vol2Vol.thresh' threshold '.mat']);
                CBIG_ComputeCorrelationProfileVol2Vol2mm(ref_output_file, threshold, mask_file, ...
                    input_file_txt, roi_file, regress_bool)
                ref = load(fullfile(ref_dir, 'ref_output', ['Vol2Vol.thresh' threshold '.mat']));
            end
            
            assert(isequal(size(ref.vol2vol_correlation_profile),size(output.vol2vol_correlation_profile)), 'Output correlation profile is of wrong size.');
            assert(all(all(abs(ref.vol2vol_correlation_profile - output.vol2vol_correlation_profile) < 1e-12)), ...
                sprintf('Output correlation profile differed from reference by (max abs diff) %f.', ...
                max(max(abs(ref.vol2vol_correlation_profile - output.vol2vol_correlation_profile)))));
            
            rmdir(output_dir, 's');
        end
    end
    
end
classdef test_CBIG_ComputeVolumeCentroid < matlab.unittest.TestCase
% Written by XUE Aihuiping and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test_compute_centroid(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));

            input_file = fullfile('input', 'Schaefer2018_1000Parcels_17Networks_order_FSLMNI152_2mm.nii.gz');
            [center_ras, center_vox, label_list] = CBIG_ComputeVolumeCentroid(input_file, [], [], 1, 100);
            ref_data = load(fullfile('ref_output', 'ref_first100.mat'));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for CBIG_ComputeVolumeCentroid...');
                sprintf('Number of different labels is %d.', sum(label_list ~= ref_data.label_list));
                sprintf('Sum absolute difference of RAS centroid is %f', sum(sum(abs(center_ras - ref_data.center_ras))));
                sprintf('Sum absolute difference of VOX centroid is %f', sum(sum(abs(center_vox - ref_data.center_vox))));
                save(fullfile('ref_output', 'ref_first100.mat'), 'label_list','center_ras', 'center_vox');

            else
                assert(isequal(label_list, ref_data.label_list), sprintf('Labels are different.'))
                assert(all(all(abs(center_ras - ref_data.center_ras) < 1e-12)), ...
                    sprintf('Sum absolute difference of RAS centroid is %f', ...
                    sum(sum(abs(center_ras - ref_data.center_ras)))));
                assert(all(all(abs(center_vox - ref_data.center_vox) < 1e-12)), ...
                    sprintf('Sum absolute difference of VOX centroid is %f', ...
                    sum(sum(abs(center_vox - ref_data.center_vox)))));
            end
        end
    end
end

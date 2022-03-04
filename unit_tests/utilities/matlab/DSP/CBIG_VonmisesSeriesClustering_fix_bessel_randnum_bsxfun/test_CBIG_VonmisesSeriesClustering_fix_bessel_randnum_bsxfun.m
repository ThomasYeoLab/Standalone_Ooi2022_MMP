classdef test_CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun < matlab.unittest.TestCase

    methods (Test)
        function test_fsaverage5_7clusters_1init(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'DSP', ...
                'CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun', 'ref_output');

            num_clusters = 7; num_initialization = 1;
            [status, msg, msgID] = mkdir('output');
            lh_avg_profile = fullfile('output', 'lh.nii.gz');
            rh_avg_profile = fullfile('output', 'rh.nii.gz');

            generate_fsaverage_data(testCase, lh_avg_profile, rh_avg_profile);

            ref_data = load(fullfile(ref_dir, 'test_fsaverage5_7clusters_1init.mat'));
            out_file = fullfile('output', 'test_fsaverage5_7clusters_1init.mat');

            CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun(...
                'fsaverage5', 'cortex', num_clusters, ...
                out_file, lh_avg_profile, rh_avg_profile, ...
                0, num_initialization, 0, 1000, 1);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_fsaverage5_7clusters_1init...');
                copyfile(out_file, fullfile(ref_dir, 'test_fsaverage5_7clusters_1init.mat'));
            else
                verify(load(out_file), ref_data);
            end

            delete(out_file);
        end

        function test_fsaverage5_7clusters_1init_smooth(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'DSP', ...
                'CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun', 'ref_output');

            num_clusters = 7; num_initialization = 1; num_smooth = 3;
            [status, msg, msgID] = mkdir('output');
            lh_avg_profile = fullfile('output', 'lh.nii.gz');
            rh_avg_profile = fullfile('output', 'rh.nii.gz');

            generate_fsaverage_data(testCase, lh_avg_profile, rh_avg_profile);

            ref_data = load(fullfile(ref_dir, 'test_fsaverage5_7clusters_1init_smooth.mat'));
            out_file = fullfile('output', 'test_fsaverage5_7clusters_1init_smooth.mat');

            CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun(...
                'fsaverage5', 'cortex', num_clusters, ...
                out_file, lh_avg_profile, rh_avg_profile, ...
                num_smooth, num_initialization, 0, 1000, 1);

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_fsaverage5_7clusters_1init_smooth...');
                copyfile(out_file, fullfile(ref_dir, 'test_fsaverage5_7clusters_1init_smooth.mat'));
            else
                verify(load(out_file), ref_data);
            end

            delete(out_file);
        end

        function test_fsaverage5_7clusters_1init_normalize(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'DSP', ...
                'CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun', 'ref_output');

            num_clusters = 7; num_initialization = 1; normalize = 1;
            [status, msg, msgID] = mkdir('output');
            lh_avg_profile = fullfile('output', 'lh.nii.gz');
            rh_avg_profile = fullfile('output', 'rh.nii.gz');

            generate_fsaverage_data(testCase, lh_avg_profile, rh_avg_profile);

            ref_data = load(fullfile(ref_dir, 'test_fsaverage5_7clusters_1init_normalize.mat'));
            out_file = fullfile('output', 'test_fsaverage5_7clusters_1init_normalize.mat');

            CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun(...
                'fsaverage5', 'cortex', num_clusters, ...
                out_file, lh_avg_profile, rh_avg_profile, ...
                0, num_initialization, normalize, 2000, 1);

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_fsaverage5_7clusters_1init_normalize...');
                copyfile(out_file, fullfile(ref_dir, 'test_fsaverage5_7clusters_1init_normalize.mat'));
            else
                verify(load(out_file), ref_data);
            end

            delete(out_file);
        end

        function test_fsaverage5_3clusters_3init(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'DSP', ...
                'CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun', 'ref_output');

            num_clusters = 3; num_initialization = 3;
            [status, msg, msgID] = mkdir('output');
            lh_avg_profile = fullfile('output', 'lh.nii.gz');
            rh_avg_profile = fullfile('output', 'rh.nii.gz');

            generate_fsaverage_data(testCase, lh_avg_profile, rh_avg_profile);

            ref_data = load(fullfile(ref_dir, 'test_fsaverage5_3clusters_3init.mat'));
            out_file = fullfile('output', 'test_fsaverage5_3clusters_3init.mat');

            CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun(...
                'fsaverage5', 'cortex', num_clusters, ...
                out_file, lh_avg_profile, rh_avg_profile, ...
                0, num_initialization, 0, 1000, 1);

                if(replace_unittest_flag)
                    disp('Replacing unit test reference results for test_fsaverage5_3clusters_3init...');
                    copyfile(out_file, fullfile(ref_dir, 'test_fsaverage5_3clusters_3init.mat'));
                else
                    verify(load(out_file), ref_data);
                end

            delete(out_file);
        end

        function test_fslr_2clusters_1init(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'DSP', ...
                'CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun', 'ref_output');

            rng(0, 'twister');
            num_clusters = 2; num_initialization = 1;
            [status, msg, msgID] = mkdir('output');

            avg_profile_file = fullfile('output', 'avg_profile.mat');
            profile_mat = rand(64984, 5);
            save(avg_profile_file, 'profile_mat');
            clear profile_mat;

            ref_data = load(fullfile(ref_dir, 'test_fslr_2clusters_1init.mat'));
            out_file = fullfile('output', 'test_fslr_2clusters_1init.mat');
            

            CBIG_VonmisesSeriesClustering_fix_bessel_randnum_bsxfun(...
                'fs_LR_32k', '', num_clusters, ...
                out_file, avg_profile_file, 'NONE', ...
                0, num_initialization, 0, 1000, 1);

            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_fslr_2clusters_1init...');
                copyfile(out_file, fullfile(ref_dir, 'test_fslr_2clusters_1init.mat'));
            else
                verify(load(out_file), ref_data);
            end

            delete(avg_profile_file);
            delete(out_file);
        end

    end

end

function generate_fsaverage_data(testCase, lh_path, rh_path)
    template = MRIread(fullfile('input', 'template.nii.gz'));
    rng(0, 'twister');

    MRIwrite(setfield(template, 'vol', rand(1, 3414, 3, 10)), lh_path);
    MRIwrite(setfield(template, 'vol', rand(1, 3414, 3, 10)), rh_path);
    testCase.addTeardown(@delete, lh_path);
    testCase.addTeardown(@delete, rh_path);
end

function verify(output, ground_truth)
    deviance = max(max(abs(ground_truth.lambda - output.lambda)));
    assert(deviance < 1e-9, sprintf('off by %.9f', deviance));
    deviance = max(max(abs(ground_truth.lowerbound - output.lowerbound)));
    assert(deviance < 1e-9, sprintf('off by %.9f', deviance));
    deviance = max(max(abs(ground_truth.mtc - output.mtc)));
    assert(deviance < 1e-9, sprintf('off by %.9f', deviance));
    deviance = max(max(abs(ground_truth.p - output.p)));
    assert(deviance < 1e-9, sprintf('off by %.9f', deviance));
    assert(all(ground_truth.lh_labels == output.lh_labels));
    assert(all(ground_truth.lh_s == output.lh_s));
    assert(all(ground_truth.rh_labels == output.rh_labels));
    assert(all(ground_truth.rh_s == output.rh_s));
end

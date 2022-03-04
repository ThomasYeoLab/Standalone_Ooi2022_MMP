classdef test_CBIG_SPGrad_workflow < matlab.unittest.TestCase
% Written by Ru(by) Kong and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test_example(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'utilities', 'matlab', 'speedup_gradients', 'examples', 'ref_results');
            out_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'speedup_gradients', 'output');
            CBIG_SPGrad_example_wrapper(out_dir);

            % compare results
            % check gradient map
            ref_grad = fullfile(ref_dir, 'sub1', 'gradients_edge_density.dtseries.nii');
            out_grad = fullfile(out_dir, 'sub1', 'gradients_edge_density.dtseries.nii');

            ref_grad_data = ft_read_cifti(ref_grad);
            out_grad_data = ft_read_cifti(out_grad);
            
            assert(CBIG_nanmean(abs(ref_grad_data.dtseries - out_grad_data.dtseries)) < 1e-12), ...
            sprintf('Gradient map differed from reference by (mean abs diff) %f.', ...
            CBIG_nanmean(abs(ref_grad_data.dtseries - out_grad_data.dtseries)));
            
            % check diffusion embedding matrices
            ref_emb = fullfile(ref_dir, 'sub1', 'lh_emb_100_distance_matrix.mat');
            out_emb = fullfile(out_dir, 'sub1', 'lh_emb_100_distance_matrix.mat');

            ref_emb_data = load(ref_emb);
            out_emb_data = load(out_emb);

            assert(CBIG_nanmean(abs(ref_emb_data.emb(:)- out_emb_data.emb(:))) < 1e-12), ...
            sprintf('Diffusion embedding matrix differed from reference by (mean abs diff) %f.', ...
            CBIG_nanmean(abs(ref_emb_data.emb(:)- out_emb_data.emb(:))));
            
            rmdir(out_dir, 's');

        end

    end

end

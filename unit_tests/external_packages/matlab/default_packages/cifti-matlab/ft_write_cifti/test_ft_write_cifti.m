classdef test_ft_write_cifti < matlab.unittest.TestCase

    methods (Test)
        function random_dtseries_read_write(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            [status, msg, msgID] = mkdir('output');
            path = fullfile('input', 'Schaefer2018_400Parcels_7Networks_order.dscalar.nii');
            template = ft_read_cifti(path);
            template.time = 1:2;
            template.dimord = 'pos_time';

            rng(0, 'twister');
            generated_series = rand(size(template.dscalar, 1), 2);

            template.dtseries = generated_series;
            ft_write_cifti(fullfile('output', 'test'), template, 'parameter', 'dtseries');            
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of ft_write_cifti...')
                movefile(fullfile('output', 'test.dtseries.nii'), fullfile('ref_output', 'test.dtseries.nii'));                
            else 
                ref_file = ft_read_cifti(fullfile('ref_output', 'test.dtseries.nii'));
                saved_file = ft_read_cifti(fullfile('output', 'test.dtseries.nii'));
                % this unit test also test reading dtseries using ft_read_cifti
                assert(all(all(abs(saved_file.dtseries - ref_file.dtseries) < 1e-7)));
                delete(fullfile('output', 'test.dtseries.nii'));
            end
        end
    end
end

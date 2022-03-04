classdef test_ft_read_cifti < matlab.unittest.TestCase

    methods (Test)
        function read_dlabel(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            parc = ft_read_cifti(fullfile('input', 'Schaefer2018_400Parcels_7Networks_order.dlabel.nii'), 'mapname', 'array');
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of ft_read_cifti, dlabel case...')
                dlabel_true = parc.dlabel;
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'matlab', ...
                    'default_packages', 'cifti-matlab', 'ft_read_cifti', 'ref_output', ...
                    'Schaefer2018_400Parcels_7Networks_order_dlabel.mat'), 'dlabel_true');             
            else 
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'matlab', ...
                    'default_packages', 'cifti-matlab', 'ft_read_cifti', 'ref_output', ...
                    'Schaefer2018_400Parcels_7Networks_order_dlabel.mat'));
                assert(all(size(parc.dlabel, 1) == 64984), 'incorrect number of vertices');
                assert(all(size(parc.brainstructure, 1) == 64984), 'incorrect number of vertices');
                assert(all(size(parc.dlabellabel) == [1 400]), 'incorrect number of parcels');
                assert(isequaln(parc.dlabel, dlabel_true), 'incorrect dlabel');
            end

        end

        function read_dscalar(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            data = ft_read_cifti(fullfile('input', 'Schaefer2018_400Parcels_7Networks_order.dscalar.nii'));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results of ft_read_cifti, dscalar case...')
                dscalar_true = data.dscalar;
                save(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'matlab', ...
                    'default_packages', 'cifti-matlab', 'ft_read_cifti', 'ref_output', ...
                    'Schaefer2018_400Parcels_7Networks_order_dscalar.mat'), 'dscalar_true');             
            else
                load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'matlab', ...
                    'default_packages', 'cifti-matlab', 'ft_read_cifti', 'ref_output', ...
                    'Schaefer2018_400Parcels_7Networks_order_dscalar.mat'));
                assert(all(size(data.brainstructure, 1) == 64984), 'incorrect number of vertices');
                assert(all(size(data.dscalar) == [64984 1]));
                assert(isequaln(data.dscalar, dscalar_true), 'incorrect dscalar');
            end
        end

    end
end

classdef test_CBIG_ProjectMNI2fsaverage_Ants < matlab.unittest.TestCase
    % Written by Siyi Tang and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        function testLinearInterpFsaverage(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'transforms', 'CBIG_ProjectMNI2fsaverage_Ants');
            
            input.vol = reshape(1:109*91*91, 109, 91, 91);
            input.vox2ras = [-2     0     0    90; ...
                0     2     0  -126; ...
                0     0     2   -72; ...
                0     0     0     1];
            
            [lh_proj, rh_proj] = CBIG_ProjectMNI2fsaverage_Ants(input, 'fsaverage', 'linear');
            
            % load reference result
            ref_output = load([ref_dir '/ref_output/result_linearInterpFsaverage.mat']);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for CBIG_ProjectMNI2fsaverage_Ants linear Interp.');
                save('ref_output/result_linearInterpFsaverage.mat','lh_proj','rh_proj');
                if(~isequal(size(ref_output.lh_proj),size(lh_proj)))
                    sprintf('lh_proj has incorrect dimension.')
                end
                if(~isequal(size(ref_output.rh_proj),size(rh_proj)))
                    sprintf('rh_proj has incorrect dimension.')
                end
                sprintf('lh_proj result differed (max abs diff) by %f.', max(max(abs(ref_output.lh_proj - lh_proj))));
                sprintf('rh_proj result differed (max abs diff) by %f.', max(max(abs(ref_output.rh_proj - rh_proj))));

            else
                assert(isequal(size(ref_output.lh_proj),size(lh_proj)), 'lh_proj has incorrect dimension.');
                assert(isequal(size(ref_output.rh_proj),size(rh_proj)), 'rh_proj has incorrect dimension.');
                assert(all(all(abs(ref_output.lh_proj - lh_proj) < 1e-12)), sprintf('lh_proj result differed (max abs diff) by %f.', max(max(abs(ref_output.lh_proj - lh_proj)))));
                assert(all(all(abs(ref_output.rh_proj - rh_proj) < 1e-12)), sprintf('rh_proj result differed (max abs diff) by %f.', max(max(abs(ref_output.rh_proj - rh_proj)))));
            end
        end
        
        function testNearestInterpFsaverage5(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'transforms', 'CBIG_ProjectMNI2fsaverage_Ants');
            
            input.vol = reshape(1:109*91*91, 109, 91, 91);
            input.vox2ras = [-2     0     0    90; ...
                0     2     0  -126; ...
                0     0     2   -72; ...
                0     0     0     1];
            
            [lh_proj, rh_proj] = CBIG_ProjectMNI2fsaverage_Ants(input, 'fsaverage5', 'nearest');
            
            % load reference result
            ref_output = load([ref_dir '/ref_output/result_nearestInterpFsaverage5.mat']);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for CBIG_ProjectMNI2fsaverage_Ants nearest Interp.');
                save('ref_output/result_nearestInterpFsaverage5.mat','lh_proj','rh_proj');
                if(~isequal(size(ref_output.lh_proj),size(lh_proj)))
                    sprintf('lh_proj has incorrect dimension.')
                end
                if(~isequal(size(ref_output.rh_proj),size(rh_proj)))
                    sprintf('rh_proj has incorrect dimension.')
                end
                sprintf('lh_proj result differed (max abs diff) by %f.', max(max(abs(ref_output.lh_proj - lh_proj))));
                sprintf('rh_proj result differed (max abs diff) by %f.', max(max(abs(ref_output.rh_proj - rh_proj))));
                
            else
                assert(isequal(size(ref_output.lh_proj),size(lh_proj)), 'lh_proj has incorrect dimension.');
                assert(isequal(size(ref_output.rh_proj),size(rh_proj)), 'rh_proj has incorrect dimension.');
                assert(all(all(abs(ref_output.lh_proj - lh_proj) < 1e-12)), sprintf('lh_proj result differed (max abs diff) by %f.', max(max(abs(ref_output.lh_proj - lh_proj)))));
                assert(all(all(abs(ref_output.rh_proj - rh_proj) < 1e-12)), sprintf('rh_proj result differed (max abs diff) by %f.', max(max(abs(ref_output.rh_proj - rh_proj)))));
            end
        end
    end
    
end

classdef test_CBIG_resample_fslr < matlab.unittest.TestCase
%
% Target function:
%                 [lh_data_resample, rh_data_resample] = CBIG_resample_fslr(lh_data, rh_data, orig_mesh, resample_mesh, type_of_data, folder_to_write, registration_version)
%
% Case design:
%                 Case 1 = resample label(integer) data from fsLR32k to
%                 fsLR164k, using registration version20170508
%                 (Coarse to Fine)
%
%                 Case 2 = resample metric(float) data from fsLR164k to
%                 fsLR32k, using registration version20160827
%                 (Fine to Coarse)
%
% Written by Yang Qing and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    
    methods (Test)
        function test_Label_version20170508_Coarse2Fine_Case(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_resample_fslr/';
            
            InputDir = fullfile(UnitTestDir, FolderStructure, 'input');
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, 'output', 'test_Label_version20170508_Coarse2Fine_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_lh_data_resample_label_version20170508_Coarse2Fine.mat')); % load in ref_lh_data_resample
            load(fullfile(ReferenceDir, '/ref_rh_data_resample_label_version20170508_Coarse2Fine.mat')); % load in ref_rh_data_resample
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % load input label data
            load(fullfile(InputDir, '/lh_labels_fslr32k.mat')); % load in lh fslr32k data: lh_labels
            load(fullfile(InputDir, '/rh_labels_fslr32k.mat')); % load in rh fslr32k data: rh_labels
            
            % convert input to integer (label)
            lh_labels = int32(lh_labels);
            rh_labels = int32(rh_labels);
            
            % parameter setting
            orig_mesh = 'fs_LR_32k';
            resample_mesh = 'fs_LR_164k';
            type_of_data = 'label';
            folder_to_write = [OutputDir '/tmp'];
            registration_version = '20170508';
            
            % generate new resampled data
            [lh_data_resample, rh_data_resample] = CBIG_resample_fslr(lh_labels, rh_labels, ...
                orig_mesh, resample_mesh, type_of_data, folder_to_write, registration_version);
            
            % check lh_data_resample
            lh_diff = lh_data_resample - ref_lh_data_resample;
            % check rh_data_resample
            rh_diff = rh_data_resample - ref_rh_data_resample;
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_resample_fslr, test_Label_version20170508_Coarse2Fine_Case...');
                
                disp(['Total difference for lh_data_resample: ' num2str(sum(sum(abs(lh_diff))))]);
                ref_lh_data_resample = lh_data_resample;
                
                disp(['Total difference for rh_data_resample: ' num2str(sum(sum(abs(rh_diff))))]);
                ref_rh_data_resample = rh_data_resample;
                
                
                save(fullfile(ReferenceDir, '/ref_lh_data_resample_label_version20170508_Coarse2Fine.mat'), 'ref_lh_data_resample');
                save(fullfile(ReferenceDir, '/ref_rh_data_resample_label_version20170508_Coarse2Fine.mat'), 'ref_rh_data_resample');
            else
                
                assert(isequal(size(lh_data_resample), size(ref_lh_data_resample)), ...
                    'result lh_data_resample is different')
                
                assert(all(all(abs(lh_diff) < 1e-12)), ...
                    sprintf('lh_data_resample result off by %f (sum absolute difference)', ...
                    sum(sum(abs(lh_diff)))));
                
                assert(isequal(size(rh_data_resample), size(ref_rh_data_resample)), ...
                    'result rh_data_resample is different')
                
                assert(all(all(abs(rh_diff) < 1e-12)), ...
                    sprintf('rh_data_resample result off by %f (sum absolute difference)', ...
                    sum(sum(abs(rh_diff)))));
                
            end
            % remove intermediate output data (IMPORTANT)
            rmdir(OutputDir, 's');
        end
        
        function test_Metric_version20160827_Fine2Coarse_Case(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_resample_fslr/';
            
            InputDir = fullfile(UnitTestDir, FolderStructure, 'input');
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, 'output', 'test_Metric_version20160827_Fine2Coarse_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_lh_data_resample_metric_version20160827_Fine2Coarse.mat')); % load in ref_lh_data_resample
            load(fullfile(ReferenceDir, '/ref_rh_data_resample_metric_version20160827_Fine2Coarse.mat')); % load in ref_rh_data_resample
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % load input label data
            load(fullfile(InputDir, '/lh_labels_fslr164k.mat')); % load in lh fslr164k data: lh_labels
            load(fullfile(InputDir, '/rh_labels_fslr164k.mat')); % load in rh fslr164k data: rh_labels
            
            % convert input to float (metric)
            lh_labels = double(lh_labels) - 0.5;
            rh_labels = double(rh_labels) - 0.5;
            
            % parameter setting
            orig_mesh = 'fs_LR_164k';
            resample_mesh = 'fs_LR_32k';
            type_of_data = 'metric';
            folder_to_write = [OutputDir '/tmp'];
            registration_version = '20160827';
            
            % generate new resampled data
            [lh_data_resample, rh_data_resample] = CBIG_resample_fslr(lh_labels, rh_labels, ...
                orig_mesh, resample_mesh, type_of_data, folder_to_write, registration_version);
            
            % check lh_data_resample
            lh_diff = lh_data_resample - ref_lh_data_resample;
            % check rh_data_resample
            rh_diff = rh_data_resample - ref_rh_data_resample;
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_resample_fslr, test_Metric_version20160827_Fine2Coarse_Case...');
                
                disp(['Total difference for lh_data_resample: ' num2str(sum(sum(abs(lh_diff))))]);
                ref_lh_data_resample = lh_data_resample;
                
                disp(['Total difference for rh_data_resample: ' num2str(sum(sum(abs(rh_diff))))]);
                ref_rh_data_resample = rh_data_resample;
                
                
                save(fullfile(ReferenceDir, '/ref_lh_data_resample_metric_version20160827_Fine2Coarse.mat'), 'ref_lh_data_resample');
                save(fullfile(ReferenceDir, '/ref_rh_data_resample_metric_version20160827_Fine2Coarse.mat'), 'ref_rh_data_resample');
            else
                
                assert(isequal(size(lh_data_resample), size(ref_lh_data_resample)), ...
                    'result lh_data_resample is different')
                
                assert(all(all(abs(lh_diff) < 1e-12)), ...
                    sprintf('lh_data_resample result off by %f (sum absolute difference)', ...
                    sum(sum(abs(lh_diff)))));
                
                assert(isequal(size(rh_data_resample), size(ref_rh_data_resample)), ...
                    'result rh_data_resample is different')
                
                assert(all(all(abs(rh_diff) < 1e-12)), ...
                    sprintf('rh_data_resample result off by %f (sum absolute difference)', ...
                    sum(sum(abs(rh_diff)))));
                
            end
            % remove intermediate output data (IMPORTANT)
            rmdir(OutputDir, 's');
            
        end
    end
end
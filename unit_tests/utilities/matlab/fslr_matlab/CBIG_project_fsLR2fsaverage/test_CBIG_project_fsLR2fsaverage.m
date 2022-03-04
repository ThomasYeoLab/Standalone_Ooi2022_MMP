classdef test_CBIG_project_fsLR2fsaverage < matlab.unittest.TestCase
%
% Target function:
%                 [lh_FS7_data,rh_FS7_data] = CBIG_project_fsLR2fsaverage(lh_fsLR_data,rh_fsLR_data,fsLR_mesh,type_of_data,folder_to_write,registration_version)
%
% Case design:
%                 Case 1 = project fsLR32k label(integer) data to fsaverage
%                 space using registration version20170508
%                 Case 2 = project fsLR32k metric(float) data to fsaverage
%                 space using registration version20160827
%
% Written by Yang Qing and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        function test_Label_version20170508_Case(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_project_fsLR2fsaverage/';
            
            InputDir = fullfile(UnitTestDir, FolderStructure, 'input');
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, 'output', 'test_Label_version20170508_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_lh_FS7_data_label_version20170508.mat')); % load in ref lh_FS7_data
            load(fullfile(ReferenceDir, '/ref_rh_FS7_data_label_version20170508.mat')); % load in ref lh_FS7_data
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % load input label data
            load(fullfile(InputDir, '/lh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % load in lh fslr32k data: lh_labels
            load(fullfile(InputDir, '/rh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % load in rh fslr32k data: rh_labels
            
            % convert input to integer (label)
            lh_labels = int32(lh_labels);
            rh_labels = int32(rh_labels);
            
            % parameter setting
            fsLR_mesh = 'fs_LR_32k';
            type_of_data = 'label';
            folder_to_write = [OutputDir '/tmp'];
            registration_version = '20170508';
            [lh_FS7_data, rh_FS7_data] = ...
                CBIG_project_fsLR2fsaverage(lh_labels,rh_labels,fsLR_mesh,type_of_data,folder_to_write,registration_version);
            
            % check lh_FS7_data
            lh_diff = lh_FS7_data - ref_lh_FS7_data;
            % check rh_FS7_data
            rh_diff = rh_FS7_data - ref_rh_FS7_data;
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_project_fsLR2fsaverage, test_Label_version20170508_Case...');
                
                disp(['Total difference for lh_FS7_data: ' num2str(sum(sum(abs(lh_diff))))]);
                ref_lh_FS7_data = lh_FS7_data;
                
                disp(['Total difference for rh_FS7_data: ' num2str(sum(sum(abs(rh_diff))))]);
                ref_rh_FS7_data = rh_FS7_data;
                
                
                save(fullfile(ReferenceDir, '/ref_lh_FS7_data_label_version20170508.mat'), 'ref_lh_FS7_data');
                save(fullfile(ReferenceDir, '/ref_rh_FS7_data_label_version20170508.mat'), 'ref_rh_FS7_data');
            else
                
                assert(isequal(size(lh_FS7_data), size(ref_lh_FS7_data)), ...
                    'size of result lh_FS7_data is different')
                
                assert(all(all(abs(lh_diff) < 1e-12)), ...
                    sprintf('lh_FS7_data result off by %f (sum absolute difference)', ...
                    sum(sum(abs(lh_diff)))));
                
                assert(isequal(size(rh_FS7_data), size(ref_rh_FS7_data)), ...
                    'size of result rh_FS7_data is different')
                
                assert(all(all(abs(rh_diff) < 1e-12)), ...
                    sprintf('rh_FS7_data result off by %f (sum absolute difference)', ...
                    sum(sum(abs(rh_diff)))));
                
            end
            % remove intermediate output data (IMPORTANT)
            rmdir(OutputDir, 's');
        end
        
        
        function test_Metric_version20160827_Case(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_project_fsLR2fsaverage/';
            
            InputDir = fullfile(UnitTestDir, FolderStructure, 'input');
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, 'output', 'test_Metric_version20160827_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_lh_FS7_data_metric_version20160827.mat')); % load in ref lh_FS7_data
            load(fullfile(ReferenceDir, '/ref_rh_FS7_data_metric_version20160827.mat')); % load in ref lh_FS7_data
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % load input label data
            load(fullfile(InputDir, '/lh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % load in lh fslr32k data: lh_labels
            load(fullfile(InputDir, '/rh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % load in rh fslr32k data: rh_labels
            
            % convert input to float (metric)
            lh_labels = single(lh_labels - 0.5);
            rh_labels = single(rh_labels - 0.5);
            
            % parameter setting
            fsLR_mesh = 'fs_LR_32k';
            type_of_data = 'label';
            folder_to_write = [OutputDir '/tmp'];
            registration_version = '20160827';
            [lh_FS7_data, rh_FS7_data] = ...
                CBIG_project_fsLR2fsaverage(lh_labels,rh_labels,fsLR_mesh,type_of_data,folder_to_write,registration_version);
            
            % check lh_FS7_data
            lh_diff = lh_FS7_data - ref_lh_FS7_data;
            % check rh_FS7_data
            rh_diff = rh_FS7_data - ref_rh_FS7_data;
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_project_fsLR2fsaverage, test_Metric_version20160827_Case...');
                
                disp(['Total difference for lh_FS7_data: ' num2str(sum(sum(abs(lh_diff))))]);
                ref_lh_FS7_data = lh_FS7_data;
                
                disp(['Total difference for rh_FS7_data: ' num2str(sum(sum(abs(rh_diff))))]);
                ref_rh_FS7_data = rh_FS7_data;
                
                
                save(fullfile(ReferenceDir, '/ref_lh_FS7_data_metric_version20160827.mat'), 'ref_lh_FS7_data');
                save(fullfile(ReferenceDir, '/ref_rh_FS7_data_metric_version20160827.mat'), 'ref_rh_FS7_data');
            else
                
                assert(isequal(size(lh_FS7_data), size(ref_lh_FS7_data)), ...
                    'size of result lh_FS7_data is different')
                
                assert(all(all(abs(lh_diff) < 1e-12)), ...
                    sprintf('lh_FS7_data result off by %f (sum absolute difference)', ...
                    sum(sum(abs(lh_diff)))));
                
                assert(isequal(size(rh_FS7_data), size(ref_rh_FS7_data)), ...
                    'size of result rh_FS7_data is different')
                
                assert(all(all(abs(rh_diff) < 1e-12)), ...
                    sprintf('rh_FS7_data result off by %f (sum absolute difference)', ...
                    sum(sum(abs(rh_diff)))));
                
            end
            % remove intermediate output data (IMPORTANT)
            rmdir(OutputDir, 's');
            
        end
    end
end
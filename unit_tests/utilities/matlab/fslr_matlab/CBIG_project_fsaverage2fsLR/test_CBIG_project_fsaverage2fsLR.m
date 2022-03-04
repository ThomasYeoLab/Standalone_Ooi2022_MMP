classdef test_CBIG_project_fsaverage2fsLR < matlab.unittest.TestCase
%
% Target function:
%                 [lh_fsLR_32k_data,rh_fsLR_32k_data,lh_fsLR_164k_data,rh_fsLR_164k_data] = CBIG_project_fsaverage2fsLR(lh_FS_data,rh_FS_data,FS_mesh,type_of_data,folder_to_write,registration_version)
%
% Case design:
%                 Case 1 = project fsaverage5 label(integer) data to fsLR space using registration version20170508
%                 Case 2 = project fsaverage5 metric(float) data to fsLR space using registration version20160827
%
% Written by Yang Qing and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        function test_Label_version20170508_Case(testCase)
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_project_fsaverage2fsLR';
            
            InputDir = fullfile(UnitTestDir, FolderStructure, 'input');
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, 'output', 'test_Label_version20170508_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_lh_fsLR_32k_data_lable_version20170508.mat')); % load in ref_lh_fsLR_32k_data
            load(fullfile(ReferenceDir, '/ref_rh_fsLR_32k_data_lable_version20170508.mat')); % load in ref_rh_fsLR_32k_data
            load(fullfile(ReferenceDir, '/ref_lh_fsLR_164k_data_lable_version20170508.mat')); % load in ref_lh_fsLR_164k_data
            load(fullfile(ReferenceDir, '/ref_rh_fsLR_164k_data_lable_version20170508.mat')); % load in ref_rh_fsLR_164k_data
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % load input label data
            load(fullfile(InputDir, '/lh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % load in a lh fs5 label file: lh_labels
            load(fullfile(InputDir, '/rh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % load in a rh fs5 label file: rh_labels
            
            % convert input to integer (label)
            lh_labels = int32(lh_labels);
            rh_labels = int32(rh_labels);
            
            % parameter setting
            FS_mesh = 'fsaverage5';
            type_of_data = 'label';
            folder_to_write = [OutputDir '/tmp'];
            registration_version = '20170508';
            [lh_fsLR_32k_data,rh_fsLR_32k_data,lh_fsLR_164k_data,rh_fsLR_164k_data] = ...
                CBIG_project_fsaverage2fsLR(lh_labels,rh_labels,FS_mesh,type_of_data,folder_to_write,registration_version);
            
            % check results
            % check lh_fsLR_32k_data
            lh_32k_diff = lh_fsLR_32k_data - ref_lh_fsLR_32k_data;
            % check rh_fsLR_32k_data
            rh_32k_diff = rh_fsLR_32k_data - ref_rh_fsLR_32k_data;
            % check lh_fsLR_164k_data
            lh_64k_diff = lh_fsLR_164k_data - ref_lh_fsLR_164k_data;
            % check rh_fsLR_164k_data
            rh_64k_diff = rh_fsLR_164k_data - ref_rh_fsLR_164k_data;
            
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_project_fsaverage2fsLR, test_Label_version20170508_Case...');
                
                disp(['Total difference for lh_fsLR_32k_data: ' num2str(sum(sum(abs(lh_32k_diff))))]);
                disp(['Total difference for lh_fsLR_32k_data vertices: ' num2str(sum(sum(lh_32k_diff~=0)))]);
                ref_lh_fsLR_32k_data = lh_fsLR_32k_data;
                
                disp(['Total difference for rh_fsLR_32k_data: ' num2str(sum(sum(abs(rh_32k_diff))))]);
                disp(['Total difference for rh_fsLR_32k_data vertices: ' num2str(sum(sum(rh_32k_diff~=0)))]);
                ref_rh_fsLR_32k_data = rh_fsLR_32k_data;
                
                disp(['Total difference for lh_fsLR_164k_data: ' num2str(sum(sum(abs(lh_64k_diff))))]);
                disp(['Total difference for lh_fsLR_164k_data vertices: ' num2str(sum(sum(lh_64k_diff~=0)))]);
                ref_lh_fsLR_164k_data = lh_fsLR_164k_data;
                
                disp(['Total difference for rh_fsLR_164k_data: ' num2str(sum(sum(abs(rh_64k_diff))))]);
                disp(['Total difference for rh_fsLR_164k_data vertices: ' num2str(sum(sum(rh_64k_diff~=0)))]);
                ref_rh_fsLR_164k_data = rh_fsLR_164k_data;
                
                save(fullfile(ReferenceDir, '/ref_lh_fsLR_32k_data_lable_version20170508.mat'), 'ref_lh_fsLR_32k_data');
                save(fullfile(ReferenceDir, '/ref_rh_fsLR_32k_data_lable_version20170508.mat'), 'ref_rh_fsLR_32k_data');
                save(fullfile(ReferenceDir, '/ref_lh_fsLR_164k_data_lable_version20170508.mat'), 'ref_lh_fsLR_164k_data');
                save(fullfile(ReferenceDir, '/ref_rh_fsLR_164k_data_lable_version20170508.mat'), 'ref_rh_fsLR_164k_data');
            else
                
                assert(isequal(size(lh_fsLR_32k_data), size(ref_lh_fsLR_32k_data)), ...
                    sprintf('result lh_fsLR_32k_data is different'))
                
                assert(all(all(abs(lh_32k_diff) < 1e-12)), ...
                    sprintf('lh_fsLR_32k_data result off by %f (sum absolute difference), %d vertices', ...
                    sum(sum(abs(lh_32k_diff))), sum(sum(lh_32k_diff~=0))));
                
                assert(isequal(size(rh_fsLR_32k_data), size(ref_rh_fsLR_32k_data)), ...
                    sprintf('result rh_fsLR_32k_data is different'))
                
                assert(all(all(abs(rh_32k_diff) < 1e-12)), ...
                    sprintf('rh_fsLR_32k_data result off by %f (sum absolute difference), %d vertices', ...
                    sum(sum(abs(rh_32k_diff))), sum(sum(rh_32k_diff~=0))));
                
                assert(isequal(size(lh_fsLR_164k_data), size(ref_lh_fsLR_164k_data)), ...
                    sprintf('result lh_fsLR_164k_data is different'))
                
                assert(all(all(abs(lh_64k_diff) < 1e-12)), ...
                    sprintf('lh_fsLR_164k_data result off by %f (sum absolute difference), %d vertices', ...
                    sum(sum(abs(lh_64k_diff))), sum(sum(lh_64k_diff~=0))));
                
                assert(isequal(size(rh_fsLR_164k_data), size(ref_rh_fsLR_164k_data)), ...
                    sprintf('result rh_fsLR_164k_data is different'))
                
                assert(all(all(abs(rh_64k_diff) < 1e-12)), ...
                    sprintf('rh_fsLR_164k_data result off by %f (sum absolute difference), %d vertices', ...
                    sum(sum(abs(rh_64k_diff))), sum(sum(rh_64k_diff~=0))));
                
            end
            
            % remove intermediate output data (IMPORTANT)
            rmdir(OutputDir, 's');
        end
        
        
        
        function test_Metric_version20160827_Case(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_project_fsaverage2fsLR';
            
            InputDir = fullfile(UnitTestDir, FolderStructure, 'input');
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            OutputDir = fullfile(UnitTestDir, FolderStructure, 'output', 'test_Metric_version20160827_Case'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(OutputDir, 'dir'))
                rmdir(OutputDir, 's')
            end
            mkdir(OutputDir);
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_lh_fsLR_32k_data_metric_version20160827.mat')); % load in ref_lh_fsLR_32k_data
            load(fullfile(ReferenceDir, '/ref_rh_fsLR_32k_data_metric_version20160827.mat')); % load in ref_rh_fsLR_32k_data
            load(fullfile(ReferenceDir, '/ref_lh_fsLR_164k_data_metric_version20160827.mat')); % load in ref_lh_fsLR_164k_data
            load(fullfile(ReferenceDir, '/ref_rh_fsLR_164k_data_metric_version20160827.mat')); % load in ref_rh_fsLR_164k_data
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % load input label data
            load(fullfile(InputDir, '/lh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % load in a lh fs5 label file: lh_labels
            load(fullfile(InputDir, '/rh.Scahefer2018_400Parcels_17Networks_0rder.mat')); % load in a rh fs5 label file: rh_labels
            
            % convert input to float (metric)
            lh_labels = single(lh_labels - 0.5);
            rh_labels = single(rh_labels - 0.5);
            
            % parameter setting
            FS_mesh = 'fsaverage5';
            type_of_data = 'metric';
            folder_to_write = [OutputDir '/tmp'];
            registration_version = '20160827';
            [lh_fsLR_32k_data,rh_fsLR_32k_data,lh_fsLR_164k_data,rh_fsLR_164k_data] = ...
                CBIG_project_fsaverage2fsLR(lh_labels,rh_labels,FS_mesh,type_of_data,folder_to_write,registration_version);
            
            % check results
            % check lh_fsLR_32k_data
            lh_32k_diff = lh_fsLR_32k_data - ref_lh_fsLR_32k_data;
            % check rh_fsLR_32k_data
            rh_32k_diff = rh_fsLR_32k_data - ref_rh_fsLR_32k_data;
            % check lh_fsLR_164k_data
            lh_64k_diff = lh_fsLR_164k_data - ref_lh_fsLR_164k_data;
            % check rh_fsLR_164k_data
            rh_64k_diff = rh_fsLR_164k_data - ref_rh_fsLR_164k_data;
            
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_project_fsaverage2fsLR, test_Metric_version20160827_Case...');
                
                disp(['Total difference for lh_fsLR_32k_data: ' num2str(sum(sum(abs(lh_32k_diff))))]);
                disp(['Total difference for lh_fsLR_32k_data vertices: ' num2str(sum(sum(lh_32k_diff~=0)))]);
                ref_lh_fsLR_32k_data = lh_fsLR_32k_data;
                
                disp(['Total difference for rh_fsLR_32k_data: ' num2str(sum(sum(abs(rh_32k_diff))))]);
                disp(['Total difference for rh_fsLR_32k_data vertices: ' num2str(sum(sum(rh_32k_diff~=0)))]);
                ref_rh_fsLR_32k_data = rh_fsLR_32k_data;
                
                disp(['Total difference for lh_fsLR_164k_data: ' num2str(sum(sum(abs(lh_64k_diff))))]);
                disp(['Total difference for lh_fsLR_164k_data vertices: ' num2str(sum(sum(lh_64k_diff~=0)))]);
                ref_lh_fsLR_164k_data = lh_fsLR_164k_data;
                
                disp(['Total difference for rh_fsLR_164k_data: ' num2str(sum(sum(abs(rh_64k_diff))))]);
                disp(['Total difference for rh_fsLR_164k_data vertices: ' num2str(sum(sum(rh_64k_diff~=0)))]);
                ref_rh_fsLR_164k_data = rh_fsLR_164k_data;
                
                save(fullfile(ReferenceDir, '/ref_lh_fsLR_32k_data_metric_version20160827.mat'), 'ref_lh_fsLR_32k_data');
                save(fullfile(ReferenceDir, '/ref_rh_fsLR_32k_data_metric_version20160827.mat'), 'ref_rh_fsLR_32k_data');
                save(fullfile(ReferenceDir, '/ref_lh_fsLR_164k_data_metric_version20160827.mat'), 'ref_lh_fsLR_164k_data');
                save(fullfile(ReferenceDir, '/ref_rh_fsLR_164k_data_metric_version20160827.mat'), 'ref_rh_fsLR_164k_data');
            else
                
                assert(isequal(size(lh_fsLR_32k_data), size(ref_lh_fsLR_32k_data)), ...
                    sprintf('result lh_fsLR_32k_data is different'))
                
                assert(all(all(abs(lh_32k_diff) < 1e-12)), ...
                    sprintf('lh_fsLR_32k_data result off by %f (sum absolute difference), %d vertices', ...
                    sum(sum(abs(lh_32k_diff))), sum(sum(lh_32k_diff~=0))));
                
                assert(isequal(size(rh_fsLR_32k_data), size(ref_rh_fsLR_32k_data)), ...
                    sprintf('result rh_fsLR_32k_data is different'))
                
                assert(all(all(abs(rh_32k_diff) < 1e-12)), ...
                    sprintf('rh_fsLR_32k_data result off by %f (sum absolute difference), %d vertices', ...
                    sum(sum(abs(rh_32k_diff))), sum(sum(rh_32k_diff~=0))));
                
                assert(isequal(size(lh_fsLR_164k_data), size(ref_lh_fsLR_164k_data)), ...
                    sprintf('result lh_fsLR_164k_data is different'))
                
                assert(all(all(abs(lh_64k_diff) < 1e-12)), ...
                    sprintf('lh_fsLR_164k_data result off by %f (sum absolute difference), %d vertices', ...
                    sum(sum(abs(lh_64k_diff))), sum(sum(lh_64k_diff~=0))));
                
                assert(isequal(size(rh_fsLR_164k_data), size(ref_rh_fsLR_164k_data)), ...
                    sprintf('result rh_fsLR_164k_data is different'))
                
                assert(all(all(abs(rh_64k_diff) < 1e-12)), ...
                    sprintf('rh_fsLR_164k_data result off by %f (sum absolute difference), %d vertices', ...
                    sum(sum(abs(rh_64k_diff))), sum(sum(rh_64k_diff~=0))));
                
            end
            % remove intermediate output data (IMPORTANT)
            rmdir(OutputDir, 's');
            
        end
    end
end
classdef test_CBIG_ComputeCorrelationProfile < matlab.unittest.TestCase
% Written by Siyi Tang, Jingwei Li and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testFsaverage(TestCase)
            % set up directories and input
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeCorrelationProfile');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            seed_mesh = 'fsaverage3';
            target = 'fsaverage5';
            threshold = '0.1';
            varargin_text1 = fullfile(ref_dir, 'input', 'testFsaverage_varargin1.txt');
            varargin_text2 = fullfile(ref_dir, 'input', 'testFsaverage_varargin2.txt');
            outlier_text = fullfile(ref_dir, 'input', 'testFsaverage_outliers.txt');
            split_data = '0';
            
            % save output data
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            output_file1 = fullfile(output_dir, ['lh.roi' seed_mesh '.thresh' threshold ...
                '.surf2surf_profile_scrub.nii.gz']);
            output_file2 = fullfile(output_dir, ['rh.roi' seed_mesh '.thresh' threshold ...
                '.surf2surf_profile_scrub.nii.gz']);
            CBIG_ComputeCorrelationProfile(seed_mesh, target, output_file1, output_file2, ...
                threshold, varargin_text1, varargin_text2, outlier_text, split_data);
            
            % read reference data
            lh_ref_struc = MRIread(fullfile(ref_dir, 'ref_output', ['lh.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub.nii.gz']));
            rh_ref_struc = MRIread(fullfile(ref_dir, 'ref_output', ['rh.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub.nii.gz']));
            lh_ref_fields = fieldnames(lh_ref_struc);
            rh_ref_fields = fieldnames(rh_ref_struc);
            
            lh_output_struc = MRIread(output_file1);
            rh_output_struc = MRIread(output_file2);
            lh_output_fields = fieldnames(lh_output_struc);
            rh_output_fields = fieldnames(rh_output_struc);
            
            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeCorrelationProfile, testFsaverage")
                % display differences
                if ~isequal(size(lh_output_fields),size(lh_ref_fields))
                    disp("lh fields are different")
                else
                    for i = 1:length(lh_output_fields)
                        if (~isequal(lh_output_fields{i}, 'fspec')) && (~isequal(lh_output_fields{i}, 'pwd'))
                            curr_output = getfield(lh_output_struc, lh_output_fields{i});
                            curr_ref = getfield(lh_ref_struc, lh_ref_fields{i});                          
                            disp(['Old size of lh ' lh_output_fields{i} ' is [ ' num2str(size(curr_ref)) ' ]' ])
                            disp(['New size of lh ' lh_output_fields{i} ' is [ ' num2str(size(curr_output)) ' ]' ])
                            if ~isequal(curr_output, curr_ref)
                                disp(['lh ' lh_output_fields{i} 'is different from reference'])
                            end
                        end
                    end
                end
                
                if ~isequal(size(rh_output_fields),size(rh_ref_fields))
                    disp("rh fields are different")
                else
                    for i = 1:length(rh_output_fields)
                        if (~isequal(rh_output_fields{i}, 'fspec')) && (~isequal(rh_output_fields{i}, 'pwd'))
                            curr_output = getfield(rh_output_struc, rh_output_fields{i});
                            curr_ref = getfield(rh_ref_struc, rh_ref_fields{i});                          
                            disp(['Old size of rh ' rh_output_fields{i} ' is [ ' num2str(size(curr_ref)) ' ]' ])
                            disp(['New size of rh ' rh_output_fields{i} ' is [ ' num2str(size(curr_output)) ' ]' ])
                            if ~isequal(curr_output, curr_ref)
                                disp(['rh ' rh_output_fields{i} 'is different from reference'])
                            end
                        end
                    end
                    
                end
                
                % save and load new results
                ref_output_dir = fullfile(ref_dir, 'ref_output');
                ref_output_file1 = fullfile(ref_output_dir, ['lh.roi' seed_mesh '.thresh' threshold ...
                '.surf2surf_profile_scrub.nii.gz']);
                ref_output_file2 = fullfile(ref_output_dir, ['rh.roi' seed_mesh '.thresh' threshold ...
                '.surf2surf_profile_scrub.nii.gz']);
                CBIG_ComputeCorrelationProfile(seed_mesh, target, ref_output_file1, ref_output_file2, ...
                threshold, varargin_text1, varargin_text2, outlier_text, split_data);
            
                lh_ref_struc = MRIread(fullfile(ref_dir, 'ref_output', ['lh.roi' seed_mesh '.thresh' ...
                    threshold '.surf2surf_profile_scrub.nii.gz']));
                rh_ref_struc = MRIread(fullfile(ref_dir, 'ref_output', ['rh.roi' seed_mesh '.thresh' ...
                    threshold '.surf2surf_profile_scrub.nii.gz']));
                lh_ref_fields = fieldnames(lh_ref_struc);
                rh_ref_fields = fieldnames(rh_ref_struc);

                lh_output_struc = MRIread(output_file1);
                rh_output_struc = MRIread(output_file2);
                lh_output_fields = fieldnames(lh_output_struc);
                rh_output_fields = fieldnames(rh_output_struc);
            end
            
            % check whether output is same as reference
            assert(isequal(size(lh_output_fields),size(lh_ref_fields)), ...
                'lh output structure is of wrong size.');
            assert(isequal(size(rh_output_fields),size(rh_ref_fields)), ...
                'rh output structure is of wrong size.');
            
            for i = 1:length(lh_output_fields)
                if (~isequal(lh_output_fields{i}, 'fspec')) && (~isequal(lh_output_fields{i}, 'pwd'))
                    curr_output = getfield(lh_output_struc, lh_output_fields{i});
                    curr_ref = getfield(lh_ref_struc, lh_ref_fields{i});
                    
                    assert(isequal(size(curr_output),size(curr_ref)), ...
                        sprintf('lh field %s is of wrong size.', lh_output_fields{i}));
                    assert(isequal(curr_output, curr_ref), ...
                        sprintf('lh field %s is different from reference result.', lh_output_fields{i}));
                end
            end
            
            for i = 1:length(rh_output_fields)
                if (~isequal(rh_output_fields{i}, 'fspec')) && (~isequal(rh_output_fields{i}, 'pwd'))
                    curr_output = getfield(rh_output_struc, rh_output_fields{i});
                    curr_ref = getfield(rh_ref_struc, rh_ref_fields{i});
                    
                    assert(isequal(size(curr_output),size(curr_ref)), ...
                        sprintf('rh field %s is of wrong size.', rh_output_fields{i}));
                    assert(isequal(curr_output, curr_ref), ...
                        sprintf('rh field %s is different from reference result.', rh_output_fields{i}));
                end
            end
            
            rmdir(output_dir, 's');
            
        end
        
        %%
        function testFslr(TestCase)
            % set up directories and input
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeCorrelationProfile');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            seed_mesh = 'fs_LR_900';
            target = 'fs_LR_32k';
            threshold = '0.2';
            varargin_text1 = fullfile(ref_dir, 'input', 'testFslr_varargin1.txt');
            varargin_text2 = 'NONE';
            outlier_text = fullfile(ref_dir, 'input', 'testFslr_outliers.txt');
            split_data = '1';
            
            % save output data
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            
            output_file1 = fullfile(output_dir, ['testFslr.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub.mat']);
            output_file2 = 'NONE';
            CBIG_ComputeCorrelationProfile(seed_mesh, target, output_file1, output_file2, ...
                threshold, varargin_text1, varargin_text2, outlier_text, split_data);
            
            % read reference data
            ref_result1 = load(fullfile(ref_dir, 'ref_output', ['testFslr.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub_1.mat']));
            ref_result2 = load(fullfile(ref_dir, 'ref_output', ['testFslr.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub_2.mat']));

            output1 = load(fullfile(ref_dir, 'output', ['testFslr.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub_1.mat']));
            output2 = load(fullfile(ref_dir, 'output', ['testFslr.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub_2.mat']));
            
            output1.profile_size = size(output1.profile_mat);
            output2.profile_size = size(output2.profile_mat);
            
            output1.profile_mat = output1.profile_mat([1:3000, 32493:34492], :);
            output2.profile_mat = output2.profile_mat([1:3000, 32493:34492], :);
            
            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeCorrelationProfile, testFslr")
                % display differences
                disp(['Old size of output1 is [ ' num2str(ref_result1.profile_size) ' ]' ])
                disp(['New size of output1 is [ ' num2str(output1.profile_size) ' ]' ])
                disp(['Max abs difference of output1 is ' ...
                    num2str(max(max(abs(ref_result1.profile_mat - output1.profile_mat)))) ])
                
                disp(['Old size of output2 is [ ' num2str(ref_result2.profile_size) ' ]' ])
                disp(['New size of output2 is [ ' num2str(output2.profile_size) ' ]' ])
                disp(['Max abs difference of output2 is ' ...
                    num2str(max(max(abs(ref_result2.profile_mat - output2.profile_mat)))) ])
                
                
                % save and load new results
                ref_output_dir = fullfile(ref_dir, 'ref_output');
                ref_output_file1 = fullfile(ref_output_dir, ['testFslr.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub.mat']);
                ref_output_file2 = 'NONE';
                CBIG_ComputeCorrelationProfile(seed_mesh, target, ref_output_file1, ref_output_file2, ...
                threshold, varargin_text1, varargin_text2, outlier_text, split_data);
            
                ref_result1 = load(fullfile(ref_dir, 'ref_output', ['testFslr.roi' seed_mesh '.thresh' ...
                    threshold '.surf2surf_profile_scrub_1.mat']));
                ref_result2 = load(fullfile(ref_dir, 'ref_output', ['testFslr.roi' seed_mesh '.thresh' ...
                    threshold '.surf2surf_profile_scrub_2.mat']));
                
                % save struct 1
                profile_mat = ref_result1.profile_mat([1:3000, 32493:34492], :);
                profile_size = size(ref_result1.profile_mat);
                save(fullfile(ref_dir, 'ref_output', ['testFslr.roi' seed_mesh '.thresh' ...
                    threshold '.surf2surf_profile_scrub_1.mat']), 'profile_mat', 'profile_size');
                % save struct 2
                profile_mat = ref_result2.profile_mat([1:3000, 32493:34492], :);
                profile_size = size(ref_result2.profile_mat);             
                save(fullfile(ref_dir, 'ref_output', ['testFslr.roi' seed_mesh '.thresh' ...
                    threshold '.surf2surf_profile_scrub_2.mat']), 'profile_mat', 'profile_size');   
                % load new structs
                ref_result1 = load(fullfile(ref_dir, 'ref_output', ['testFslr.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub_1.mat']));
                ref_result2 = load(fullfile(ref_dir, 'ref_output', ['testFslr.roi' seed_mesh '.thresh' ...
                threshold '.surf2surf_profile_scrub_2.mat']));
            end
            
            % check whether output is same as reference
            assert(isequal(ref_result1.profile_size, output1.profile_size), ...
                'Output 1 profile_mat is of wrong size.');
            assert(isequal(ref_result2.profile_size, output2.profile_size), ...
                'Output 2 profile_mat is of wrong size.');
            
            assert(all(all(abs(ref_result1.profile_mat - output1.profile_mat) < 1e-12)), ...
                sprintf('Output 1 profile_mat differed from reference by (max abs diff) %f.', ...
                max(max(abs(ref_result1.profile_mat - output1.profile_mat)))));
            assert(all(all(abs(ref_result2.profile_mat - output2.profile_mat) < 1e-12)), ...
                sprintf('Output 2 profile_mat differed from reference by (max abs diff) %f.', ...
                max(max(abs(ref_result2.profile_mat - output2.profile_mat)))));
            
            rmdir(output_dir, 's');
        end
            
    end
    
end

            
            
            
            
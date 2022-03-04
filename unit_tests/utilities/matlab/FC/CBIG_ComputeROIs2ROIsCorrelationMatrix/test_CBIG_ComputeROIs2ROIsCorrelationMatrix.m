classdef test_CBIG_ComputeROIs2ROIsCorrelationMatrix < matlab.unittest.TestCase
% Written by Siyi Tang and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        function testlh2rhFsaverage5(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeROIs2ROIsCorrelationMatrix');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            % In this test case, compute correlation between lh and rh
            % using Schaefer 400ROI parcellation in fsaverage5 space. There are 2 subjects, 1st
            % subject has 1 run, 2nd subject has 2 runs. Correlation matrix of each subject is
            % obtained (not averaged across subjects).
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            output_file = fullfile(output_dir, 'output_testlh2rhFsaverage5.mat');
            subj_text_list1 = fullfile(ref_dir, 'input', 'subjList1_testlh2rhFsaverage5.txt');
            subj_text_list2 = fullfile(ref_dir, 'input', 'subjList2_testlh2rhFsaverage5.txt');
            discard_frames_list = fullfile(ref_dir, 'input', 'censorList_testlh2rhFsaverage5.txt');
            ROIs1 = fullfile(ref_dir, 'input', 'lh.Schaefer2018_400Parcels_17Networks_order.annot');
            ROIs2 = fullfile(ref_dir, 'input', 'rh.Schaefer2018_400Parcels_17Networks_order.annot');
            regression_mask1 = 'NONE';
            regression_mask2 = 'NONE';
            all_comb_bool = 1;
            avg_sub_bool = 0;
            
            CBIG_ComputeROIs2ROIsCorrelationMatrix(output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
            
            % compare with reference result
            output = load(output_file);
            ref_output_dir = fullfile(ref_dir, 'ref_output');
            ref_output_file = fullfile(ref_output_dir, 'output_testlh2rhFsaverage5.mat');
            ref_result = load(ref_output_file);
            
            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeROIs2ROIsCorrelationMatrix, testlh2rhFsaverage5")
                % display differences
                disp(['Old size of correlation matrix is [ ' num2str(size(ref_result.corr_mat)) ' ]' ])
                disp(['New size of correlation matrix is [ ' num2str(size(output.corr_mat)) ' ]' ])
                disp(['Max abs diff of correlation profile matrix is ' num2str(max(max(abs(output.corr_mat - ref_result.corr_mat)))) ])
                            
                % save and load new results
                CBIG_ComputeROIs2ROIsCorrelationMatrix(ref_output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
                ref_result = load(ref_output_file);
            end
            
            assert(isequal(size(output.corr_mat),size(ref_result.corr_mat)),...
                'Output correlation matrix is of wrong size.');
            assert(all(all(all(abs(output.corr_mat - ref_result.corr_mat) < 1e-12))), ...
                sprintf('Output correlation matrix differed from reference (max abs diff) by %f.', ...
                max(max(max(abs(output.corr_mat - ref_result.corr_mat))))));
            
            rmdir(output_dir, 's')
        end
        
        function testlh2subcortFsaverage5(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeROIs2ROIsCorrelationMatrix');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            % In this test case, compute correlation between lh and
            % subcortical ROIs using Schaefer 400ROI parcellation and 19 subcortical ROIs segmented in FreeSurfer.
            % There is only 1 subject.
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            output_file = fullfile(output_dir, 'output_testlh2subcortFsaverage5.mat');
            subj_text_list1 = fullfile(ref_dir, 'input', 'subjList1_testlh2subcortFsaverage5.txt');
            subj_text_list2 = fullfile(ref_dir, 'input', 'subjList2_testlh2subcortFsaverage5.txt');
            discard_frames_list = fullfile(ref_dir, 'input', 'censorList_testlh2subcortFsaverage5.txt');
            ROIs1 = fullfile(ref_dir, 'input', 'lh.Schaefer2018_400Parcels_17Networks_order.annot');
            ROIs2 = fullfile(ref_dir, 'input', 'Sub1.subcortex.parcels.func.nii.gz');
            regression_mask1 = 'NONE';
            regression_mask2 = 'NONE';
            all_comb_bool = 1;
            avg_sub_bool = 1;
            
            CBIG_ComputeROIs2ROIsCorrelationMatrix(output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
                       
            % compare with reference result
            output = load(output_file);
            ref_output_dir = fullfile(ref_dir, 'ref_output');
            ref_output_file = fullfile(ref_output_dir, 'output_testlh2subcortFsaverage5.mat');
            ref_result = load(ref_output_file);
            
            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeROIs2ROIsCorrelationMatrix, testlh2subcortFsaverage5")
                % display differences
                disp(['Old size of correlation matrix is [ ' num2str(size(ref_result.corr_mat)) ' ]' ])
                disp(['New size of correlation matrix is [ ' num2str(size(output.corr_mat)) ' ]' ])
                disp(['Max abs diff of correlation profile matrix is ' num2str(max(max(abs(output.corr_mat - ref_result.corr_mat)))) ])
                            
                % save and load new results
                CBIG_ComputeROIs2ROIsCorrelationMatrix(ref_output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
                ref_result = load(ref_output_file);
            end
            
            assert(isequal(size(output.corr_mat),size(ref_result.corr_mat)), ...
                'Output correlation matrix is of wrong size.');
            assert(all(all(abs(output.corr_mat - ref_result.corr_mat) < 1e-12)), ...
                sprintf('Output correlation matrix differed from reference (max abs diff) by %f.', ...
                max(max(abs(output.corr_mat - ref_result.corr_mat)))));
            
            rmdir(output_dir, 's');
        end
        
        function testFslr(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeROIs2ROIsCorrelationMatrix');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
                
            % In this test case, compute correlation matrix in fslr space using Schaefer 400ROI parcellation.
            % There are 2 subjects. Correlation matrices are averaged
            % across subjects
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            output_file = fullfile(output_dir, 'output_testFslr.mat');
            subj_text_list1 = fullfile(ref_dir, 'input', 'subjList1_testFslr.txt');
            subj_text_list2 = fullfile(ref_dir, 'input', 'subjList2_testFslr.txt');
            discard_frames_list = 'NONE';
            ROIs1 = fullfile(ref_dir, 'input', 'Schaefer2018_400Parcels_17Networks_order.dlabel.nii');
            ROIs2 = fullfile(ref_dir, 'input', 'Schaefer2018_400Parcels_17Networks_order.dlabel.nii');
            regression_mask1 = 'NONE';
            regression_mask2 = 'NONE';
            all_comb_bool = 1;
            avg_sub_bool = 1;
            
            CBIG_ComputeROIs2ROIsCorrelationMatrix(output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
            
            % compare with reference result
            output = load(output_file);
            ref_output_dir = fullfile(ref_dir, 'ref_output');
            ref_output_file = fullfile(ref_output_dir, 'output_testFslr.mat');
            ref_result = load(ref_output_file);
            
            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeROIs2ROIsCorrelationMatrix, testFslr")
                % display differences
                disp(['Old size of correlation matrix is [ ' num2str(size(ref_result.corr_mat)) ' ]' ])
                disp(['New size of correlation matrix is [ ' num2str(size(output.corr_mat)) ' ]' ])
                disp(['Max abs diff of correlation profile matrix is ' num2str(max(max(abs(output.corr_mat - ref_result.corr_mat)))) ])
                            
                % save and load new results
                CBIG_ComputeROIs2ROIsCorrelationMatrix(ref_output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
                ref_result = load(ref_output_file);
            end

            
            assert(isequal(size(output.corr_mat),size(ref_result.corr_mat)), ...
                'Output correlation matrix is of wrong size.');
            assert(all(all(abs(output.corr_mat - ref_result.corr_mat) < 1e-12)), ...
                sprintf('Output correlation matrix differed from reference (max abs diff) by %f.', ...
                max(max(abs(output.corr_mat - ref_result.corr_mat)))));
            
            rmdir(output_dir, 's');
        end
        
        function test_mixlabels(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', ...
                'FC', 'CBIG_ComputeROIs2ROIsCorrelationMatrix');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
                
            % In this test case, compute correlation matrix in fslr space
            % using Schaefer 400ROI dlabel parcellation, 
            % and caudate labels using a single ROI text file
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            output_file = fullfile(output_dir, 'output_test_mixlabels.mat');
            subj_text_list1 = fullfile(ref_dir, 'input', 'subjList1_testFslr.txt');
            subj_text_list2 = fullfile(ref_dir, 'input', 'subjList2_testFslr.txt');
            discard_frames_list = 'NONE';
            % create text file with mix of dlabel and subcort labels
            output_txt = fullfile(output_dir, 'test_mixlabels.txt');
            fid = fopen(output_txt, 'w');
                fprintf(fid,[fullfile(ref_dir,'input','Schaefer2018_400Parcels_17Networks_order.dlabel.nii') '\n']);
                fprintf(fid,[fullfile(ref_dir,'input','testFslr_caudate_left.label') '\n']);
                fprintf(fid,fullfile(ref_dir,'input','testFslr_caudate_right.label'));
            fclose(fid);
            ROIs1 = output_txt;
            ROIs2 = output_txt;
            regression_mask1 = 'NONE';
            regression_mask2 = 'NONE';
            all_comb_bool = 1;
            avg_sub_bool = 1;
            
            CBIG_ComputeROIs2ROIsCorrelationMatrix(output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
            
            if replace_unit_test
                ref_output_dir = fullfile(ref_dir, 'ref_output');
                ref_output_file = fullfile(ref_output_dir, 'output_test_mixlabels.mat');
                CBIG_ComputeROIs2ROIsCorrelationMatrix(ref_output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
            end
            
            % compare with reference result
            output = load(output_file);
            ref_output_dir = fullfile(ref_dir, 'ref_output');
            ref_output_file = fullfile(ref_output_dir, 'output_test_mixlabels.mat');
            ref_result = load(ref_output_file);

            % replace if flag is 1
            if replace_unit_test
                disp("Replacing unit test for CBIG_ComputeROIs2ROIsCorrelationMatrix, test_mixlabels")
                % display differences
                disp(['Old size of correlation matrix is [ ' num2str(size(ref_result.corr_mat)) ' ]' ])
                disp(['New size of correlation matrix is [ ' num2str(size(output.corr_mat)) ' ]' ])
                disp(['Max abs diff of correlation profile matrix is ' num2str(max(max(abs(output.corr_mat - ref_result.corr_mat)))) ])
                            
                % save and load new results
                CBIG_ComputeROIs2ROIsCorrelationMatrix(ref_output_file, subj_text_list1, ...
                subj_text_list2, discard_frames_list, ROIs1, ROIs2, regression_mask1, ...
                regression_mask2, all_comb_bool, avg_sub_bool);
                ref_result = load(ref_output_file);
            end
            
            assert(isequal(size(output.corr_mat),size(ref_result.corr_mat)), ...
                'Output correlation matrix is of wrong size.');
            assert(all(all(abs(output.corr_mat - ref_result.corr_mat) < 1e-12)), ...
                sprintf('Output correlation matrix differed from reference (max abs diff) by %f.', ...
                max(max(abs(output.corr_mat - ref_result.corr_mat)))));
            
            rmdir(output_dir, 's');
        end
        
    end
    
end

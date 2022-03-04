classdef test_CBIG_MultiKRRWorkflow < matlab.unittest.TestCase

    methods (Test)
        function test_standard_no_bias(testCase)
            
            if exist(fullfile('output','standard','no_bias'))
                rmdir(fullfile('output','standard','no_bias'),'s')
            end
            
            mkdir(fullfile('output','standard','no_bias'));
            
            in = load(fullfile('input','standard','no_bias','setup.mat'));
            
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                % replace reference result   
                ref_outdir = fullfile('ref_output','standard','no_bias');
                mkdir(ref_outdir)
                mkdir(fullfile(ref_outdir, 'optimal_acc', 'fold_1'))
                mkdir(fullfile(ref_outdir, 'optimal_acc', 'fold_2'))
                
                CBIG_MultiKRR_workflow( '', 0, in.sub_fold_file, in.y_file,...
                    in.covariate_file, in.feat_file, in.num_inner_folds, in.outdir,...
                    in.outstem, 'with_bias',in.with_bias, 'acc_metric', 'corr')
                
                filenames = {'final_result_Cognitive.mat', fullfile('optimal_acc', 'fold_1', 'acc_Cognitive.mat')...
                    fullfile('optimal_acc', 'fold_2', 'acc_Cognitive.mat')};
                for i = 1:length(filenames)
                    source = fullfile(in.outdir,filenames{i});
                    destination = fullfile(ref_outdir,filenames{i});
                    copyfile(source,destination)
                end
            else
                CBIG_MultiKRR_workflow( '', 0, in.sub_fold_file, in.y_file,...
                    in.covariate_file, in.feat_file, in.num_inner_folds, in.outdir,...
                    in.outstem, 'with_bias',in.with_bias, 'acc_metric', 'corr')

                ref_out = load(fullfile('ref_output', 'standard','no_bias',...
                    'final_result_Cognitive.mat'));

                ref_out_value = mean(mean(ref_out.acc{1}));

                test_out = load(fullfile('output', 'standard','no_bias',...
                    'final_result_Cognitive.mat'));
                disp(test_out)

                test_out_value = mean(mean(test_out.acc{1}));

                delta = abs(ref_out_value - test_out_value);

                assert( delta < 1e-8, 'error for the Multi KRR no_bias case');
            end
            
            rmdir (fullfile('output','standard','no_bias'), 's')
            
            
        end

        function test_standard_bias(testCase)
            
            if exist(fullfile('output','standard','bias'), 'dir')
                rmdir(fullfile('output','standard','bias'),'s')
            end
            
            mkdir(fullfile('output','standard','bias'));
            
            in = load(fullfile('input','standard','bias','setup.mat'));

            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                % replace reference result   
                ref_outdir = fullfile('ref_output','standard','bias');
                mkdir(ref_outdir)
                mkdir(fullfile(ref_outdir, 'optimal_acc', 'fold_1'))
                mkdir(fullfile(ref_outdir, 'optimal_acc', 'fold_2'))
                
                CBIG_MultiKRR_workflow( '', 0, in.sub_fold_file, in.y_file,...
                    in.covariate_file, in.feat_file, in.num_inner_folds, in.outdir,...
                    in.outstem, 'with_bias',in.with_bias, 'acc_metric', 'corr')
                
                filenames = {'final_result_Cognitive.mat', fullfile('optimal_acc', 'fold_1', 'acc_Cognitive.mat')...
                    fullfile('optimal_acc', 'fold_2', 'acc_Cognitive.mat')};
                for i = 1:length(filenames)
                    source = fullfile(in.outdir,filenames{i});
                    destination = fullfile(ref_outdir,filenames{i});
                    copyfile(source,destination)
                end
            else
                CBIG_MultiKRR_workflow( '', 0, in.sub_fold_file, in.y_file,...
                    in.covariate_file, in.feat_file, in.num_inner_folds, in.outdir,...
                    in.outstem, 'with_bias',in.with_bias, 'acc_metric', 'corr')

                ref_out = load(fullfile('ref_output', 'standard','bias',...
                    'final_result_Cognitive.mat'));

                ref_out_value = mean(mean(ref_out.acc{1}));

                test_out = load(fullfile('output', 'standard','bias',...
                    'final_result_Cognitive.mat'));

                test_out_value = mean(mean(test_out.acc{1}));

                delta = abs(ref_out_value - test_out_value);

                assert( delta < 1e-8, 'error for the Multi KRR bias case');
            end
            
            rmdir (fullfile('output','standard','bias'), 's')
            
        end       

        function test_grouped(testCase)
            
            if exist(fullfile('output','grouped'), 'dir')
                rmdir(fullfile('output','grouped'),'s')
            end
            
            mkdir(fullfile('output','grouped'));
            
            in = load(fullfile('input','grouped','setup.mat'));
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                % replace reference result   
                ref_outdir = fullfile('ref_output','grouped');
                mkdir(ref_outdir)
                mkdir(fullfile(ref_outdir, 'optimal_acc', 'fold_1'))
                mkdir(fullfile(ref_outdir, 'optimal_acc', 'fold_2'))
                
                CBIG_MultiKRR_workflow( '', 0, in.sub_fold_file, in.y_file,...
                    in.covariate_file, in.feat_file, in.num_inner_folds, in.outdir,...
                    in.outstem, 'with_bias',in.with_bias, 'group_kernel_file', in.group_kernel_file,...
                    'acc_metric', 'corr')

                filenames = {'final_result_Cognitive.mat', fullfile('optimal_acc', 'fold_1', 'acc_Cognitive.mat')...
                    fullfile('optimal_acc', 'fold_2', 'acc_Cognitive.mat')};
                for i = 1:length(filenames)
                    source = fullfile(in.outdir,filenames{i});
                    destination = fullfile(ref_outdir,filenames{i});
                    copyfile(source,destination)
                end
            else
                CBIG_MultiKRR_workflow( '', 0, in.sub_fold_file, in.y_file,...
                    in.covariate_file, in.feat_file, in.num_inner_folds, in.outdir,...
                    in.outstem, 'with_bias',in.with_bias, 'group_kernel_file', in.group_kernel_file,...
                    'acc_metric', 'corr')

                ref_out = load(fullfile('ref_output', 'grouped',...
                    'final_result_Cognitive.mat'));

                ref_out_value = mean(mean(ref_out.acc{1}));

                test_out = load(fullfile('output', 'grouped',...
                    'final_result_Cognitive.mat'));

                test_out_value = mean(mean(test_out.acc{1}));

                delta = abs(ref_out_value - test_out_value);

                assert( delta < 1e-8, 'error for the Multi KRR grouped case');
            
            end
            
            rmdir(fullfile('output','grouped'),'s')
            
        end
    end

end

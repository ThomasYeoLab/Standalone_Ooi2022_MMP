classdef test_CBIG_run_Elasticnet_workflow < matlab.unittest.TestCase
% Written by Leon Ooi and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    
    methods (Test)
        % test basic Elasticnet basic function
        function test_basic( TestCase )
            % Setup directory for input data 
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'Elasticnet', 'CBIG_run_Elasticnet_workflow');
            input_dir = fullfile(parent_dir, 'input');
            load(fullfile(input_dir, 'no_relative_5_fold_sub_list.mat'))
            load(fullfile(input_dir, 'y.mat'))
            load(fullfile(input_dir, 'covariates.mat'))
            load(fullfile(input_dir, 'RSFC.mat'))
            
            params.sub_fold = sub_fold;
            params.feature_mat = corr_mat;
            params.y = y;
            params.covariates = covariates;
            params.num_innerfolds = length(params.sub_fold);
            params.split_name = 'split_1';
            params.outdir = fullfile(parent_dir, 'output', 'test_basic');
            params.outstem = 'unit_test';
            
            % run test
            if(exist(params.outdir, 'dir'))
                rmdir(params.outdir, 's')
            end
            mkdir(params.outdir)
            
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                % replace reference result   
                params.outdir = fullfile(parent_dir, 'ref_output', 'test_basic');
                if(exist(params.outdir, 'dir'))
                    rmdir(params.outdir, 's')
                end
                CBIG_run_Elasticnet_workflow( params );
            else

                CBIG_run_Elasticnet_workflow( params );

                % compare results
                expected_fields = {'acc_corr_test' 'acc_metric_train' 'optimal_statistics' ...
                    'y_pred_train' 'y_predict'};
                expected_metrics = {'corr','COD','predictive_COD','MAE','MAE_norm','MSE','MSE_norm'};

                ref_dir = fullfile(parent_dir, 'ref_output', 'test_basic', ...
                    'split_1', 'optimal_acc');
                ref = load(fullfile(ref_dir, 'unit_test_final_acc.mat'));
                test = load(fullfile(params.outdir, 'split_1', ...
                    'optimal_acc', 'unit_test_final_acc.mat'));
                fields = sort(fieldnames(ref));

                for j = 1:length(fields)
                    curr_ref = getfield(ref, fields{j});
                    curr_test = getfield(test, fields{j});

                    % check if field names are the same
                    assert(strcmp(fields{j},expected_fields{j}), ...
                        sprintf('unexpected field %s.', fields{j}))

                    switch j
                        case 3 % go through all optimal_statistics
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            total_test = 0;
                            total_ref = 0;
                            % loop through train-test splits
                            for k = 1:length(curr_test)
                                metrics = fieldnames(curr_test{k});
                                for m = 1:length(metrics)
                                    assert(strcmp(metrics{m},expected_metrics{m}), ...
                                    sprintf('unexpected metric %s.', metrics{m}))
                                    total_test = total_test + curr_test{k}.(metrics{m});
                                    total_ref = total_ref + curr_ref{k}.(metrics{m});
                                end
                            end
                            assert(abs(total_test - total_ref) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}));
                        case {4, 5} % go through y_pred_train and y_predict
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            total_test = 0;
                            total_ref = 0;
                            % loop through train-test splits
                            for k = 1:length(curr_test)
                                total_test = total_test + sum(abs(curr_test{k}));
                                total_ref = total_ref + sum(abs(curr_ref{k}));
                            end
                            assert(abs(total_test - total_ref) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}));                         
                        otherwise
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            assert(abs(sum(curr_test - curr_ref)) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}));
                    end
                end
            end    
            rmdir(fullfile(parent_dir, 'output'), 's')
        end
        
        % test whether normalization works
        function test_normalization( TestCase )
            
            % Setup directory for input data 
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'Elasticnet', 'CBIG_run_Elasticnet_workflow');
            input_dir = fullfile(parent_dir, 'input');
            load(fullfile(input_dir, 'no_relative_5_fold_sub_list.mat'))
            load(fullfile(input_dir, 'y.mat'))
            load(fullfile(input_dir, 'covariates.mat'))
            load(fullfile(input_dir, 'RSFC.mat'))
            
            params.sub_fold = sub_fold;
            params.feature_mat = corr_mat;
            params.y = y;
            params.covariates = covariates;
            params.num_innerfolds = num2str(length(params.sub_fold));
            params.split_name = 'split_1';
            params.norm = true;
            params.outdir = fullfile(parent_dir, 'output', 'test_normalization');
            params.outstem = 'unit_test';
            
            % run test
            if(exist(params.outdir, 'dir'))
                rmdir(params.outdir, 's')
            end
            mkdir(params.outdir)
            
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                % replace reference result   
                params.outdir = fullfile(parent_dir, 'ref_output', 'test_normalization');
                if(exist(params.outdir, 'dir'))
                    rmdir(params.outdir, 's')
                end
                CBIG_run_Elasticnet_workflow( params );
            else
                CBIG_run_Elasticnet_workflow( params );

                % compare results
                expected_fields = {'acc_corr_test' 'acc_metric_train' 'optimal_statistics' ...
                    'y_pred_train' 'y_predict'};
                expected_metrics = {'corr','COD','predictive_COD','MAE','MAE_norm','MSE','MSE_norm'};

                ref_dir = fullfile(parent_dir, 'ref_output', 'test_normalization', ...
                    'split_1', 'optimal_acc');
                ref = load(fullfile(ref_dir, 'unit_test_final_acc.mat'));
                test = load(fullfile(params.outdir, 'split_1', ...
                    'optimal_acc', 'unit_test_final_acc.mat'));
                fields = sort(fieldnames(ref));

                for j = 1:length(fields)
                    curr_ref = getfield(ref, fields{j});
                    curr_test = getfield(test, fields{j});

                    % check if field names are the same
                    assert(strcmp(fields{j},expected_fields{j}), ...
                        sprintf('unexpected field %s', fields{j}))

                    switch j
                        case 3 % go through all optimal_statistics
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            total_test = 0;
                            total_ref = 0;
                            % loop through train-test splits
                            for k = 1:length(curr_test)
                                metrics = fieldnames(curr_test{k});
                                for m = 1:length(metrics)
                                    assert(strcmp(metrics{m},expected_metrics{m}), ...
                                    sprintf('unexpected metric %s', metrics{m}))
                                    total_test = total_test + curr_test{k}.(metrics{m});
                                    total_ref = total_ref + curr_ref{k}.(metrics{m});
                                end
                            end
                            assert(abs(total_test - total_ref) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}));
                        case {4, 5} % go through y_pred_train and y_predict
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            total_test = 0;
                            total_ref = 0;
                            % loop through train-test splits
                            for k = 1:length(curr_test)
                                total_test = total_test + sum(abs(curr_test{k}));
                                total_ref = total_ref + sum(abs(curr_ref{k}));
                            end
                            assert(abs(total_test - total_ref) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}));                         
                        otherwise
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            assert(abs(sum(curr_test - curr_ref)) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}))
                    end
                end
            end
            rmdir(fullfile(parent_dir, 'output'),'s')
        end
        
        % test whether not setting lambda works
        function test_no_lambda( TestCase )
            
            % Setup directory for input data 
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'Elasticnet', 'CBIG_run_Elasticnet_workflow');
            input_dir = fullfile(parent_dir, 'input');
            load(fullfile(input_dir, 'no_relative_5_fold_sub_list.mat'))
            load(fullfile(input_dir, 'y.mat'))
            load(fullfile(input_dir, 'covariates.mat'))
            load(fullfile(input_dir, 'RSFC.mat'))
            
            params.sub_fold = sub_fold;
            params.feature_mat = corr_mat;
            params.y = y;
            params.covariates = covariates;
            params.num_innerfolds = num2str(length(params.sub_fold));
            params.split_name = 'split_1';
            params.norm = true;
            params.lambda = [];
            params.outdir = fullfile(parent_dir, 'output', 'test_no_lambda');
            params.outstem = 'unit_test';
            
            % run test
            if(exist(params.outdir, 'dir'))
                rmdir(params.outdir, 's')
            end
            mkdir(params.outdir)
            
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                % replace reference result   
                params.outdir = fullfile(parent_dir, 'ref_output', 'test_no_lambda');
                if(exist(params.outdir, 'dir'))
                    rmdir(params.outdir, 's')
                end
                CBIG_run_Elasticnet_workflow( params );
            else
                CBIG_run_Elasticnet_workflow( params );

                % compare selected lambdas are same
                ref_dir = fullfile(parent_dir, 'ref_output', 'test_no_lambda', ...
                    'split_1', 'params');
                for i = 1:length(params.sub_fold)
                    fold = strcat('fold_',num2str(i));
                    ref = load(fullfile(ref_dir, fold, 'selected_parameters_unit_test.mat'));
                    test = load(fullfile(params.outdir, 'split_1', ...
                    'params', fold, 'selected_parameters_unit_test.mat'));
                    assert(abs(ref.curr_lambda - test.curr_lambda) < 1e-10, ...
                                sprintf('lambda for split %i is different from reference result.', i));
                end

                % compare results
                expected_fields = {'acc_corr_test' 'acc_metric_train' 'optimal_statistics' ...
                    'y_pred_train' 'y_predict'};
                expected_metrics = {'corr','COD','predictive_COD','MAE','MAE_norm','MSE','MSE_norm'};

                ref_dir = fullfile(parent_dir, 'ref_output', 'test_no_lambda', ...
                    'split_1', 'optimal_acc');
                ref = load(fullfile(ref_dir, 'unit_test_final_acc.mat'));
                test = load(fullfile(params.outdir, 'split_1', ...
                    'optimal_acc', 'unit_test_final_acc.mat'));
                fields = sort(fieldnames(ref));

                for j = 1:length(fields)
                    curr_ref = getfield(ref, fields{j});
                    curr_test = getfield(test, fields{j});

                    % check if field names are the same
                    assert(strcmp(fields{j},expected_fields{j}), ...
                        sprintf('unexpected field %s', fields{j}))

                    switch j
                        case 3 % go through all optimal_statistics
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            total_test = 0;
                            total_ref = 0;
                            % loop through train-test splits
                            for k = 1:length(curr_test)
                                metrics = fieldnames(curr_test{k});
                                for m = 1:length(metrics)
                                    assert(strcmp(metrics{m},expected_metrics{m}), ...
                                    sprintf('unexpected metric %s', metrics{m}))
                                    add_test = curr_test{k}.(metrics{m});
                                    add_ref = curr_ref{k}.(metrics{m});
                                    if isnan(add_test);
                                        add_test = 0;
                                    end
                                    if isnan(add_ref);
                                        add_ref = 0;
                                    end
                                    total_test = total_test + add_test;
                                    total_ref = total_ref + add_ref;
                                end
                            end
                            assert(abs(total_test - total_ref) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}));
                        case {4, 5} % go through y_pred_train and y_predict
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            total_test = 0;
                            total_ref = 0;
                            % loop through train-test splits
                            for k = 1:length(curr_test)
                                total_test = total_test + sum(abs(curr_test{k}));
                                total_ref = total_ref + sum(abs(curr_ref{k}));
                            end
                            assert(abs(total_test - total_ref) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}));                         
                        otherwise
                            curr_test(isnan(curr_test)) = 0;
                            curr_ref(isnan(curr_ref)) = 0;
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{j}))
                            assert(abs(sum(curr_test - curr_ref)) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{j}))
                    end
                end
            end
            rmdir(fullfile(parent_dir, 'output'),'s')
        end
        
    end
    
end

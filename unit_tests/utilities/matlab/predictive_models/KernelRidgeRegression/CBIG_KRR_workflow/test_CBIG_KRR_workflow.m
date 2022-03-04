classdef test_CBIG_KRR_workflow < matlab.unittest.TestCase
% Written by Jingwei Li and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    
    methods (Test)
        function test_setup_input( TestCase )
            % The inputs are passed in through a single setup file;
            % No NaN in the behavior;
            % param.with_bias = 1, so that the beta term is included in the model
            
            %% 
            % create the setup file on fly (we cannot pre-save it because param.outdir
            % dependes on CBIG_CODE_DIR of each user)
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_setup_input');
            
            load(fullfile(input_dir, 'no_relative_5_fold_sub_list.mat'))
            load(fullfile(input_dir, 'y.mat'))
            load(fullfile(input_dir, 'covariates.mat'))
            load(fullfile(input_dir, 'RSFC.mat'))
            
            param.sub_fold = sub_fold;
            param.y = y;
            param.feature_mat = corr_mat;
            param.covariates = covariates;
            param.num_inner_folds = 5;
            param.outdir = fullfile(parent_dir, 'output', 'test_setup_input_case');
            param.outstem = '2cog';
            param.with_bias = 1;
            param.ker_param.type = 'corr';
            param.ker_param.scale = nan;
            param.lambda_set = [0 0.01 0.1 1 10 100 1000];
            param.threshold_set = nan;
            param.metric = 'corr';
            param.cov_X = [];
            
            if(exist(param.outdir, 'dir'))
                rmdir(param.outdir, 's')
            end
            mkdir(param.outdir)
            save(fullfile(param.outdir, 'setup.mat'), '-struct', 'param')
            
			%% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                %% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_setup_input_case');
                mkdir(ref_outdir)
                CBIG_KRR_workflow(param);
                filename = 'final_result_2cog.mat';
                source = fullfile(param.outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else		
				%% call the KRR workflow function
				CBIG_KRR_workflow( fullfile(param.outdir, 'setup.mat') );
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_setup_input_case');
				ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
				test = load(fullfile(param.outdir, 'final_result_2cog.mat'));
				fields = fieldnames(ref);
				
				for i = 1:length(fields)
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel')...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
						if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
            end
        end

        function test_setup_input_struct( TestCase )
            % The inputs are passed in through a single setup struct;
            % No NaN in the behavior;
            % param.with_bias = 1, so that the beta term is included in the model
            
            %% 
            % create the setup param struct
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_setup_input');
            
            load(fullfile(input_dir, 'no_relative_5_fold_sub_list.mat'))
            load(fullfile(input_dir, 'y.mat'))
            load(fullfile(input_dir, 'covariates.mat'))
            load(fullfile(input_dir, 'RSFC.mat'))
            
            param.sub_fold = sub_fold;
            param.y = y;
            param.feature_mat = corr_mat;
            param.covariates = covariates;
            param.num_inner_folds = 5;
            param.outdir = fullfile(parent_dir, 'output', 'test_setup_input_struct');
            param.outstem = '2cog';
            param.with_bias = 1;
            param.ker_param.type = 'corr';
            param.ker_param.scale = nan;
            param.lambda_set = [0 0.01 0.1 1 10 100 1000];
            param.threshold_set = nan;
            param.metric = 'corr';
            param.cov_X = [];

            if(exist(param.outdir, 'dir'))
                rmdir(param.outdir, 's')
            end
            mkdir(param.outdir)
            
			%% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
				%% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_setup_input_struct');
                mkdir(ref_outdir)
                CBIG_KRR_workflow(param);
                filename = 'final_result_2cog.mat';
                source = fullfile(param.outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else
				
				%% call the KRR workflow function
				CBIG_KRR_workflow(param);
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_setup_input_struct');
				ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
				test = load(fullfile(param.outdir, 'final_result_2cog.mat'));
				fields = fieldnames(ref);
				
				for i = 1:length(fields)
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel')...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
                        if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
			end
        end
        
        function test_varargin_input_withNaN( TestCase )
            % The inputs are passed in as separate variables through varargin;
            % NaN appears in the behavior ;
            % Use default value of "with_bias" option, which means the beta
            % term is included in the model.
            
            %% specify inputs
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_varargin_input_withNaN');
            
            sub_fold_file = fullfile(input_dir, 'no_relative_5_fold_sub_list.mat');
            y_file = fullfile(input_dir, 'y.mat');
            covariate_file = fullfile(input_dir, 'covariates_empty.mat');
            feature_file = fullfile(input_dir, 'RSFC.mat');
            num_inner_folds = 5;
            outstem = '2cog';
            outdir = fullfile(parent_dir, 'output', 'test_varargin_input_withNaN_case');
            with_bias = 1;
            ker_param_file = fullfile(input_dir, 'kernel_param.mat');
            lambda_set_file = fullfile(input_dir, 'lambda_set.mat');
            metric = 'corr';
            
            if(exist(outdir, 'dir'))
                rmdir(outdir, 's')
            end
            mkdir(outdir)
            
			%% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                %% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_varargin_input_withNaN_case');
                mkdir(ref_outdir)
                CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
                    num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
                    ker_param_file, 'lambda_set_file', lambda_set_file, 'metric', metric);
				
                filename = 'final_result_2cog.mat';
                source = fullfile(outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else
                %% call the KRR workflow function
                CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file, 'lambda_set_file', lambda_set_file, 'metric', metric);
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_varargin_input_withNaN_case');
				ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
				test = load(fullfile(outdir, 'final_result_2cog.mat'));
				fields = fieldnames(ref);
				
				for i = 1:length(fields)
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel')...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
						if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
			end	
        end
        
        function test_without_bias( TestCase )
            % The inputs are pass in through the same input arguments as
            % "test_varargin_input_withNaN" case, except for outdir;
            % Set with_bias to 0 so that the beta term is not included in
            % the model.
            
            %% specify inputs
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_varargin_input_withNaN');
            
            sub_fold_file = fullfile(input_dir, 'no_relative_5_fold_sub_list.mat');
            y_file = fullfile(input_dir, 'y.mat');
            covariate_file = fullfile(input_dir, 'covariates.mat');
            feature_file = fullfile(input_dir, 'RSFC.mat');
            num_inner_folds = 5;
            outstem = '2cog';
            outdir = fullfile(parent_dir, 'output', 'test_without_bias_case');
            with_bias = 0;
            ker_param_file = fullfile(input_dir, 'kernel_param.mat');
            lambda_set_file = fullfile(input_dir, 'lambda_set.mat');
            metric = 'corr';
            
            if(exist(outdir, 'dir'))
                rmdir(outdir, 's')
            end
            mkdir(outdir)
            
			%% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                %% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_without_bias_case');
                mkdir(ref_outdir)
                CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file, 'lambda_set_file', lambda_set_file, 'metric', metric);
				
                filename = 'final_result_2cog.mat';
                source = fullfile(outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else
                %% call the KRR workflow function
                CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file,'lambda_set_file', lambda_set_file, 'metric', metric);
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_without_bias_case');
				ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
				test = load(fullfile(outdir, 'final_result_2cog.mat'));
				fields = fieldnames(ref);
				
				for i = 1:length(fields)
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel')...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
						if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
            end
        end
        
        function test_exp_kernel( TestCase )
            % The inputs are pass in through the same input arguments as
            % "test_varargin_input_withNaN" case, except for kernel parameters and outdir;
            % kernel type is 'Exponential', with scaling factor range from 0.01 to 2;
            % Use default value of "with_bias" option, which means the beta
            % term is included in the model.
            
            %% specify inputs
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_nonlinear_kernel');
            
            sub_fold_file = fullfile(input_dir, 'no_relative_5_fold_sub_list.mat');
            y_file = fullfile(input_dir, 'y.mat');
            covariate_file = fullfile(input_dir, 'covariates.mat');
            feature_file = fullfile(input_dir, 'RSFC.mat');
            num_inner_folds = 5;
            outstem = '2cog';
            outdir = fullfile(parent_dir, 'output', 'test_exp_kernel_case');
            with_bias = 1;
            ker_param_file = fullfile(input_dir, 'kernel_param_exp.mat');
            lambda_set_file = fullfile(input_dir, 'lambda_set.mat');
            metric = 'corr';
            
            if(exist(outdir, 'dir'))
                rmdir(outdir, 's')
            end
            mkdir(outdir)
            %% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
			if replace_unittest_flag
                %% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_exp_kernel_case');
                mkdir(ref_outdir)
                CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file, 'lambda_set_file', lambda_set_file, 'metric', metric);
                
                filename = 'final_result_2cog.mat';
                source = fullfile(outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else
                %% call the KRR workflow function
                CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file,'lambda_set_file', lambda_set_file, 'metric', metric);
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_exp_kernel_case');
				ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
				test = load(fullfile(outdir, 'final_result_2cog.mat'));
				fields = fieldnames(ref);
				
				for i = 1:length(fields) 
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel')...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
						if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
            end
        end
        
        function test_Gaussian_kernel( TestCase )
            % The inputs are pass in through the same input arguments as
            % "test_varargin_input_withNaN" case, except for kernel parameters and outdir;
            % kernel type is 'Gaussian', with scaling factor range from 0.01 to 2;
            % Use default value of "with_bias" option, which means the beta
            % term is included in the model.
            
            %% specify inputs
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_nonlinear_kernel');
            
            sub_fold_file = fullfile(input_dir, 'no_relative_5_fold_sub_list.mat');
            y_file = fullfile(input_dir, 'y.mat');
            covariate_file = fullfile(input_dir, 'covariates.mat');
            feature_file = fullfile(input_dir, 'RSFC.mat');
            num_inner_folds = 5;
            outstem = '2cog';
            outdir = fullfile(parent_dir, 'output', 'test_Gaussian_kernel_case');
            with_bias = 1;
            ker_param_file = fullfile(input_dir, 'kernel_param_Gaussian.mat');
            lambda_set_file = fullfile(input_dir, 'lambda_set.mat');
            metric = 'corr';
            
            if(exist(outdir, 'dir'))
                rmdir(outdir, 's')
            end
            mkdir(outdir)
            
			%% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag 
                %% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_Gaussian_kernel_case');
                mkdir(ref_outdir)
                CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file,'lambda_set_file', lambda_set_file, 'metric', metric);
                filename = 'final_result_2cog.mat';
                source = fullfile(outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else
                %% call the KRR workflow function
                CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file,'lambda_set_file', lambda_set_file, 'metric', metric);
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_Gaussian_kernel_case');
				ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
				test = load(fullfile(outdir, 'final_result_2cog.mat'));
				fields = fieldnames(ref);
				
				for i = 1:length(fields) 
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel') ...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
						if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
			end	
        end
        
        function test_binary_y( TestCase )
            %% specify inputs
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_binary_y');
            
            sub_fold_file = fullfile(input_dir, 'no_relative_5_fold_sub_list.mat');
            y_file = fullfile(input_dir, 'y.mat');
            covariate_file = fullfile(input_dir, 'covariates.mat');
            feature_file = fullfile(input_dir, 'RSFC.mat');
            num_inner_folds = 5;
            outstem = 'Age';
            outdir = fullfile(parent_dir, 'output', 'test_binary_y_case');
            with_bias = 0;
            ker_param_file = fullfile(input_dir, 'kernel_param.mat');
            lambda_set_file = fullfile(input_dir, 'lambda_set.mat');
            metric = 'corr';
            
            if(exist(outdir, 'dir'))
                rmdir(outdir, 's')
            end
            mkdir(outdir)
            
			%% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                %% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_binary_y_case');
                mkdir(ref_outdir)
   				CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file,'lambda_set_file', lambda_set_file, 'metric', metric);
                filename = ['final_result_' outstem '.mat'];
                source = fullfile(outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else
                %% call the KRR workflow function
				CBIG_KRR_workflow( [], 0, sub_fold_file, y_file, covariate_file, feature_file, ...
					num_inner_folds, outdir, outstem, 'with_bias', with_bias,'ker_param_file',...
					ker_param_file,'lambda_set_file', lambda_set_file, 'metric', metric);
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_binary_y_case');
				ref = load(fullfile(ref_dir, ['final_result_' outstem '.mat']));
				test = load(fullfile(outdir, ['final_result_' outstem '.mat']));
				fields = fieldnames(ref);
				
				for i = 1:length(fields) 
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel')...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
						if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold - ref.optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
			end	
        end
        
        function test_empty_cov( TestCase )
            %% specify inputs
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_empty_or_none_cov');
            
            load(fullfile(input_dir, 'no_relative_5_fold_sub_list.mat'))
            load(fullfile(input_dir, 'y.mat'))
            load(fullfile(input_dir, 'covariates_empty.mat'))
            load(fullfile(input_dir, 'RSFC.mat'))
            
            param.sub_fold = sub_fold;
            param.y = y;
            param.feature_mat = corr_mat;
            param.covariates = covariates;
            param.num_inner_folds = 5;
            param.outdir = fullfile(parent_dir, 'output', 'test_empty_cov');
            param.outstem = '2cog';
            param.with_bias = 1;
            param.ker_param.type = 'corr';
            param.ker_param.scale = nan;
            param.lambda_set = [0 0.01 0.1 1 10 100 1000];
            param.threshold_set = nan;
            param.metric = 'corr';
            param.cov_X = [];
            
            if(exist(param.outdir, 'dir'))
                rmdir(param.outdir, 's')
            end
            mkdir(param.outdir)
            save(fullfile(param.outdir, 'setup.mat'), '-struct', 'param')
            
			%% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                %% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_empty_cov');
                mkdir(ref_outdir)
   				CBIG_KRR_workflow(param);
				
                filename = 'final_result_2cog.mat';
                source = fullfile(param.outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else
				%% call the KRR workflow function
				CBIG_KRR_workflow( fullfile(param.outdir, 'setup.mat') );
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_empty_cov');
				ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
				test = load(fullfile(param.outdir, 'final_result_2cog.mat'));
				fields = fieldnames(ref);
				
				for i = 1:length(fields)
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel')...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
						if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
			end
        end
        
        function test_none_cov( TestCase )
            %% specify inputs
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_empty_or_none_cov');
            
            load(fullfile(input_dir, 'no_relative_5_fold_sub_list.mat'))
            load(fullfile(input_dir, 'y.mat'))
            load(fullfile(input_dir, 'covariates_empty.mat'))
            load(fullfile(input_dir, 'RSFC.mat'))
            
            param.sub_fold = sub_fold;
            param.y = y;
            param.feature_mat = corr_mat;
            param.covariates = covariates;
            param.num_inner_folds = 5;
            param.outdir = fullfile(parent_dir, 'output', 'test_none_cov');
            param.outstem = '2cog';
            param.with_bias = 1;
            param.ker_param.type = 'corr';
            param.ker_param.scale = nan;
            param.lambda_set = [0 0.01 0.1 1 10 100 1000];
            param.threshold_set = nan;
            param.metric = 'corr';
            param.cov_X = [];
            
            if(exist(param.outdir, 'dir'))
                rmdir(param.outdir, 's')
            end
            mkdir(param.outdir)
            save(fullfile(param.outdir, 'setup.mat'), '-struct', 'param')
            
			%% get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                %% replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_none_cov');
                mkdir(ref_outdir)
   				CBIG_KRR_workflow(param);
				
                filename = 'final_result_2cog.mat';
                source = fullfile(param.outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
			else
				%% call the KRR workflow function
				CBIG_KRR_workflow( fullfile(param.outdir, 'setup.mat') );
				
				%% compare results
				ref_dir = fullfile(parent_dir, 'ref_output', 'test_none_cov');
				ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
				test = load(fullfile(param.outdir, 'final_result_2cog.mat'));
				fields = fieldnames(ref);
				
				for i = 1:length(fields)
					if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel')...
                            && ~isequal(fields{i}, 'optimal_stats'))
						curr_ref = getfield(ref, fields{i});
						curr_test = getfield(test, fields{i});
						
						if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
					end
				end
				
				% check each field of optimal_kernel
				assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
					'field optimal_kernel is of wrong size');
				for i = 1:size(ref.optimal_kernel, 1)
					for j = 1:size(ref.optimal_kernel, 2)
						assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
							sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));
						
						if(~isnan(ref.optimal_kernel(i,j).scale))
							assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
						else
							assert(isnan(test.optimal_kernel(i,j).scale), ...
								sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
						end
					end
				end
				
				% if y is binary, check optimal_threshold
				assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
						'field optimal_threshold is of wrong size.');
				if(~all(all(isnan(ref.optimal_threshold))))
					assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
						'field optimal_threshold is different from reference result.');
				else
					assert(all(all(isnan(test.optimal_threshold))), ...
						'field optimal_threshold is different from reference result.')
				end
			end
        end
        function test_cov_X( TestCase )
            % Test confounding regression from features
            % param.with_bias = 1, so that the beta term is included in the model
            
            %% 
            % create the setup param struct
            rng('default')
            parent_dir = fullfile(getenv('CBIG_CODE_DIR'), 'unit_tests', 'utilities', 'matlab', ...
                'predictive_models', 'KernelRidgeRegression', 'CBIG_KRR_workflow');
            input_dir = fullfile(parent_dir, 'input', 'test_setup_input');
            
            load(fullfile(input_dir, 'no_relative_5_fold_sub_list.mat'))
            load(fullfile(input_dir, 'y.mat'))
            load(fullfile(input_dir, 'covariates.mat'))
            load(fullfile(input_dir, 'RSFC.mat'))
            
            param.sub_fold = sub_fold;
            param.y = y;
            param.feature_mat = corr_mat;
            param.covariates = covariates;
            param.num_inner_folds = 5;
            param.outdir = fullfile(parent_dir, 'output', 'test_cov_X');
            param.outstem = '2cog';
            param.with_bias = 1;
            param.ker_param.type = 'corr';
            param.ker_param.scale = nan;
            param.lambda_set = [0 0.01 0.1 1 10 100 1000];
            param.threshold_set = nan;
            param.metric = 'corr';
            param.cov_X = covariates;

            if(exist(param.outdir, 'dir'))
                rmdir(param.outdir, 's')
            end
            mkdir(param.outdir)
            
            % get replace_unittest_flag
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests','replace_unittest_flag'));
            
            if replace_unittest_flag
                % replace reference result   
                ref_outdir = fullfile(parent_dir, 'ref_output', 'test_cov_X');
                mkdir(ref_outdir)
                CBIG_KRR_workflow(param)
                filename = 'final_result_2cog.mat';
                source = fullfile(param.outdir,filename);
                destination = fullfile(ref_outdir,filename);
                copyfile(source,destination)
            else
                %% call the KRR workflow function
                CBIG_KRR_workflow(param)

                %% compare results
                ref_dir = fullfile(parent_dir, 'ref_output', 'test_cov_X');
                ref = load(fullfile(ref_dir, 'final_result_2cog.mat'));
                test = load(fullfile(param.outdir, 'final_result_2cog.mat'));
                fields = fieldnames(ref);

                for i = 1:length(fields)
                    if (~isequal(fields{i}, 'optimal_threshold') && ~isequal(fields{i}, 'optimal_kernel') ...
                            && ~isequal(fields{i}, 'optimal_stats'))
                        curr_ref = getfield(ref, fields{i});
                        curr_test = getfield(test, fields{i});

                        if (isequal(fields{i}, 'y_pred_train'))
                            for n = 1:length(curr_ref)
                                pred_test = curr_test{n};
                                pred_ref = curr_ref{n};
                                assert(isequal(size(pred_test),size(pred_ref)), ...
                                    sprintf('field %s is of wrong size.', fields{i}));
                                assert(max(abs((pred_test(:) - pred_ref(:)))) < 1e-10, ...
                                    sprintf('field %s is different from reference result.', fields{i}));
                            end   
                        else
                            assert(isequal(size(curr_test),size(curr_ref)), ...
                                sprintf('field %s is of wrong size.', fields{i}));
                            assert(max(abs((curr_test(:) - curr_ref(:)))) < 1e-10, ...
                                sprintf('field %s is different from reference result.', fields{i}));
                        end
                    end
                end

                % check each field of optimal_stats
                fields = fieldnames(ref.optimal_stats);
                for i = 1:length(fields)
                    curr_ref = getfield(ref.optimal_stats, fields{i});
                    curr_test = getfield(test.optimal_stats, fields{i});

                    assert(isequal(size(curr_test), size(curr_ref)), ...
                        sprintf('subfield %s of field optimal_stats is of wrong size.', fields{i}));
                    assert(max(abs(curr_test(:) - curr_ref(:))) < 1e-10, ...
                        sprintf('subfield %s is different from reference result.', fields{i}));
                end

                % check each field of optimal_kernel
                assert(isequal(size(test.optimal_kernel), size(ref.optimal_kernel)), ...
                    'field optimal_kernel is of wrong size');
                for i = 1:size(ref.optimal_kernel, 1)
                    for j = 1:size(ref.optimal_kernel, 2)
                        assert(all(strcmp(test.optimal_kernel(i,j).type, ref.optimal_kernel(i,j).type)), ...
                            sprintf('field optimal_kernel(%d,%d).type is different from reference result.', i, j));

                        if(~isnan(ref.optimal_kernel(i,j).scale))
                            assert(max(abs(test.optimal_kernel(i,j).scale - ref.optimal_kernel(i,j).scale)) < 1e-10, ...
                                sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j));
                        else
                            assert(isnan(test.optimal_kernel(i,j).scale), ...
                                sprintf('field optimal_kernel(%d,%d).scale is different from reference result.', i, j))
                        end
                    end
                end

                % if y is binary, check optimal_threshold
                assert(isequal(size(test.optimal_threshold), size(ref.optimal_threshold)), ...
                        'field optimal_threshold is of wrong size.');
                if(~all(all(isnan(ref.optimal_threshold))))
                    assert(max(abs(test.optimal_threshold, ref_optimal_threshold)) < 1e-10, ...
                        'field optimal_threshold is different from reference result.');
                else
                    assert(all(all(isnan(test.optimal_threshold))), ...
                        'field optimal_threshold is different from reference result.')
                end
            end
        end
	end
end


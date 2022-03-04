function params = EM2_AT(corpus, paradigm_by_exp, params)

% corpus is a D x 1 cell where D is the number of documents
% corpus is a D x V logical matrix where corpus(d, n) = 1 if study d reports
% activation in voxel n.
%
% paradigm_by_exp a A x D matrix where paradigm_by_exp(a, d) = 1 if
% author "a" is in study "d"
%
% params is created by EM2_CreateEmptyATParams

rand('twister', sum(10000*params.seed));
lh_avg_mesh = ReadNCAvgMesh('lh', 'fsaverage5', 'inflated', 'cortex');
rh_avg_mesh = ReadNCAvgMesh('rh', 'fsaverage5', 'inflated', 'cortex');
cortex_label = [lh_avg_mesh.MARS_label == 2 rh_avg_mesh.MARS_label == 2];

params = EM2_InitATParams(corpus, paradigm_by_exp, params);
paradigm_by_exp = full(paradigm_by_exp);

params.log_likelihood = -inf;
tic;
for iter = 1:params.em_max_iter
    
    params.doc_log_likelihood = zeros(params.D, 1);
    params.new_theta = zeros([params.A params.T]);
    params.new_beta     = zeros([params.T params.V]);
    params.new_beta_inv = zeros([params.T params.V]);
    
    % e-step
    for d = 1:params.D
        if(size(corpus, 2) == params.V)
            [params, params.doc_log_likelihood(d)] = EM2_doc_e_step(corpus(d, :), paradigm_by_exp(:, d), params);
        elseif(size(corpus, 2) == 1)
            [params, params.doc_log_likelihood(d)] = EM2_doc_e_step_wc(corpus{d}, paradigm_by_exp(:, d), params);
        else
            error('dimensions of corpus wrong');
        end
    end
    
    % store old values first
    old_theta = params.theta;
    old_beta  = params.beta;
    old_beta_inv = params.beta_inv;
    
    % m-step
    params.theta     = params.new_theta + params.virtual_theta;
    params.theta     = bsxfun(@times, params.theta, 1./sum(params.theta, 2));
    params.log_theta = log(params.theta);
    
    params.beta     = params.new_beta + params.virtual_beta;
    params.beta_inv = params.new_beta_inv + params.virtual_beta;
    params.beta = params.beta ./ (params.beta + params.beta_inv);
    params.beta_inv = 1 - params.beta;
    params.log_beta     = log(params.beta);
    params.log_beta_inv = log(params.beta_inv);
    
    % compute likelihood convergence conditions
    new_log_likelihood = sum(params.doc_log_likelihood);
    if(isinf(params.log_likelihood))
        log_likelihood_improvement = inf;
    else
        log_likelihood_improvement = abs(new_log_likelihood - params.log_likelihood)/abs(params.log_likelihood);
    end
    params.log_likelihood = new_log_likelihood;
    
    % compute parameters convergence conditions
    theta_change = abs(old_theta - params.theta);
    beta_change = abs(old_beta - params.beta);
    beta_inv_change = abs(old_beta_inv - params.beta_inv);
    params_change = max([max(theta_change(:)) max(beta_change(:)) max(beta_inv_change(:))]);
    
    disp(['Iter ' num2str(iter, '%03d') ': log likelihood = ' num2str(params.log_likelihood) ' (' num2str(log_likelihood_improvement) ', ' num2str(params_change) '), time elapsed = ' num2str(toc)]);
    tic;
    
    if((log_likelihood_improvement < params.em_convergence || params_change < params.parameter_convergence) && iter >= params.em_min_iter  && mod(iter, params.mod_smooth) ~= 1)
       break; 
    end
    
    if(mod(iter, params.mod_smooth) == 0 && iter ~= params.em_max_iter)
        disp('Smoothing ...');
        process_maps = zeros(params.T, length(lh_avg_mesh.MARS_label)+length(rh_avg_mesh.MARS_label));
        
        % smooth beta
        process_maps(:, cortex_label) = params.beta;
        process_maps(:, 1:10242) = MARS_AverageData(lh_avg_mesh, process_maps(:, 1:10242), 0, params.num_smooth);
        process_maps(:, 10243:end) = MARS_AverageData(lh_avg_mesh, process_maps(:, 10243:end), 0, params.num_smooth);
        params.beta  = full(process_maps(:, cortex_label));
        
        % smooth inv_beta
        process_maps(:, cortex_label) = params.beta_inv;
        process_maps(:, 1:10242) = MARS_AverageData(lh_avg_mesh, process_maps(:, 1:10242), 0, params.num_smooth);
        process_maps(:, 10243:end) = MARS_AverageData(lh_avg_mesh, process_maps(:, 10243:end), 0, params.num_smooth);
        params.beta_inv  = full(process_maps(:, cortex_label));
        
        % re-normalize beta
        params.beta = params.beta ./ (params.beta + params.beta_inv);
        params.beta_inv = 1 - params.beta;
        params.log_beta     = log(params.beta);
        params.log_beta_inv = log(params.beta_inv);
    end
end

% final e-step to compute final log likelihood
params.doc_log_likelihood = zeros(params.D, 1);
for d = 1:params.D
    if(size(corpus, 2) == params.V)
        q = EM2_doc_inference(corpus(d, :), paradigm_by_exp(:, d), params);
        params.doc_log_likelihood(d) = EM2_doc_log_likelihood(corpus(d, :), paradigm_by_exp(:, d), params, q);
    else
        [q1, q0] = EM2_doc_inference_wc(corpus{d}, paradigm_by_exp(:, d), params);
        params.doc_log_likelihood(d) = EM2_doc_log_likelihood_wc(corpus{d}, paradigm_by_exp(:, d), params, q1, q0);
    end
end
params.log_likelihood = sum(params.doc_log_likelihood);
disp(['Final log likelihood: ' num2str(params.log_likelihood)]);


params = rmfield(params, 'new_theta');
params = rmfield(params, 'new_beta');
params = rmfield(params, 'new_beta_inv');
params = rmfield(params, 'log_theta');
params = rmfield(params, 'log_beta');
params = rmfield(params, 'log_beta_inv');

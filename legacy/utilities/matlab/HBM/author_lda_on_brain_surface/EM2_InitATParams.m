function params = EM2_InitATParams(corpus, paradigm_by_exp, params)

% params = EM2_InitATParams(corpus, paradigm_by_exp, params)

params.A = size(paradigm_by_exp, 1);
params.D = size(corpus, 1);

if(size(corpus, 2) == 1)
    params.V = size(corpus{1}, 2);
else
    params.V = size(corpus, 2);
end

if(strcmp(params.init, 'RAND'))
    disp('Initializing randomly');
    
    params.theta     = rand([params.A params.T]);
    params.theta     = bsxfun(@times, params.theta, 1./sum(params.theta, 2));
    
    params.beta = rand([params.T params.V]);
else
    if(strcmp(params.init, 'GIBBS'))
        
        disp('Initializing using Gibbs input');
        load(params.init_file);
        
        lh_avg_mesh = ReadNCAvgMesh('lh', 'fsaverage5', 'inflated', 'cortex');
        rh_avg_mesh = ReadNCAvgMesh('rh', 'fsaverage5', 'inflated', 'cortex');
        cortex_label = [lh_avg_mesh.MARS_label == 2 rh_avg_mesh.MARS_label == 2];
        
        % initialize theta
        if(size(theta, 1) ~= params.A || size(theta, 2) ~= params.T)
            error('Initialization theta not the same size');
        end
        params.theta = full(theta);
        
        % initialize beta
        process_maps = process_maps';
        process_maps(:, 1:10242) = MARS_AverageData(lh_avg_mesh, process_maps(:, 1:10242), 0, params.init_smooth);
        process_maps(:, 10243:end) = MARS_AverageData(lh_avg_mesh, process_maps(:, 10243:end), 0, params.init_smooth);
        
        process_maps = process_maps(:, cortex_label);
        if(size(process_maps, 1) ~= params.T || size(process_maps, 2) ~= params.V)
            error('Initialization beta not the same size');
        end
        params.beta = full(process_maps);
        
        for t = 1:params.T
            params.beta(t, :) = min(params.beta(t, :)/(mean(params.beta(t, :)))*0.5, 0.9);
        end
        
    elseif(strcmp(params.init, 'EM'))
        
        error('Does not handle EM initialization yet');
        
    else
        error('Currently no other initialization');
    end
end

params.beta_inv = 1 - params.beta;
params.log_theta = log(params.theta);
params.log_beta = log(params.beta);
params.log_beta_inv = log(params.beta_inv);



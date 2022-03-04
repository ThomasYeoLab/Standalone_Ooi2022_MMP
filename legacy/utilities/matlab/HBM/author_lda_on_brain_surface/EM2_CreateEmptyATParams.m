function params = EM2_CreateEmptyATParams(SEED, T, init_type, init_file)

params.em_max_iter    = 2000;
params.em_min_iter    = 10;
params.em_convergence = 5e-4;
params.parameter_convergence = 1e-3; 
params.virtual_beta   = 0.01;
params.virtual_theta  = 50/T;
params.num_smooth     = 1;
params.mod_smooth     = 10;

if(nargin < 3)
    params.init = 'RAND';
else
    params.init = init_type;
    params.init_file = init_file;
    params.init_smooth = 5;
end

params.seed = SEED;
params.T = T;

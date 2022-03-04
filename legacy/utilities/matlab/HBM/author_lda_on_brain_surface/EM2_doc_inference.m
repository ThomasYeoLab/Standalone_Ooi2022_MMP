function q = EM2_doc_inference(w, paradigm, params) 

% w is 1 x V logical matrix
% 
% paradigm is a A x 1 logical sparse matrix where paradigm(a) = 1 if
% author "a" is in study
%
% using authors and paradigms interchangeably.

num_paradigms = sum(paradigm);

% Compute q = Ad x T x V
theta = params.theta(paradigm, :); % num_paradigms x T

beta_wd = zeros(params.T, params.V);
beta_wd(:, w == 1) = params.beta(:, w == 1);
beta_wd(:, w == 0) = 1 - params.beta(:, w == 0);
q = zeros([num_paradigms params.T params.V]);
for a = 1:num_paradigms
   q(a, :, :) = bsxfun(@times, beta_wd, theta(a, :)');
end

normalizer = 1./squeeze(sum(squeeze(sum(q, 2)), 1));
for a = 1:num_paradigms
   q(a, :, :) = bsxfun(@times, squeeze(q(a, :, :)), normalizer); 
end

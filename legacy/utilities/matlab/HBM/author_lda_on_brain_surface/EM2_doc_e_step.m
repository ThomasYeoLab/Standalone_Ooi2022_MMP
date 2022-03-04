function [params, doc_log_likelihood, q] = EM2_doc_e_step(w, paradigm, params) 

% w is 1 x V logical matrix
% 
% paradigm is a A x 1 logical sparse matrix where paradigm(a) = 1 if
% author "a" is in study
%
% using authors and paradigms interchangeably.

% q* = Ad x T x V
q = EM2_doc_inference(w, paradigm, params);

% Compute document log likelihood
doc_log_likelihood = EM2_doc_log_likelihood(w, paradigm, params, q);

% update theta for M-step: theta is A x T
params.new_theta(paradigm, :) = params.new_theta(paradigm, :) + squeeze(sum(q, 3)); % Ad x T

% update beta for M-step: beta is T x V
beta_update = squeeze(sum(q, 1)); % T x V
params.new_beta     = params.new_beta + bsxfun(@times, beta_update, w);
params.new_beta_inv = params.new_beta_inv + bsxfun(@times, beta_update, 1 - w);

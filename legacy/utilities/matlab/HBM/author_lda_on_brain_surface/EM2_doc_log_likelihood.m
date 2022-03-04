function doc_log_likelihood = EM2_doc_log_likelihood(w, paradigm, params, q) 

% w is 1 x V logical vector
% 
% paradigm is a A x 1 logical sparse matrix where paradigm(a) = 1 if
% author "a" is in study
%
% q is Ad x T x V matrix obtained from EM2_doc_inference 
% q = p(author, topic | nth vertex activated or not, current estimate of beta and theta) 
%
% using authors and paradigms interchangeably.

log_likelihood_theta = sum(sum(sum(bsxfun(@times, q, log(params.theta(paradigm, :))), 3), 2));

beta_update = squeeze(sum(q, 1)); % T x V
beta_wd = bsxfun(@times, params.log_beta, w) + bsxfun(@times, params.log_beta_inv, 1 - w); % T x V
log_likelihood_beta  = sum(sum(beta_update .* beta_wd, 2));

q_entropy = -sum(sum(sum(q .* log(q), 3), 2));

doc_log_likelihood = log_likelihood_theta + log_likelihood_beta + q_entropy; 

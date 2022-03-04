function doc_log_likelihood = EM2_doc_log_likelihood_wc(w, paradigm, params, q1, q0) 

% w is 2 x V matrix
% w(1, :) is 1 x V vector indicating # times each word exists
% w(2, :) is 1 x V vector indicating # times each word does not exists
% sum(w, 1) is a constant number
% 
% paradigm is a A x 1 logical sparse matrix where paradigm(a) = 1 if
% author "a" is in study
%
% q1 and q0 are Ad x T x V matrix obtained from EM2_doc_inference_wc 
% q1 = p(author, topic | nth vertex activated, current estimate of beta and theta) 
% q0 = p(author, topic | nth vertex not activated, current estimate of beta and theta) 
%
% using authors and paradigms interchangeably.

log_likelihood_theta1 = sum(sum(sum(bsxfun(@times, bsxfun(@times, q1, params.log_theta(paradigm, :)), reshape(w(1, :), [1 1 length(w(1, :))])), 3), 2));
log_likelihood_theta2 = sum(sum(sum(bsxfun(@times, bsxfun(@times, q0, params.log_theta(paradigm, :)), reshape(w(2, :), [1 1 length(w(2, :))])), 3), 2));

beta_update1 = squeeze(sum(q1, 1)); % T x V
log_likelihood_beta1  = sum(sum(bsxfun(@times, beta_update1 .* params.log_beta, w(1, :)), 2));

beta_update0 = squeeze(sum(q0, 1)); % T x V
log_likelihood_beta0  = sum(sum(bsxfun(@times, beta_update0 .* params.log_beta_inv, w(2, :)), 2));

q_entropy1 = -sum(sum(sum(bsxfun(@times, q1 .* log(q1), reshape(w(1, :), [1 1 length(w(1, :))])), 3), 2));
q_entropy0 = -sum(sum(sum(bsxfun(@times, q0 .* log(q0), reshape(w(2, :), [1 1 length(w(2, :))])), 3), 2));

doc_log_likelihood = log_likelihood_theta1 + log_likelihood_theta2 + log_likelihood_beta1 + log_likelihood_beta0 + q_entropy1 + q_entropy0; 

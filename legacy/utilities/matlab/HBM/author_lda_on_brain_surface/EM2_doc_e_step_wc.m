function [params, doc_log_likelihood, q1, q0] = EM2_doc_e_step_wc(w, paradigm, params) 

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

% q* = Ad x T x V
[q1, q0] = EM2_doc_inference_wc(w, paradigm, params);

% Compute document log likelihood
doc_log_likelihood = EM2_doc_log_likelihood_wc(w, paradigm, params, q1, q0);

% update theta for M-step: theta is A x T
params.new_theta(paradigm, :) = params.new_theta(paradigm, :) + ...
                                squeeze(sum(bsxfun(@times, q1, reshape(w(1, :), [1 1 length(w(1, :))])), 3)) + ...
                                squeeze(sum(bsxfun(@times, q0, reshape(w(2, :), [1 1 length(w(2, :))])), 3));
                            
% update beta for M-step: beta is T x V
beta_update1 = squeeze(sum(q1, 1)); % T x V
params.new_beta     = params.new_beta + bsxfun(@times, beta_update1, w(1, :));

beta_update0 = squeeze(sum(q0, 1)); % T x V
params.new_beta_inv = params.new_beta_inv + bsxfun(@times, beta_update0, w(2, :));

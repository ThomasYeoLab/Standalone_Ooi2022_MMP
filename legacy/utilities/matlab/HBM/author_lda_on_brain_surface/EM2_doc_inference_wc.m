function [q1, q0] = EM2_doc_inference_wc(w, paradigm, params) 

% w is 2 x V matrix
% w(1, :) is 1 x V vector indicating # times each word exists
% w(2, :) is 1 x V vector indicating # times each word does not exists
% sum(w, 1) is a constant number
%
% q1 is for activation
% q0 is for non-activation
% q1 = p(author, topic | nth vertex activated, current estimate of beta and theta) 
% q0 = p(author, topic | nth vertex not activated, current estimate of beta and theta) 
%
% paradigm is a A x 1 logical sparse matrix where paradigm(a) = 1 if
% author "a" is in study
%
% using authors and paradigms interchangeably.

num_paradigms = sum(paradigm);
theta = params.theta(paradigm, :); % num_paradigms x T

% Compute q1 = Ad x T x V
% q1 = p(author, topic | nth vertex activated, current estimate of beta and theta) 
q1 = zeros([num_paradigms params.T params.V]);
for a = 1:num_paradigms
   q1(a, :, :) = bsxfun(@times, params.beta, theta(a, :)');
end

normalizer = 1./squeeze(sum(squeeze(sum(q1, 2)), 1));
for a = 1:num_paradigms
   q1(a, :, :) = bsxfun(@times, squeeze(q1(a, :, :)), normalizer); 
end

% Compute q0 = Ad x T x V
% q0 = p(author, topic | nth vertex not activated, current estimate of beta and theta) 
q0 = zeros([num_paradigms params.T params.V]);
for a = 1:num_paradigms
   q0(a, :, :) = bsxfun(@times, params.beta_inv, theta(a, :)');
end

normalizer = 1./squeeze(sum(squeeze(sum(q0, 2)), 1));
for a = 1:num_paradigms
   q0(a, :, :) = bsxfun(@times, squeeze(q0(a, :, :)), normalizer); 
end

function FSM = CBIG_Kernel_with_scale_factor(data_KbyS,type,scale)

% FSM = CBIG_Kernel_with_scale_factor(data_KbyS,type,scale)
% data_KbyS is a KxS matrix, where K is the number of features, S is the
% number of subjects. This function will generate the similarity matrix for
% given data_KbyS. type can be "Gaussian/Exponential/corr". scale is only
% set for "Gaussian/Exponential" kernel.

% Written by Ruby Kong and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


K = size(data_KbyS, 1); % feature number

if(strcmp(type, 'corr'))
    FSM = corr(data_KbyS, data_KbyS);
else
    data_KbyS = zscore(data_KbyS, 0, 2);
end
if(strcmp(type, 'Exponential'))
    FSM = exp(-1*scale*squareform(pdist(data_KbyS'))/K);
elseif(strcmp(type, 'Gaussian'))
    FSM = exp(-1*scale*squareform(pdist(data_KbyS').^2)/K);
end


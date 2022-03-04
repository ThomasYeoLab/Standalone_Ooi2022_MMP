function [dx,ck] = diff( x, fs, dim, horizon, tangency )
%
% [dx,ck] = ant.ts.diff( x, fs, dim, horizon=4, tangency=4 )
%
% Numerical differentiation of sampled sequence.
%
% Example:
%     t = linspace(-2,13,400); 
%     h = t(2)-t(1); 
%     x = sin(t); 
%     y = ant.ts.diff( x, 1/h );
%     plot(t,x,t,y);
%
% Reference: 
% http://www.holoborodko.com/pavel/numerical-methods/numerical-derivative/smooth-low-noise-differentiators/
%
% JH
    
    if nargin < 5, tangency=4; end
    if nargin < 4, horizon=4; end
    if nargin < 3 || isempty(dim)
        % first non-singleton dimension
        dim = ant.nsdim(x);
    end
    if nargin < 2, fs=1; end

    N = 2*horizon+1;
    M = horizon;
    
    switch tangency
        
        % second-order tangency
        case 2
            
            switch horizon
                case 2
                    ck = [2,1]/8;
                case 3
                    ck = [5,4,1]/32;
                case 4
                    ck = [14,14,6,1]/128;
                case 5
                    ck = [42,48,27,8,1]/512;
                otherwise
                    m = (N-3)/2;
                    ck = zeros(1,M);
                    for k = 1:M
                        ck(k) = ( binomial(2*m,m-k+1) - binomial(2*m,m-k-1) )/pow2(2*m+1);
                    end
            end
            
        % fourth-order tangency
        case 4
            
            switch horizon
                case 3
                    ck = [39,12,-5]/96;
                case 4
                    ck = [27,16,-1,-2]/96;
                case 5
                    ck = [322,256,39,-32,-11]/1536;
                otherwise
                    error('No general formula for fourth-order tangency.');
            end
            
        otherwise
            error('Unsupported tangency.');
        
    end
    
    % weights of derivation filter
    ck = [-fliplr(ck),0,ck]*fs; 
    
    % reshape input data as a matrix with dim as first dimension
    [dx,rev] = ant.mat.squash( x, dim ); 
    
    % wextend padds smoothly before filtering
    %dx = conv2( padarray(dx,[M,0],'replicate'), flipud(ck(:)), 'valid' );
    dx = conv2( wextend('ar','sp1',dx,M), flipud(ck(:)), 'valid' ); 
    
    % reshape data to the original size
    dx = ant.mat.unsquash(dx,rev); 

end

function b = binomial(n,k)
    % cf comment: http://www.holoborodko.com/pavel/numerical-methods/numerical-derivative/smooth-low-noise-differentiators/#comment-7533
    if k < 0
        b = 0;
    else
        b = nchoosek(n,k);
    end
end

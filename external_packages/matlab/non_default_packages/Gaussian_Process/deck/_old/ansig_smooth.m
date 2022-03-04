function [env,phi,frq] = ansig_smooth( x, fs, npt )
%
% [env,phi,frq] = ansig_smooth( x, fs, npt )
%
% Compute smooth analytic signal. Method:
% 
%   1. Compute Hilbert envelope and phase
%   2. Enforce non-decreasing assumption on the unwrapped phase
%   3. 
%
%
% JH

    error( 'Not implemented yet' );

    if nargin < 3, npt=5; end
    if nargin < 2, fs=1; end
    
    % compute hilbert transform
    [env,phi] = ant.ts.ansig( x, fs );
    
    % generate time vector
    [nt,ns] = size(x);
    t = (0:nt-1) / fs;

    % deal with phase reversals
    prev = diff(phi,1,1) < -1e-6;
    prev = sum(prev) / (nt-1);
    thresh = max( 1/(nt-1), 1e-3 );
    
    dk.reject('w', any(prev > thresh), 'Too many phase-reversals in signals: %s', ...
        dk.util.vec2str(find(prev > thresh)) ); %#ok
    
    % force phase to be non-decreasing
    pdif = max( 0, diff(phi,1,1) );
    ndph = cumsum([ phi(1,:); pdif ],1);
    
    % points inside the cycle
    ptar = linspace(0,2*pi,npt+2);
    ptar = ptar(2:end-1);
    
    % iterate on target points
    tol = 2*pi / (10*npt);
    pint = cell(1,npt);
    for i = 1:npt
        M = mod(ndph,ptar(i));
        pint{i} = phi;
        for j = 1:ns
            s = M(:,i);
            s = 
            s = interp1( t(s),  );
        end
    end
    
end

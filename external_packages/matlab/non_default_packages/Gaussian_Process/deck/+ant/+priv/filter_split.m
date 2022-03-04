function x = filter_split( get_filt, N )
%
% Recursively split a filter of order N into two filters respectively of order floor(N/2) and ceil(N/2),
% if the original filter has unstable poles. This protects against numerical unstability typically encountered
% with IIR filters.
%
% The first input should be a function handle which, given an order O, returns a structure with fields:
%  'a' the denominator
%  'b' the numerator
%  'o' the corresponding order O
%
% An example of get_filt could be, eg for low-pass Butterworth filters:
%
%   function f = get_filt( ord )
%       f.o = ord; [f.b,f.a] = butter( freq, ord, 'low' );
%   end
%
% where freq is a shared variable representing the relative cutoff frequency (ie Fcut / Fnyquist).
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    x    = get_filt(N);
    stop = false;
    
    assert( dk.is.struct( x, {'a','b','o'} ), ...
        'Handle function get_filt should return a structure with fields {a,b,o}.' );
    
    while ~stop
        y    = [];
        nx   = numel(x);
        stop = true;
        
        for i = 1:nx
            xi = x(i);
            if ~ant.priv.filter_check_stability(xi.a)
                n1   = floor(xi.o/2);
                n2   = ceil(xi.o/2);
                y    = [y,get_filt(n1),get_filt(n2)];
                stop = false;
            else
                y = [y,xi];
            end
        end
        
        x = y;
    end

end

function [f,input] = filter_parse( input )
%
% [f,input] = filter_parse( input )
%
% Parse and return filter structure from various input types.
%
% STRING INPUT:
%
%   Processed using either ant.util.eeg_bands, or assuming that it is a string 
%   representation of a numerical format (see below).
%
% NUMERICAL INPUT:
%
%   Positive scalars are interpreted as a high-pass cutoff.
%   Negative scalars            "         low-pass cutoff.
%   Positive 1x2 vectors        "         band-pass cutoffs.
%   Negative 1x2 vectors        "         band-stop cutoffs.
%
% STRUCTURE INPUT:
%
%   Field 'type' with value in: lowpass, highpass, bandstop, bandpass
%   Field 'freq' with an UNSIGNED numerical format (see above).
%
% See also: ant.util.eeg_bands
%
% JH

    if ischar(input)
        
        % get eeg bands
        eeg = ant.util.eeg_bands();
        
        switch input
            
            case {'','none','broadband'} % no filter
                input = [];
            
            case fieldnames(eeg) % one of the eeg bands
                input = eeg.(input);
                
            otherwise % a "string formatted filter"
                input = str2num(input); %#ok
        end
        
    end
    
    if isstruct(input)
        assert( all(isfield( input, {'type','freq'} )), 'Input structure is missing required fields.' );
        f = input; return;
    end
    
    assert( isnumeric(input), 'Input should be numeric at this stage.' );
    switch numel(input)
        
        case 0 % no filter
            
            f = [];
            
        case 1 % eg '+25' or '-16'
            
            if input < 0
                f.type = 'lowpass';
                f.freq = -input;
            else
                f.type = 'highpass';
                f.freq = input;
            end
            
        case 2  % eg [13,31] or -[5,12]
            
            assert( prod(input) >= 0, 'Signs of frequency bounds should be the same.' );
            if any(input < 0)
                f.type = 'bandstop';
                f.freq = -input;
            else
                f.type = 'bandpass';
                f.freq = input;
            end
            
        otherwise
            error('Unable to parse input as a filter.');
        
    end

end

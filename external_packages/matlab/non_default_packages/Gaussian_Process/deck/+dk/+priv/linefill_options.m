function [popt,fopt,fface] = linefill_options(varargin)

    colors = dk.color.jh();

    popt = {};
    fopt = {};
    fdef = colors.brick; % default fill edge color

    % sort out inputs
    switch nargin
        case 0
            theme = 'default';
        case 1
            theme = varargin{1};
            assert( ischar(theme), 'Theme should be a string.' );
        case 2
            theme = 0;
            popt = varargin{1};
            fopt = varargin{2};
    end
    
    % apply color themes
    switch theme
        case {'default','darkred'}
            popt = colors.dark;
            fopt = colors.carmine;
        case 'bluered'
            popt = colors.teal;
            fopt = colors.brick;
        case 'win'
            popt = colors.oxford;
            fopt = colors.winred;
    end
    
    % convert options to cells
    if isnumeric(popt)
        assert( numel(popt)==3, 'Color vector should be 1x3.' );
        popt = struct( 'LineWidth', 1.5, 'Color', popt );
    elseif iscell(popt)
        popt = dk.c2s(popt{:});
    end
    assert( isstruct(popt), 'Bad line properties.' );
    
    if isnumeric(fopt)
        assert( numel(fopt)==3, 'Color vector should be 1x3.' );
        fopt = struct( 'LineWidth', 1, 'EdgeColor', fopt, 'FaceAlpha', 0.85 );
    elseif iscell(fopt)
        fopt = struct(fopt{:});
    end
    assert( isstruct(fopt), 'Bad fill properties.' );
    
    % ensure that the face color is set
    fedge = dk.struct.get( fopt, 'EdgeColor', fdef );
    fface = hsv2rgb(rgb2hsv(fedge) .* [1,0.9,1]);
    
    % extract struct values to cell
    popt = dk.struct.to_cell(popt);
    fopt = dk.struct.to_cell(fopt);
    
end

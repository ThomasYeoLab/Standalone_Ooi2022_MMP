function style = export( fig, fname, style )
% 
% style = dk.fig.export( fig, fname, style )
%
% Export a figure "fig" to an image named "fname" using the export style (string or struct) "style".
% If the style is specified as a string, then the style is loaded from Matlab and this might throw 
% an error if it doesn't exist. 
%
% NOTE: Format field in the style is overriden if filename specifies the extension.
% 
% JH

    if ischar(style), style = hgexport('readstyle',style); end

    [~,~,ext] = fileparts(fname);
    if ~isempty(ext)
        style.Format = dk.str.lstrip(ext,'.');
    end
    
    hgexport( fig, fname, style );
    dk.print( '[dk.fig.export] Saved as: %s', fname );
    
end

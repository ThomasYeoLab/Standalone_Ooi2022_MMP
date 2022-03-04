function names = list_ext( dirname, ext, hidden, folders )
%
% names = list_ext( dirname, ext, hidden=false, folders=false )
% 
% List files by extension in directory dirname.
% If hidden is true, then hidden files are included too.
% If folders is true, then directories with that extension are included too.
%
% JH

    if isempty(dirname), dirname=pwd; end
    if nargin < 3 || isempty(hidden), hidden=false; end
    if nargin < 4, folders=false; end
    
    assert( ~isempty(ext), 'Extension cannot be empty.' );
    if ext(1) == '.' % remove only one dot
        ext = ext(2:end);
    end
    
    if hidden
        pattern = ['^.*\.' ext '$'];
    else
        pattern = ['^[^\.].*\.' ext '$'];
    end
    
    if folders
        filter = @(x) true;
    else
        filter = @(x) ~x.isdir;
    end
    
    names = dk.fs.match( dirname, pattern, filter );
    
end

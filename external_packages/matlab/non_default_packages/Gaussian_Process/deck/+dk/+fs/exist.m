function y = exist( name, kind )
%
% y = dk.fs.exist( name, kind=any )
% 
% Enhanced exist function.
%
% kind:
%   any
%       anything
%   file
%       fs file, not a folder
%   link, symlink
%       fs symlink
%   dir, folder
%       fs folder
%   var, variable
%       env variable
%   function, fun
%       env function
%   builtin
%       env builtin function
%   mfile, mscript
%       fs matlab script on the path
%   mex, mexfile
%       fs mex script on the path
%   class
%       env class
%
% JH

    if nargin < 2, kind='any'; end
    
    e = exist(name);
    switch lower(kind)
        
        case 'any'
            y = (e > 0) || ~isempty(which(name)) || ~isempty(dir(name));
        
        case 'file'
            y = dir(name);
            y = ~isempty(y) && isscalar(y) && ~y.isdir;
            
        case {'symlink','link'}
            y = dk.fs.islink(name);
            
        case {'folder','dir'}
            y = (e == 7);
            
        case {'variable','var'}
            y = (e == 1);
            
        case 'builtin'
            y = (e == 5);
            
        case {'function','fun'}
            y = ismember( e, [2 3 5 6] ) || ( (e ~= 8) && ~isempty(which(name)) );
            
        case {'mfile','mscript'}
            [~,~,y] = fileparts(which(name));
            y = strcmpi(y,'.m');
            
        case {'mexfile','mex'}
            [~,~,y] = fileparts(which(name));
            y = ~isempty(strfind(y,'.mex')); %#ok
            
        case 'class'
            y = (e == 8);
            
    end

end

function [extfun,matfun] = dependencies( name, recursive )
%
% [extfun,matfun] = dependencies( name, recursive = false )
%
% List all functions used in Matlab script "name" or in all Matlab scripts in directory "name".
%
% INPUT
%   name        Full path to either a Matlab script or a directory containing Matlab scripts.
%
% OUTPUT
%   Two cell arrays containing respectively non-native and built-in Matlab functions.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 2, recursive = false; end

    % If input is a directory, process each file
    if dk.fs.isdir( name )
        files  = dk.fs.lsdir( name );
        extfun = struct();
        matfun = struct();
        
        for i = 1:length(files)
            
            file    = files{i};
            [~,f,e] = fileparts(file);
            file    = fullfile(name,file);
            
            if ( recursive && dk.fs.isdir(file) ) || strcmpi(e,'.m')
                [extfun.(f),matfun.(f)] = dk.util.dependencies(file);
            end
        end
        return
    end
    
    % Only accept Matlab scripts
    assert( strcmpi( name(end-1:end), '.m' ), 'This function only accepts Matlab scripts with ".m" extension.' );
    
    % Prepare outputs
    extfun = {};
    matfun = {};

    % The matlab root for the current instance
    mroot = matlabroot;
    mlen  = length(mroot);
    is_matlab_fun = @(x)( strcmp( x(1:mlen), mroot ) ); % compare function path to Matlab's root dir
    
    % List all dependencies in the target script
    list = matlab.codetools.requiredFilesAndProducts( name );
    nfun = length(list);
    
    % Iterate through each dependency and determine whether it's a Matlab function
    for i = 1:nfun
        
        fun = list{i};
        
        % Decompose function
        [d,f,e] = fileparts(fun);
        fun = struct( ...
            'dir', d, 'name', f, 'ext', e ...
        );
        
        if is_matlab_fun(d)
            matfun{end+1} = fun;
        else
            extfun{end+1} = fun;
        end
    end
    
end

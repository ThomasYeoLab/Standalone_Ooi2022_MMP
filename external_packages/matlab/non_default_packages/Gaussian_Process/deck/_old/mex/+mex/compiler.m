function C = compiler( verbose, debug )

    if nargin < 2, debug   =false; end
    if nargin < 1, verbose =false; end

    C = dk.obj.Compiler();
    
    % Matlab version
	mver  = version('-release');
	myear = str2double( mver(1:4) );
    
    % general compiler options
    C.optimize = ~debug;
    C.debug    =  debug;
    C.verbose  = verbose;
    
    % use custom mex options
    here = fileparts(mfilename('fullpath'));
    if myear >= 2016
        if ismac()
            % NOTE:
            %
            % If you get an error about no supported compiler found, run:
            %   xcrun --show-sdk-path
            %   
            % If the version number MacOSX10.xx.sdk does not appear in the XML file:
            %   dk.path('+mex','clang++_maci64.xml')
            % specifically under
            %   blocks <ISYSROOT> and <SDKVER>, subblock <dirExists>
            % 
            % Then it is possible to add entries of <dirExists> blocks manually, with 
            % newer SDK versions. See: 
            %
            % https://uk.mathworks.com/matlabcentral/answers
            %      /243868-mex-can-t-find-compiler-after-xcode-7-update-r2015b#answer_192936
            %
            C.opt_file = fullfile( here, 'clang++_maci64.xml' );
        else
            C.opt_file = fullfile( here, 'g++_glnxa64.xml' );
        end
    else
        C.opt_file = fullfile( here, 'mexopts.sh' );
    end

end

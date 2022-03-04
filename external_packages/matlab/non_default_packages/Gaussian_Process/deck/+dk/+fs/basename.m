function b = basename(x)
%
% b = dk.fs.basename(x)
%
% Return filename+extension, as obtained with the 2nd and 3rd output of fileparts.
% Output is empty if path x ends with a filesep (e.g. 'foo/bar/').
%
% See also: fileparts, dk.fs.dirname
%
% JH

    [~,f,e] = fileparts(x);
    b = [f,e];

end
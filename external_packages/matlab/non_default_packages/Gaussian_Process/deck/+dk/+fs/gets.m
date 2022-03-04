function txt = gets( name )
%
% Extract the text contents of an existing file into a single string.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    txt = fileread(name);
end

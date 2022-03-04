function compile( comp, files, out_folder, out_name )

    if ischar(files), files = {files}; end
    assert( iscellstr(files), 'Expected a cell-array of filenames in input.' );

    if nargin > 2
        comp.out_dir = out_folder;
    else
        comp.out_dir = pwd;
    end
    
    if nargin > 3
        comp.out_name = out_name;
    end

    comp.rem_files();
    for i = 1:numel(files)
        comp.add_file( files{i} );
    end

    comp.print();
    comp.compile();

end

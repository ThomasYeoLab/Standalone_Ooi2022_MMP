function chk_dir(x)
    dk.assert( dk.fs.isdir(x), 'Not a directory: %s', x );
end

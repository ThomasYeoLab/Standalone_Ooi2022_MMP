function chk_file(x)
    dk.assert( dk.fs.isfile(x), 'File not found: %s', x );
end

function logger_handle()

    print1 = @(x) dk.info( 'Print1: %s', x );
    print2 = @dk.info;
    
    print1('Hello');
    print2('Bonjour');

end
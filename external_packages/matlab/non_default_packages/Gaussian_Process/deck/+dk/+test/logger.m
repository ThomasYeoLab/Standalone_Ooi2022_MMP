classdef logger < handle
    
    methods
        
        function self = logger()
            self.gne();
            baz();
        end
        
        function gne(self)
            dk.log( 'i', 'Foo' );
            self.bar();
        end
        
        function bar(self)
            dk.log( 'd', 'Bar' );
        end
        
    end
    
end

function baz()
    dk.reject( 'w', 5 > 3, 'Thats not right' );
    dk.assert( 'e', 3 > 5, 'Who am I' );
end
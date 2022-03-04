classdef Timer < handle
%
% A lightweight timer class using cputime.
% It includes a simple linear estimation of timeleft from the amoung of task done, 
% which is useful to monitor the progress of long tasks.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk
    
    properties (SetAccess = private)
        start_time;
        last_step;
    end
    
    methods
        
        function self = Timer()
            self.start();
        end
        
        function start(self)
            self.start_time = tic;
            self.last_step = 0;
        end
        
        function t = restart(self)
            t = self.runtime();
            self.start();
        end
        
        % Runtime
        function t = runtime(self)
            t = toc(self.start_time);
        end
        function s = runtime_str(self)
            t = self.runtime();
            s = dk.time.sec2str(t);
        end
        
        % Linear timeleft estimation
        function t = timeleft(self,fraction_done)
            t = self.runtime();
            t = t / fraction_done - t;
        end
        function s = timeleft_str(self,fraction_done)
            t = self.timeleft(fraction_done);
            s = dk.time.sec2str( t );
        end
        
        % show timeleft
        function showleft(self,fraction_done,fraction_step)
            if nargin < 3, fraction_step=0.1; end
            if fraction_done >= 1
                disp( 'Done!' );
            elseif fraction_done > self.last_step
                self.last_step = self.last_step + fraction_step;
                dk.print( 'Timeleft [%d %%]: %s', ...
                    floor(100*fraction_done), self.timeleft_str(fraction_done) );
            end
        end
        
    end
    
end

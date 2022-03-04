function c = jh(name)
%
% My collection of colors
%

    m = dk.cmap.jh();

    c.black   = [0,0,0];
    c.white   = [1,1,1];
    c.gray1   = 0.1*[1,1,1];
    c.gray2   = 0.2*[1,1,1];
    c.gray3   = 0.3*[1,1,1];
    
    c.light   = [0.95,0.95,0.96];
    c.dark    = [0.1,0.14,0.13];
    c.gray    = [0.25,0.25,0.28];
    c.beige   = [0.98,0.92,0.84];
    c.cream   = [0.96,1,0.98];
    
    c.purple  = [0.5,0,0.5];
    c.pink    = [1,0,0.5];
    c.rose    = [1,0.16,0.64];
    c.fushia  = [0.96,0,0.63];
    c.tang    = [0.95,0.52,0];
    c.rtang   = [0.98,0.3,0];
    c.ytang   = [1,0.8,0];
    
    c.teal    = [0,0.5,0.5];
    c.azure   = [0,0.22,0.66];
    c.royal   = [0,0.14,0.4];
    c.ink     = [0,0.19,0.33];
    c.bottle  = [0,0.25,0.25];
    
    c.oxford  = [0,13,28]/100;
    c.winred  = [51,12,17]/100;
    
    c.red     = [1,0.11,0];
    c.carmine = [1,0,0.22];
    c.brick   = [0.89,0.26,0.2];
    c.ruby    = [0.88,0.07,0.37];
    c.brown   = [0.7,0.11,0.11];
    c.wine    = m(1,:);
    c.orange  = m(2,:);
    c.yellow  = m(3,:);
    c.green   = [0.4,1,0];
    c.leaf    = m(4,:);
    c.cyan    = m(5,:);
    c.blue    = [0,0.3,1];
    c.sky     = m(6,:);
    
    if nargin > 0
        c = c.(name);
    end
    
end

% old
% color_blue = lab2rgb([60 -5 -30]);
% color_red  = lab2rgb([60 45  20]);
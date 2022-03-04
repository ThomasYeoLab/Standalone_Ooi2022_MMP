function rescale( f, factor )
%
% dk.fig.rescale( f, factor )
%
% Multiply the current size of the figure by a real factor.
%
% JH

    [~,hw] = dk.fig.position(f);
    dk.fig.resize( f, factor*hw );

end
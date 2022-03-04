function h = wg_Slider()

    p = uicontainer( 'parent', figure );
    h = dk.widget.Slider(p).set_range( [0,100], 4 );

end
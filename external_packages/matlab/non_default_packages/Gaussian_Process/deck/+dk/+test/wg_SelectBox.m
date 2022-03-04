function h = wg_SelectBox()

    p = uicontainer( 'parent', figure );
    h = dk.widget.SelectBox(p).set_choices({ 'First', 'Second', 'Third' }).select(3);
    h.callback = @cb_select;
    
end

function cb_select(idx,str)
    fprintf( 'Choice %d: %s\n', idx, str );
end
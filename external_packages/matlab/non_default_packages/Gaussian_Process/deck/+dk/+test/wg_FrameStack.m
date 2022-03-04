function h = wg_FrameStack()

    p = uicontainer( 'parent', figure );
    I = dk.test.data_cameraman(10);
    h = dk.widget.FrameStack(p).set_frames(I).select_frame(3);

end
function [h1,h2] = wg_ImageBox()

    p1 = uicontainer( 'parent', figure );
    I1 = dk.test.data_cameraman(10);
    h1 = dk.widget.ImageBox(p1).set_images(I1).select_image(3);
    
    p2 = uicontainer( 'parent', figure );
    C = imread('cameraman.tif');
    P = imread('peppers.png');
    I2 = dk.struct.array( 'img', {C,P}, 'name', {'Cameraman','Peppers'} );
    h2 = dk.widget.ImageBox(p2).set_images(I2).select_image(2);
    
end
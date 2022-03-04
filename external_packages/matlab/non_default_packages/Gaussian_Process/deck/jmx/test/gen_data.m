function s = gen_data()
%
% Generate data and save it as a MAT file.
%

    s.logt = true;
    s.logf = false;
    
    s.num1 = 0;
    s.num2 = 1;
    s.num3 = -1;
    s.num4 = pi;
    s.num5 = inf;
    s.num6 = nan;
    
    s.vec1 = [];
    s.vec2 = [1,2,3];
    s.vec3 = [3,2,1]';
    
    s.mat1 = toeplitz(1:5);
    s.mat2 = [1;2] * [10,11,12];
    s.mat3 = zeros(0,23);
    
    s.vol1 = cat( 3, s.mat1, s.mat1+10, s.mat1+20 );
    s.vol2 = bsxfun( @times, s.mat2, reshape( 100*(1:4), [1,1,4] ) );
    s.vol3 = zeros(0,23,42);
    
    s.str1 = 'Hello World';
    s.str2 = '';
    
    s.map1 = struct( 'a',true, 'b',[1,nan,3], 'c','hi', 'd',struct(), 'e',{} );
    s.map2 = repmat( s.map1, [2,3] );
    s.map3 = struct();
    
    s.cel1 = { true, [1,nan,3], 'hi', struct(), {} };
    s.cel2 = num2cell( s.vol2 );
    s.cel3 = {};
    
    save( 'data.mat', '-v7', '-struct', 's' );
    
end
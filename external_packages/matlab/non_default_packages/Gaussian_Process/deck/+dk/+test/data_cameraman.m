function I = data_cameraman( n )
%
% I = data_cameraman( n=1 )
%
% Return images of cameraman.
% If n > 1, blur with increasing sigma.
%

    if nargin < 1, n=1; end
   
    I = cell(1,n);
    I{1} = imread('cameraman.tif');
    for k = 2:n
        I{k} = imgaussfilt( I{1}, k/2 );
    end
    if n == 1, I = I{1}; end

end
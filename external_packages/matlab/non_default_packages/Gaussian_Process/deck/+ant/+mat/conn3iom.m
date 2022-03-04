function [o,m] = conn3iom(sz,conn)
%
% [o,m] = ant.mat.conn3iom(sz,conn)
%
% 3D neighbourhood connectivity index-offset mask (6,18,26).
%
% INPUT:
%   sz the size of the image in which we are looking for neighbours
%   conn the connectivity number
%
% OUTPUT
%   o the neighbour offsets (plain indices)
%   m 3x3x3 binary mask
%
% JH

    if nargin < 2, conn=18; end
    a = zeros(3,3,3);
    
    % dim 1
    o = 1;
    a(1,:,:) = a(1,:,:)-o;
    a(3,:,:) = a(3,:,:)+o;
    
    % dim 2
    o = sz(1);
    a(:,1,:) = a(:,1,:)-o;
    a(:,3,:) = a(:,3,:)+o;
    
    % dim 3
    o = sz(1)*sz(2);
    a(:,:,1) = a(:,:,1)-o;
    a(:,:,3) = a(:,:,3)+o;
    
    % create mask of connectivity
    switch conn
        case 6
            m = false(3,3,3);
            m(2,2,1)=true;
            m(2,1,2)=true;
            m(1,2,2)=true;
            m(2,2,3)=true;
            m(2,3,2)=true;
            m(3,2,2)=true;
        case 18
            m = true(3,3,3);
            m(1,1,1)=false;
            m(2,2,2)=false;
            m(3,3,3)=false;
            m(1,1,3)=false;
            m(1,3,1)=false;
            m(3,1,1)=false;
            m(3,3,1)=false;
            m(3,1,3)=false;
            m(1,3,3)=false;
        case 26
            m = true(3,3,3);
            m(2,2,2) = false;
        otherwise
            error('Unknown 3D connectivity.');
    end
    
    o = a(m);

end
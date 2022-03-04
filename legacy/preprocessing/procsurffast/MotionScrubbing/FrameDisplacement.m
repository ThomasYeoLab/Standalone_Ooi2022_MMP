function FD = FrameDisplacement(motionrelrms)
% This script extract relative motion text file (as specified by motionrelrms)
% Written by Jesisca Tandi and Thomas Yeo

if (nargin ~=1)
	error('FD : cannot find motion estimate file')
end

FD_fid = fopen([motionrelrms]);
FD = fscanf(FD_fid, '%f'); FD(1) = [];

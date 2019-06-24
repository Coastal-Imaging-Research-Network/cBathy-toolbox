function [subG, subXY, camUsed] = ...
        spatialLimitBathy(G, xyz, cam, xm, ym, Lx, Ly, maxNPix )

%% spatialLimitBathy -- extract appropriate data from stack for 
% [subG, subXYZ] = spatialLimitBathy( G, xyz, cam, xm, ym, Lx, Ly, maxNPix )
%
%  Take the full array of stack locations in xyz, G(nF by Nxy) and find
%  those in a tile of size Lx by Ly around and analysis point xm, ym,
%  allowing there to be a max of maxNPix.

% these are the indices of xy data that are within our box
idUse = find( (xyz(:,1) >= xm-Lx) ...
         &    (xyz(:,1) <= xm+Lx) ...
         &    (xyz(:,2) >= ym-Ly) ...
         &    (xyz(:,2) <= ym+Ly) );
 
% first decimate to maxNPix per tile, then drop minority cameras at seams.
% Otherwise you end up limited only by maxNPix and the weightings get funny
% for tiles with partial coverage.

del = max(1, length(idUse)/maxNPix);
idUse = idUse(round(1: del: length(idUse)));

subG = G(:,idUse);
subXY = xyz(idUse,1:2);
cams = cam(idUse);

% if on seam, limit to the dominant camera bypixel count
uniqueCams = unique(cams);
for i = 1: length(uniqueCams)
    N(i) = length(find(cams==uniqueCams(i)));
end

pick = [];
camUsed = -1;

if exist('N')
    [~,pickCam] = max(N);
    pick = find(cams==uniqueCams(pickCam));
    camUsed = uniqueCams(pickCam);
end
subG = subG(:,pick);   % keep only those for the majority camera
subXY = subXY(pick,:);

%
% Copyright by Oregon State University, 2011
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: spatialLimitBathy.m,v 1.2 2016/02/11 00:34:38 stanley Exp $
%
% $Log: spatialLimitBathy.m,v $
% Revision 1.2  2016/02/11 00:34:38  stanley
% toss bad data in subG
%
% Revision 1.1  2012/09/24 23:33:30  stanley
% Initial revision
%
%
%key 
%comment  
%

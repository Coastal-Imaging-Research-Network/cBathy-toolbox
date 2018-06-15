function map = showcBathyTimeSeriesMovie(sn,pa, map)
%
%  map = showcBathyTimeSeriesMovie(stackName,pixArraySpecs,map)
%
%  load a full cBathy data collection and show as a movie.  This is to
%  allow debugging, i.e. letting you see if actual waves are there.
%  The pixels are converted from discrete locations to a mapping in a
%  regular array under the assumption that they were designed as an array.
%  The array is described by user input information
%
%  if pixArraySpecs is missing or empty, create a default array covering
%  the entire stack collection area at a spacing of 20m. If is is a 2
%  element array, it is [dx dy]. Otherwise
%  pixArraySpecs = [xMin dx xMax yMin dy yMax].  
%
%  The mapping between stack
%  columns and this array is returned as map and can presumably be used many
%  times if the geometry is unchanging.
%
%  If nargin is three, the third argument is assumed to be the mapping and
%  a new map is not calculated.

DBConnect;
n = parseFilename(sn);
eval(n.station)
bathy.epoch = n.time; bathy.sName = sn; bathy.params = params;
[xyz, epoch, data, cam] = loadBathyStack(bathy.sName, bathy.params.DECIMATE);

% if there was no map passed in, create an empty one
if nargin < 3
    map = [];
end

% if nargin < 2, create a default pa
if nargin < 2
    pa = [ 20 20 ];
end

if( length(pa) == 2 )
     pa = [min(xyz(:,1)) pa(1) max(xyz(:,1)) ...
           min(xyz(:,2)) pa(2) max(xyz(:,2)) ];
end

% and then call this function. If it has a valid map, it will
% create only x and y. This is to keep from duplicating code
% to do that.
[x,y,map] = findInterpMap( xyz, pa, map );
Nx = length(x); 
Ny = length(y);

figure(2); clf; colormap gray
I = nan(Ny,Nx);
for ii = 1: length(epoch)
    I = reshape(data(ii,map),Ny,Nx);
    imagesc(x,y,log(I)); axis xy; axis equal; axis tight
    pause(0.2)
end

%   Copyright (C) 2017  Coastal Imaging Research Network
%                       and Oregon State University

%    This program is free software: you can redistribute it and/or
%    modify it under the terms of the GNU General Public License as
%    published by the Free Software Foundation, version 3 of the
%    License.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see
%                                <http://www.gnu.org/licenses/>.

% CIRN: https://coastal-imaging-research-network.github.io/
% CIL:  http://cil-www.coas.oregonstate.edu


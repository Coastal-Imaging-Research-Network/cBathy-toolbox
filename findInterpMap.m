function [x,y,map,wt] = findInterpMap(xyz,pa,map,kn,doNan)
%  [x,y,map,weight] = findInterpMap(xyz,pixelArray,map,N,doNan);
%
%  compute a lookup interpolation map between columns of a stack and an
%  intended array described by pixelArray = [xmin dx xmax ymin dy ymax]
%  that could be the intended array of pixel locations or perhaps the array
%  of cBathy analysis points or whatever.
%
%  this function used knnsearch to return the N nearest neighbors and the
%  weights for each mapping distance.
%
%  If 'map' is empty or omitted, a new map will be created. Otherwise, the main 
%  result of this function will be the x,y output locations.
%
%  if N is omitted, it will be set to 1.
%  
%  doNan is a flag that specifies that any points further than doNan units
%  away from the nearest neighbor will return -1 in map, which will be
%  converted to NaN in the output of useInterpMap. Zero means don't do
%  that. If you use doNan, you must provide N. 

x = [pa(1):pa(2):pa(3)];
y = [pa(4):pa(5):pa(6)];

if nargin  == 3
    kn = 1;
    doNan = 0;
end

if length(map) == 1 % how many weights to return
    kn = map;
    map = [];
end

if nargin < 5
    doNan = 0;
end

if ~isempty(map)
    return;
end

Nx = length(x); 
Ny = length(y);
[X,Y] = meshgrid(x,y);      % target grid points
X = X(:); Y = Y(:);

[map,dist] = knnsearch(xyz(:,1:2), [X Y], 'k', kn);

wt = 1 ./ (dist+eps);  % weights!
% sw = sum(dist,2);
% for ii=1:size(dist,2)
%     wt(:,ii) = dist(:,ii) ./ sw;
% end

wt = wt ./ repmat(sum(wt,2),1,kn);

% one last bit, if we doNan, do it here.
if doNan > 0
    % set ANY wt that is outside doNam dist to NaN
    % useInterpMap2 will return NaN value!
    wt(dist>doNan) = NaN;    
end


return;
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
%
%key cBathy
%


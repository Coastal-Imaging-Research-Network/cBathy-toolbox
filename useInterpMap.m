function out = useInterpMap2( in, map, weight )

% function out = useInterpMap2( in, map, weight )
%
%   use the indices in the NxM array 'map' to remap the data in the Lx1
%   data array 'in' into an interpolated output 'out', with weights in the
%   NxM array "weight". 
%
%   map and weight are produced by findInterpMap2.
%

if isempty(map)
    warn('no map in input');
end

if isempty(weight)
    warn('no weighting array');
end

if (size(map) ~= size(weight))
    warn('map and weight must have same size!');
end

in = in(:);
% must loop, until Rob can find an elegant way
out = in(map(:,1)) .* weight(:,1);
for ii = 2:size(map,2);
    out = out + in(map(:,ii)) .* weight(:,ii);
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
%
%key cBathy
%


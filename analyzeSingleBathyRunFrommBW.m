function bathy = analyzeSingleBathyRunFrommBW(mBWPathname, n)
% To run this code, the second input should be a structure with the
% station (name of the m file with input parameters, e.g. argus02b)
% and an epoch time.
% The first input should be the input MAT file.
% Output will be the bathy data.

eval(n.station)
bathy.epoch = n.time; bathy.sName = mBWPathname; bathy.params = params;
load(mBWPathname)
bathy = analyzeBathyCollect(XYZ, T(:), RAW, CAM, bathy);

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


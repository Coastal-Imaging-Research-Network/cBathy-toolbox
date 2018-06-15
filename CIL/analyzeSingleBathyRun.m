function bathy = analyzeSingleBathyRun(stackName)
%
%  bathy = analyzeSingleBathyRun(stackName)
%
%  simple run of analyzeBathyCollect for a single stackName.  Useful for
%  debugging.  Assumes CIL compatible stack.

DBConnect;
n = parseFilename(stackName);
eval(n.station)
bathy.epoch = n.time;
bathy.sName = stackName;
bathy.params = params;
[xyz, epoch, data, cam] = loadBathyStack(bathy.sName, bathy.params.DECIMATE);
bathy = analyzeBathyCollect(xyz, epoch, data, cam, bathy);

%
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


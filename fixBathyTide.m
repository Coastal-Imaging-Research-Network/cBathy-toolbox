
function bathy = fixBathyTide( bathy)

%%
%
%  bathy = fixBathyTide(bathy);
%
%    fix the tide levels in a bathy. I.e., find the current 
% predicted or measured tide and subtract it from the h.
% This routine now accepts CIL compatible and non-compatible inputs.  If
% bathy.sName (the stack name) can be parsed successfully using
% parseFilename, use the tide function with two arguments, the station and
% the epoch.  This ensures that we can't mistakenly find tides from the
% wrong station (because the station name comes from the stack name).  If
% parseFilename fails, the user is responsible for ensuring they have
% supplied a correct tide function in params.tideFunction and only the
% epoch time is passed as an input.
%

%% Find estimated depths and tide correct, if tide data are available.
  
if (exist(bathy.params.tideFunction,'file') ~= 2)   % existing function
	return;
end

try
        foo = parseFilename(bathy.sName);
        if isempty(foo)         % not CIL compatible
            eval(['tide = ' bathy.params.tideFunction '(' bathy.epoch ');'])
        else    % CIL formatted stackname, hence CIL format tide function
            eval(['tide = ' bathy.params.tideFunction '(''' ...
                foo.station ''',' bathy.epoch ');'])
        end

	if(~isfield(bathy,'tide'))
		bathy.tide = tide;
		bathy.tide.zt = NaN;  % will correct with tide.zt later
    end

	tidecorr = sum( [bathy.tide.zt -1*tide.zt],'omitnan');
	bathy.fDependent.hTemp = bathy.fDependent.hTemp + tidecorr;
	bathy.fCombined.h = bathy.fCombined.h + tidecorr;
	bathy.tide = tide;
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


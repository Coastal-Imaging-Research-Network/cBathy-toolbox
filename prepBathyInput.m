function [f, G, bathy] = prepBathyInput( xyz, epoch, data, bathy )

%% prepBathyInput
%
%  [f, G, bathy] = prepBathyInput( xyz, epoch, data, bathy )
%
%  take stack data from mBW bathy stacks and create the fft-ed intermediate
%   and a list of all x and y for analysis. Fill in empty bathy struct.
%
%  x and y are in bathy.xm, bathy.ym
%

%% 1.  Common Fourier calculations

% do the common tasks of Fourier transform, normalizing and getting
% rid of extraneous frequencies.  Keep memory use to a minimum.  Note
% that I get rid of all extraneous frequencies (including the upper
% reflected portion that are conjugates).  Note that the data are 
% detrended.

params = bathy.params;      % extract for ease of use.

% deal with epoch that is row vs. columns
if(size(epoch,2) > size(epoch,1))
	epoch = epoch';
end

% fB are the center frequencies for potential analysis
fB = params.fB; 
dfB = fB(2)-fB(1);      % assumes constant spacing

% detrend the columns (time series), fft (G is complex).
G = fft(detrend(double(data)));

% dt is timestep  
dt = mean(diff(epoch(:,1)));

% frequencies of fft run from 0 1/(N-1) by 1/N
df = 1/(size(epoch,1)*dt);
f = [0: df: 1/(2*dt)-df];

% find results of fft that are within the desired frequency limits
id = find((f >= (fB(1)-dfB/2)) & (f <= (fB(end)+dfB/2)));
f = f(id);
G = G(id,:);
G = G./abs(G);  % scale spectral results to 1.

%%   2.  Define the analysis domain. 

% size of x and y intervals
dxm = params.dxm; 
dym = params.dym;

% span from the minimum X to maximum X in steps of dxm. Ditto Y.
%  round lower boundary.  If exists xyMinMax, let user set xm, ym.
if ~isempty(params.xyMinMax)
    xm = [params.xyMinMax(1): dxm: params.xyMinMax(2)];
    ym = [params.xyMinMax(3): dym: params.xyMinMax(4)];
else
    xm = [ceil(min(xyz(:,1))/dxm)*dxm: dxm: max(xyz(:,1))];
    ym = [ceil(min(xyz(:,2))/dym)*dym: dym: max(xyz(:,2))];
end

if (cBDebug(params, 'DOPLOTPHASETILE'))    % allow user to change array
    [xm,ym] = alterAnalysisArray(xm,ym);
end

%% 3.  Create initial empty struct
bathy.tide.zt = nan;
bathy.tide.e = 0;
bathy.tide.source = '';
bathy.xm = xm;
bathy.ym = ym;

% number of analysis points in x and y
Nxm = length(xm); 
Nym = length(ym); 
nanArray = nan(Nym, Nxm);
fNanArray = nan([Nym, Nxm, params.nKeep]);

bathy.timex = nanArray;

bathy.fDependent.fB = fNanArray;
bathy.fDependent.k = fNanArray;
bathy.fDependent.a = fNanArray;
bathy.fDependent.hTemp = fNanArray;
bathy.fDependent.kErr = fNanArray;
bathy.fDependent.aErr = fNanArray;
bathy.fDependent.hTempErr = fNanArray;
bathy.fDependent.skill = fNanArray;
bathy.fDependent.dof = fNanArray;
bathy.fDependent.lam1 = fNanArray;
bathy.fDependent.NPixels = fNanArray;
bathy.fDependent.NCalls = fNanArray;
bathy.fDependent.kSeed = fNanArray;
bathy.fDependent.aSeed = fNanArray;
bathy.fDependent.camUsed = nanArray;

bathy.fCombined.h = nanArray;
bathy.fCombined.hErr = nanArray;
bathy.fCombined.J = nanArray;
bathy.fCombined.fBar = nanArray;

bathy.runningAverage.h = nanArray;
bathy.runningAverage.hErr = nanArray;
bathy.runningAverage.P = nanArray;
bathy.runningAverage.Q = nanArray;


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


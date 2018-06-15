function showWaveVarianceMap(sn,pa)
%
%  showWaveVarianceMap(stackName,pixArraySpecs)
%
%  This routine loads a cBathy stack with name "stackName" and computes 
%  the wave band variance that is the basis for the cBathy computations.
%  It is intended for debugging, to show you if you are seeing significant
%  signals in any stack.  While the routine name says wave variance, the
%  significant intensity variations are shown, analogous to the significant
%  wave height being 4*sqrt(variance).  Variance was an easier title.  The
%  user must also specify the characteristics of the pixel sampling array
%  in pixArraySpecs = [xMin dx xMax yMin dy yMax].  These target sample
%  locations will be compared to the true collected locations and the
%  closest pixel location found.  Note that there will be target locations
%  that due to pixel size and rounding do not have a sampled pixel (while
%  others have more than one).  These show up as dark pixels and indicate
%  areas where pixel spacing is becoming comparable to pixel resolution.
%  Note that cBathy will still usually work since it is based only on
%  knowing where samples were collected (so it is really only a slight
%  warning that resolution is becoming a problem).

% Holman, March 2016.

% extract the cBathy data
DBConnect;
n = parseFilename(sn);
eval(n.station)
bathy.epoch = n.time; bathy.sName = sn; bathy.params = params;
[xyz, epoch, data, cam] = loadBathyStack(bathy.sName, bathy.params.DECIMATE);
params = bathy.params;      % extract for ease of use.
if(size(epoch,2) > size(epoch,1))   % deal with epoch that is row vs. columns
	epoch = epoch';
end

% This is the code extracted from prepBathyInput.
fB = params.fB; 
dfB = fB(2)-fB(1);
G = fft(detrend(double(data))); % do FFT
dt = mean(diff(epoch(:,1)));
df = 1/(size(epoch,1)*dt);
f = [0: df: 1/(2*dt)-df];
id = find((f >= (fB(1)-dfB/2)) & (f <= (fB(end)+dfB/2)));
f = f(id);      % extract only the required incident band)
G = G(id,:);
sig = sqrt(sum(abs(G))*df);      % find standard deviation map

% make the target array.  We will create a matrix that has x to the right.
x = [pa(1):pa(2):pa(3)];
y = [pa(4):pa(5):pa(6)];
Nx = length(x); 
Ny = length(y);
for i = 1: size(xyz,1)      % loop through every pixel
    r = round((pa(6)-xyz(i,2))/pa(5)) + 1;   % row 
    r = max(r,1); r = min(r,Ny);      % keep within limits (rounding)
    c = round((xyz(i,1)-pa(1))/pa(2)) + 1;   % column
    c = max(c,1); c = min(c,Nx);      % same
    map(i) = sub2ind([length(y) length(x)],r,c);
end

% show the map as 4*sigma.
figure(2); clf; colormap jet
I = 0*ones(Ny,Nx);
I(map) = 4*sig;         % make equivalent to a Hs but for intensity
imagesc(x,fliplr(y),I); axis xy;axis equal; axis tight; 
colorbar

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


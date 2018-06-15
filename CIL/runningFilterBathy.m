function runningFilterBathy(startVec, endVec)
%
%  runningFilterBathy([y1 m1 d1], [y2 m2 d2])
%
% wrapper filter routine to smooth consecutive bathy collects and save
% them.  Goes to the bathyCollectPath and finds all collection results
% between time1 (y1 m1 d1) and time2.  It then computes a Kalman filter
% smoothing of each in turn.  If the first bathy doesn't have a Kalman
% seed, it creates the seed.  Results can be examined with
% plotBathyKalmanStep to check performance.
% Results are simply saved back in place.

resultsPath = '/home/ruby/users/holman/research/BEACHWIZARD/BATHYRESULTS/argus02a/COLLECTIONRESULTS/';
epochStart = matlab2Epoch(datenum([startVec 0 0 0]));
epochEnd = matlab2Epoch(datenum([endVec 23 59 59]));
nms = dir([resultsPath '8*mat']);

for i = 1: length(nms);
    foo = findstr('argus', nms(i).name);
    epoch(i) = str2num(nms(i).name([1:foo-1]));
end
good = find((epoch>=epochStart)&(epoch<=epochEnd));
nms = nms(good);

% now get waves for Kalman filtering
DBConnect
waves = DuckGetWaves([epochStart epochEnd], 3111);
tw = epoch2Matlab([waves(:).epoch]);
Hmo = [waves(:).hmo];

% load first bathy and see if we need a seed.
load([resultsPath nms(1).name]);
if all(isnan(bathy.runningAverage.h(:)))    % need seed
    bathy = makeKalmanBathySeed(bathy);
    eval(['save ' resultsPath nms(1).name ' bathy'])
end    
    
% go through rest of bathys
for i = 2: length(nms)
    load([resultsPath nms(i-1).name])
    prior = bathy;
    load([resultsPath nms(i).name])
    H = interp1(tw, Hmo, epoch2Matlab(str2num(bathy.epoch)));
    bathy = KalmanFilterBathy(prior, bathy, H);
    eval(['save ' resultsPath nms(i).name ' bathy'])
end

    
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


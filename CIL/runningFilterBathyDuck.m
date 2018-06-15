%function runningFilterBathyDuck
%
%  runningFilterBathyDuck
%
% Read bathy files in a series of local directories and compute
% Kalman-filtered results.  For comparison with CRAB surveys from 2009 to
% 2011 for cBathy paper.

clear all
resultsPath = '/home/ruby/users/holman/research/BEACHWIZARD/BATHYRESULTS/argus02a/';
nms = dir([resultsPath '20*']);
DBConnect
hWait = waitbar(0);

for test = 1: length(nms)
    waitbar(test/length(nms),hWait)
    testStr = [nms(test).name '/'];
    files = dir([resultsPath testStr '*mat']);
    load([resultsPath testStr files(1).name])
    bathy = makeKalmanBathySeed(bathy);
    eval(['save ' resultsPath testStr files(1).name ' bathy'])
    for i = 2: length(files)
        load([resultsPath testStr files(i-1).name])
        prior = bathy;
        load([resultsPath testStr files(i).name])
        waves = DuckGetWaves(str2num(bathy.epoch), 630);
        if isempty(waves)
            waves(1).hmo = 1.0;    % default wave height
            warning(['No wave data for ' bathy.sName])
        end
        bathy = KalmanFilterBathy(prior, bathy, waves.hmo);
        eval(['save ' resultsPath testStr files(i).name ' bathy'])
    end
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


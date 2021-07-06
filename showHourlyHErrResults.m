function [epoch, hErrVar]=showHourlyHErrResults(startVec, endVec);
% showHourlyHErrResults([y1 m1 d1], [y2 m2 d2]);
%
% do plotBathyCollect for each available result within a range of days
% from year1, month1, day1 to year2, month2, day2

resultsPath = '/home/ruby/users/holman/research/BEACHWIZARD/BATHYRESULTS/argus02a/COLLECTIONRESULTS/';
epochStart = matlab2Epoch(datenum([startVec 0 0 0]));
epochEnd = matlab2Epoch(datenum([endVec 23 59 59]));

nms = dir([resultsPath '*mat']);
for i = 1: length(nms);
    foo = findstr('argus', nms(i).name);
    epoch(i) = str2num(nms(i).name([1:foo-1]));
end
good = find((epoch>=epochStart)&(epoch<=epochEnd));
nms = nms(good);
epoch = epoch(good);

for i = 2: length(nms);
        load([resultsPath nms(i-1).name])
        hErr2 = bathy.fCombined.hErr.^2;
        hErrVar(i) = mean(hErr2(:),'omitnan');
    
end

figure(2); clf
plot(epoch2Matlab(epoch), hErrVar, '-+')
datetick('x', 1); xlabel('time'); ylabel('R (m^2)')
title(datestr(epoch2Matlab(epoch(1))))

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


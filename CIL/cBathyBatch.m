function cBathyBatch(stationStr, year, JulianDays)
% 
%   cBathyBatch(stationStr, year, JulianDay)
% Batch control for the BWLite program.  This routine runs Beach
% Wizard for a set of files, plotting output as requested by the user
% and saving data products in a specified folder.  This routine calls
% analyseBathyCollect which loads the stack and controls the analysis
% using on a tile by tile basis.  
% stationStr is the short station name.  The analysis will be done for
% the specified year and Julian day.

% written by Holman, 06/09 following pioneering work by Nathaniel
% Plant.  

% connect to the DB and set paths
DBConnect;
BWSaveCollectPath = ['/home/ruby/users/holman/research/BEACHWIZARD/BATHYRESULTS/' ...
                stationStr '/COLLECTIONRESULTS/'];
addpath(strrep(which('cBathyBatch'), 'cBathyBatch.m', 'SETTINGS'));

% set the parameters for analysis.  
eval(stationStr) % edit this m-file to change params

% begin the analysis loop.  Get the stack names for this day
camStr = ['c' num2str(params.defaultKeyCam, '%.0f')];
for day = JulianDays
    dirStr = ['/ftp/pub/' stationStr '/' num2str(year) '/' ...
            camStr '/' num2str(day) '*'];
    dayStr = dir(dirStr);
    dirStr = ['/ftp/pub/' stationStr '/' num2str(year) '/' ...
            camStr '/' dayStr.name '/*stack*'];
    nms = dir(dirStr);
    fprintf('\n\nAnalyzing %2d stacks from date %s\n\n', length(nms), dayStr.name)

    % loop through, saving output to disk
    tic
    for i = 1: length(nms)
        sName = nms(i).name;
        n = parseFilename(sName);
        clear bathy                 % store all here, clear first
        bathy.epoch = n.time; bathy.sName = sName; bathy.params = params;
        [xyz, epoch, data, cam] = loadBathyStack(bathy.sName, bathy.params.DECIMATE);
        bathy = analyzeBathyCollect(xyz, epoch, data, cam, bathy);
        if ~isempty(bathy)
            plotBathyCollectSDS(bathy);
            saveStr = [n.time n.station]
            eval(['save ' BWSaveCollectPath saveStr  ' bathy'])
        else
            warning(['No data returned for stack ' sName])
        end
    end
end
TOTALANALYSISTIME = toc

% to do
% - get tide for kalman filtering elevations (not depths)
% - improve the plotting stuff - options, meaningful plots, etc.
% - improve front end batch stuff.  How to I want to call this?  By
% the day?  By station, etc.
% - check out the nlparceci errors - why are they happening?

return

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


function [bathy, myErr] = doKal( fn, prevfn )

%%
%  do kallman filtering for cBathy (beach wizard!)
%  called by perl automation wrapper with name of cbathy mat file
%  to work on, and previous mat file. I.e., *.cx.cBathy.mat

%  previous kalman attempts can be detected by the struct
%  runningAverage. 
%
%   K and prior: fully processed kalman data
%   prior with no K: kalman seed
%   no prior and no K: untouched.
%
%   what do I do?
%     if prevfn is null string
%         apply seeding to fn and save. all done
%     if prevfn loads
%         if prev.bathy is untouched
%	      apply seeding to prev, save, continue.
%     filter bathy using prev. save.
%

%% set up returns
myErr = -999;
bathy = [];

%%
tic;
try
	DBConnect;
catch
	%myErr = -998;
	disp( 'failed to connect to database' );
	return;
end

try
	pn = parseFilename( fn );
	nb = load( FTPPath(fn) );  % get bathy
	bathy = nb.bathy;
	bathy = fixBathyTide(bathy);
	if nargin > 1 
		ob = load( FTPPath( prevfn ));
		previous = ob.bathy;
		previous = fixBathyTide(previous);
	end
catch
	myErr = -800;
	return;
end

%%

if nargin < 2
    if ~isfield( bathy.runningAverage, 'prior' )
	bathy = makeKalmanBathySeed( bathy );
	save( fn, 'bathy' );
	comm = ['perl ~/bin/move.data.2000 ' pn.station ' ' fn ];
	system(comm);
	myErr = -100; 
    else
	myErr = -200;
    end
    return;
end

%%

% check for a previous that has no kalman data
if ~isfield( previous.runningAverage, 'prior' ) 
	bathy = makeKalmanBathySeed( previous );
	save( prevfn, 'bathy' );
	comm = ['perl ~/bin/move.data.2000 ' pn.station ' ' prevfn ];
	system(comm);
    previous = bathy;
	bathy = nb.bathy;
end

%%

% have two bathys, let's kalman them, dude.
% first, wave data if there
site = DBGetSiteFromAnything(pn.station);
if( ~isempty(site) ) 
        waves = DBGetWaves( bathy.epoch, site.waveSource );
end
if isempty( waves ) 
    waves(1).gauge = 'fixed';
    waves(1).epoch = bathy.epoch;
    waves(1).dir = 999;
    waves(1).period = -1;
    waves(1).hmo = 1.0; 
end

%%

try
bathy = KalmanFilterBathy( previous, bathy, waves(1).hmo );
catch
        myErr = -700;
        size(bathy.xm)
        size(previous.xm)
        return;
end

bathy.waves = waves(1);

save( fn, 'bathy' );

myErr = toc;

% one last step, move the data where it goes.
comm = ['perl ~/bin/move.data.2000 ' pn.station ' ' fn ];
system(comm);

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


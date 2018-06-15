function [bathy, myErr] = docBathy( fn )

%%
%  do cBathy function. Wrapper around actual code, is 
%  called by perl automation wrapper with name of stack file
%  to work on. 
%%
%   WARNING: this function is used by production CIL processing.
% PLEASE do not change or remove this. Please do not "fix" it so
% it runs for you. It is here so that the git version of cBathy
% can be run in production mode at CIL without having to remember to
% fix the repository version to add this back. Thank you.
%
% you are probably looking for analyzeBathyCollect. 

% from BWLiteBatch by YHS.

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

pn = parseFilename( fn );

% do I even DO this one?
% look it up! all of them, I'll need them later
stack = DBGetTableEntry('stack','epoch',[str2num(pn.time)-5 str2num(pn.time)+5], ...
		'station', pn.station );

%disp( stack );

if( ~isempty(stack) )

	rinfo = DBGetTableEntry('R', 'station', pn.station, ...
			'epoch', stack(1).aoiEpoch, ...
			'camNum', pn.camera );

	if( isempty( rinfo ) )
		disp( ['no r file for ' fn] );
		myErr = -803;
		return;
	end

	if( isempty( strfind( rinfo.names, 'mBW' ) ) )
		disp( [ 'no instrument mBW in ' fn ] );
		myErr = -800;
		return;
	end

else
	myErr = -801;
	return;
end

addpath(strrep(which('cBathyBatch'), 'cBathyBatch.m', 'SETTINGS'));
paramsFile = [ pn.station ];

try
	eval( paramsFile );
catch
	myErr = -802;
	return;
end

%params.DOPLOTTILES = 0;             % per tile plot option
%params.DOPLOTCollect = 0;           % per collection plot option
%params.DOPLOTTRANSECTS = 0;         % primary debugging

bathy.epoch = pn.time;
bathy.sName = fn;
bathy.params = params;

[xyz, epoch, data, cam] = loadBathyStack( fn, params.DECIMATE );


%%
bathy = analyzeBathyCollect( xyz, epoch, data, cam, bathy );

%%
pn.camera = 'x';
pn.type = 'cBathy';
pn.format = 'mat';

nfn = argusFilename( pn );

save( nfn, 'bathy' );

myErr = toc;

% one last step, move the data where it goes.
comm = ['perl ~/bin/move.data.2000 -q ' pn.station ' ' nfn ];
system(comm);

%%
% one real last thing -- update stack database with this 
for i = 1:length(stack)
    
    ostack = stack(i);
    nstack = stack(i);
    nstack.cBathyTime = floor(epochtime);
    if( isnan(bathy.tide.zt ) )
        nstack.tide = 0;
    else
        nstack.tide = bathy.tide.zt;
    end
    nstack.tideType = bathy.tide.source;
    ns = createUpdateString( 'stack', ostack, nstack, {'seq' 'epoch'} );
    DBQueryRaw( ns );
    
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


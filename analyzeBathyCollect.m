function bathy = analyzeBathyCollect(xyz, epoch, data, cam, bathy)
%%
%
%  bathy = analyzeBathyCollect(xyz, epoch, data, cam, bathy);
%
%  cBathy main analysis routine.  Input data from a time
%  stack includes xyz, epoch and data as well as the initial fields
%  of the bathy structure.  Returns an
%  augmented structure with new fields 'fDependent' that contains all
%  the frequency dependent results and fCombined that contains the
%  estimated bathymetry and errors.
%  bathy input is expected to have fields .epoch, .sName and .params.
%  All of the relevant analysis parameters are contained in params.
%  These are usually set in an m-file (or text file) BWLiteSettings or
%  something similar that is loaded in the wrapper routine
%  NOTE - we assume a coordinate system with x oriented offshore for
%  simplicity.  If you use a different system, rotate your data to this
%  system prior for analysis then un-rotate after.

tic 			% to record the CPUTime
% record version
myVer = cBathyVersion();
bathy.ver = myVer;
bathy.matVer = version;
if isempty(ver('stats'))        % forced to use local LMFit if no stats toolbox
    bathy.params.nlinfit = 0;
end

%% prepare data for analysis
[f, G, bathy] = prepBathyInput( xyz, epoch, data, bathy );

if( cBDebug( bathy.params, 'DOPLOTSTACKANDPHASEMAPS' ) )
    plotStacksAndPhaseMaps( xyz, epoch, data, f, G, bathy.params );
    input('Hit return to continue ')
    close(10); close(11);
end

% create and save a time exposure, brightest and darkest.
data = double(data);
IBar = mean(data);
IBright = max(data);
IDark = min(data);
xy = bathy.params.xyMinMax;
dxy = [bathy.params.dxm bathy.params.dym];
pa = [xy(1) dxy(1) xy(2) xy(3) dxy(2) xy(4)];  % create the pixel array
[xm,ym,map, wt] = findInterpMap(xyz, pa, []);
timex = useInterpMap(IBar,map,wt);
bathy.timex = reshape(timex,length(ym), length(xm));
bright = useInterpMap(IBright,map,wt);
bathy.bright = reshape(bright,length(ym), length(xm));
dark = useInterpMap(IDark,map,wt);
bathy.dark = reshape(dark,length(ym), length(xm));

%% now loop through all x's and y's

if( cBDebug( bathy.params, 'DOSHOWPROGRESS' ))
    figure(21);clf
    plot(xyz(:,1), xyz(:,2), '.'); axis equal; axis tight
    xlabel('x (m)'); ylabel('y (m)')
    title('Analysis Progress'); drawnow;
    hold on
end

% if cBDebug( bathy.params )
	hWait = waitbar(0, 'percentage complete');
% end

% turn off warnings
warning('off', 'stats:nlinfit:IterationLimitExceeded')
warning('off', 'stats:nlinfit:RankDeficient')

% check for the stats toolbox
if isempty(ver('stats'))
    bathy.params.nlinfit=0;
end

for xind = 1:length(bathy.xm)
%    if cBDebug( bathy.params )
	    waitbar(xind/length(bathy.xm), hWait)
        
%    end
    fDep = cell(1,length(bathy.ym));  %% Initialization of fDep yb D.S.
    camUsed = zeros(length(bathy.ym),1);

    if( cBDebug( bathy.params, 'DOSHOWPROGRESS' ))
        for yind = 1:length(bathy.ym)
            [fDep{yind},camUsed(yind)] = csmInvertKAlpha( f, G, xyz(:,1:2), cam, ...
                bathy.xm(xind), bathy.ym(yind), bathy );
        end
    else
        xmValues = bathy.xm(xind);
        xy = xyz(:,1:2);
        ymValues = bathy.ym;
        parfor yind = 1:length(bathy.ym)
            [fDep{yind},camUsed(yind)] = csmInvertKAlpha( f, G, xy, cam, ...
                xmValues, ymValues(yind), bathy );
        end  %% parfor yind
    end
    
    % stuff fDependent data back into bathy (outside parfor)
    for ind = 1:length(bathy.ym)        
        bathy.fDependent.kSeed(ind,xind,:) = fDep{ind}.kSeed;
        bathy.fDependent.aSeed(ind,xind,:) = fDep{ind}.aSeed;
        bathy.fDependent.camUsed(ind,xind) = camUsed(ind);
        if( any( ~isnan( fDep{ind}.k) ) )  % not NaN, valid data.
            bathy.fDependent.fB(ind, xind, :) = fDep{ind}.fB(:);
            bathy.fDependent.k(ind,xind,:) = fDep{ind}.k(:);
            bathy.fDependent.a(ind,xind,:) = fDep{ind}.a(:);
            bathy.fDependent.dof(ind,xind,:) = fDep{ind}.dof(:);
            bathy.fDependent.skill(ind,xind,:) = fDep{ind}.skill(:);
            bathy.fDependent.lam1(ind,xind,:) = fDep{ind}.lam1(:);
            bathy.fDependent.kErr(ind,xind,:) = fDep{ind}.kErr(:);
            bathy.fDependent.aErr(ind,xind,:) = fDep{ind}.aErr(:);
            bathy.fDependent.hTemp(ind,xind,:) = fDep{ind}.hTemp(:);
            bathy.fDependent.hTempErr(ind,xind,:) = fDep{ind}.hTempErr(:);
            bathy.fDependent.NPixels(ind,xind,:) = fDep{ind}.NPixels;
            bathy.fDependent.NCalls(ind,xind,:) = fDep{ind}.NCalls;
        end
        
    end
        
end % xind
% if cBDebug( bathy.params )
	delete(hWait);
% end

% turn warnings back on
    warning('on', 'stats:nlinfit:IterationLimitExceeded')
    warning('on', 'stats:nlinfit:RankDeficient')

%% Find estimated depths and tide correct, if tide data are available.
  
bathy = bathyFromKAlpha(bathy);

bathy = fixBathyTide(bathy);

bathy.cpuTime = toc;

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

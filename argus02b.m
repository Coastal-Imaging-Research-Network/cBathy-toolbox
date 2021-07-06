%%% Site-specific Inputs
params.stationStr = 'argus02b';
params.dxm = 10;                    % analysis domain spacing in x
params.dym = 25;                    % analysis domain spacing in y
params.xyMinMax = [80 800 -500 1500];   % min, max of x, then y
                                    % default to [] for cBathy to choose
params.tideFunction = 'cBathyTide';  % tide level function for evel

%%%%%%%   Power user settings from here down   %%%%%%%
params.MINDEPTH = 0.25;             % for initialization and final QC
params.QTOL = 0.35;                 % reject skill below this in csm
params.minLam = 10;                 % min normalized eigenvalue to proceed
params.Lx = 3*params.dxm;           % tomographic domain smoothing
params.Ly = 3*params.dym;           % 
params.kappa0 = 2;                  % increase in smoothing at outer xm
params.DECIMATE = 1;                % decimate pixels to reduce work load.
params.maxNPix = 80;                % max num pixels per tile (decimate excess)
params.minValsForBathyEst = 4;      % need this many pixels to solve
params.shortLengthNFreqs = 4;       % need this many for coherence sorting
                                    % versus magnitude shorting

% f-domain etc.
params.fB = [1/18: 1/50: 1/4];		% frequencies for analysis (~40 dof)
params.nKeep = 4;                   % number of frequencies to keep

% debugging options
params.debug.production = 1; % this should be ZERO in DEBUG MODE!
params.debug.DOPLOTSTACKANDPHASEMAPS = 1;  % top level debug of phase
params.debug.DOSHOWPROGRESS = 1;		  % show progress of tiles
params.debug.DOPLOTPHASETILE = 1;		  % observed and EOF results per pt
params.debug.TRANSECTX = 200;		  % for plotStacksAndPhaseMaps
params.debug.TRANSECTY = 900;		  % for plotStacksAndPhaseMaps

% default offshore wave angle.  For search seeds.
params.offshoreRadCCWFromx = 0;

params.nlinfit = 1; % flag, 0 = use LMFnlsq.m to do non-linear fitting




%
% Copyright by Oregon State University, 2011
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: argus02b.m,v 1.2 2016/04/11 23:06:10 stanley Exp $
%
% $Log: argus02b.m,v $
% Revision 1.2  2016/04/11 23:06:10  stanley
% Fix MAXDEPTH
%
% Revision 1.1  2012/09/24 23:36:32  stanley
% Initial revision
%
%
%key 
%comment  
%
params.minValsForBathyEst = 4;


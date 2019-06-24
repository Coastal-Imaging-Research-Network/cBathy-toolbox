function bathy = analyzeSingleBathyRunFrommBW(mBWPathname, n)
%
%  bathy = analyzeSingleBathyRunFrommBW(mBWPathname, n)
%
%  simple run of analyzeBathyCollect for a single stackName.  Useful for
%  debugging

eval(n.station)
bathy.epoch = n.time; bathy.sName = mBWPathname; bathy.params = params;
load(mBWPathname)
bathy.h0.x = params.xyMinMax(1):params.dxm:params.xyMinMax(2);
bathy.h0.y = params.xyMinMax(3):params.dym:params.xyMinMax(4);
bathy.h0.h = findh0Duck(bathy.h0.x, bathy.h0.y, 1);   % seed depths for search
bathy = analyzeBathyCollect(XYZ, T(:), RAW, CAM, bathy);

%
% Copyright by Oregon State University, 2011
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: analyzeSingleBathyRun.m,v 1.1 2012/09/24 23:08:04 stanley Exp $
%
% $Log: analyzeSingleBathyRun.m,v $
% Revision 1.1  2012/09/24 23:08:04  stanley
% Initial revision
%
%
%key 
%comment  
%

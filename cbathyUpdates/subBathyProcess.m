function [fDep, camUsed] = subBathyProcess( f, G, xyz, cam, xm, ym, bathy )

%% subBathyProcess -- extract region from full bathy stack, process
%
%  fDep = subBathyProcess( f, G, xyz, cam, xm, ym, bathy )
%
%  f, G, xyz, cam are the full arryms. 
%  xm,ym is the desired analysis point.
%  bathy is the building result structure
%
%

%% first extract sub region.  Obsolete since tiles are now f-dependent size
% [subG, subXYZ, camUsed] = spatialLimitBathy( G, xyz, cam, xm, ym, ...
%                            bathy.params, bathy.kappa );
if( cBDebug( bathy.params, 'DOSHOWPROGRESS' ))
    figure(21);
    foo = findobj('tag','pixDots'); % tidy up old locations
    if ~isempty(foo)
        delete(foo)
    end
    foo = findobj('tag','xmDot');
    if ~isempty(foo)
        delete(foo)
    end
   % hp1 = plot(subXYZ(:,1), subXYZ(:,2), 'r.', 'tag', 'pixDots');
    hp2 = plot(xm, ym, 'g*', 'tag', 'xmDot');
end

%% now process!

[fDep, camUsed] = csmInvertKAlpha( f, G, xyz, cam, xm, ym, bathy );

%% how simple!

 

%
% Copyright by Oregon State University, 2011
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: subBathyProcess.m,v 1.1 2012/09/24 23:33:57 stanley Exp $
%
% $Log: subBathyProcess.m,v $
% Revision 1.1  2012/09/24 23:33:57  stanley
% Initial revision
%
%
%key 
%comment  
%

function [fDependent, camUsed] = ...
    csmInvertKAlpha(f, G, xy, cam, xm, ym, bathy)
%
% [fDependent, camUsed] = ...
%   csmInvertKAlpha(f, G, xy, cam, xm, ym, bathy)
%
% estimate wavennumber components from cross spectral matrix CSM
% using local nolinear model for any provided subset of Fourier values
% at any location, xm, ym.    
%
% Input
%   f   frequencies of input Fourier coefficients, Nf x 1
%   G, Fourier coeffients from a tiles worth of pixels, Nxy x 1 (complex)
%   xy, pixel locations (Nxy of them); horizontal position only
%   cam, camera number for each xyz, required for handling seams
%   xm, ym, single location for this analysis
%   bathy, building results structure with everything in it.
% Outputs:
%   fDependent: small structure of results with the following fields, each
%   of length nKeep (one for each frequency)
%       - fB,       - analysed frequencies
%       - k a h,    - wavenumber, wave direction, depth
%       - kEst aEst hEst - errors in wavenumber, direction and depth
%       - skill dof, - skill and degrees of freedom

% 03/07/10 - Holman fix to catch edge error where a tomographic point
%   an extrapolation region can get poor estimates with low error
%   because only a very few pixels are fit well.  Fix is to require
%   nGood pixels (likely > 3) and to have max(deltax) and max(deltay)
%   at least wavelengthFraction of the expected wavelength.
% 09/01/11 - Holman rewrite to finally get rid of tiling and analyze a
%   single location only
% 12/05/11 - Holman major change to base on EOFs rather than direct from CSM

% 05/22/17 - Holman major change to dynamic tile size (based on fB) and new
%               seed based on initial guess at bathy, bathy.h0
% 07/24/19 - major changes including better implementation of dynamic tile
%            size, removing phi0 as a search variable and new seed
%            algorithm based on radon transform.

%% %%  1. constants and parameters

global callCount            % keep track of number of calls to predictCSM
global centerInd            % index of pixel closest to xm, ym for phase corr.
global v                    % dominant eigenvector at each f
% set up nonlinear solver parameters.

OPTIONS = statset('nlinfit');   % fit options
OPTIONS.MaxIter = 50;
OPTIONS.TolFun = 1e-5;      % previous version used 1e-6
%OPTIONS.Display = 'iter';  % only for debugging search
warning off

clear fDependent
g=9.81;                         % 'g'
ri = [0:0.01:1]';       % create a hanning filter for later interp
ai = (1 - cos( pi*(0.5 + 0.5*ri) ).^2);
if( cBDebug( bathy.params, 'DOPLOTPHASETILE' ))
    for i = 1: bathy.params.nKeep
        figure(i); clf
    end
end

% find the dominant frequencies for this location, estimates of
% seed for k and alpha, create adaptive tiles subG, subxy and
% subCams.  If insufficient pixels, return empty results, indicated by fs 
% being nan.
[fs, kAlpha0, subvs, subxy, camUsed, lam1Norms, centerInds] = ...
                    prepareTiles(f, G, xy, cam, xm, ym, bathy);
fDependent.fB = fs;

%% %%  Loop through frequencies from most to least coherent solving for the
%      best fit kAlpha from the complex eigenvectors for each tile

for i = 1:length(fs)         % frequency loop
    if ~isnan(fs(i))     % skip invalid frequencies.
        % info for depth subsequent h error estimation
        hiimax = 9.8*(1/fs(i)^2)/(2*pi)/2;  % deepest allowable = L0/2
        hii = [bathy.params.MINDEPTH:.1:hiimax]'; % find k for full range of h
        kii = dispsol(hii, fs(i),0);

        xy = subxy{i};
        Nxy = size(xy,1);
        v = subvs{i};
        lam1Norm = lam1Norms(i);
        kAlphaInit = kAlpha0(i,:);
        if((cBDebug( bathy.params, 'DOSHOWPROGRESS' )) & (i==1)) % first pass only
            figure(21);
            foo = findobj('tag','pixDots'); % tidy up old locations
            if ~isempty(foo)
                delete(foo)
            end
            foo = findobj('tag','xmDot');
            if ~isempty(foo)
                delete(foo)
            end
            hp1 = plot(xy(:,1), xy(:,2), 'r.', 'tag', 'pixDots');
            hp2 = plot(xm, ym, 'g*', 'tag', 'xmDot');
        end

        % weightings
        dxmi = xy(:,1) - repmat(xm, Nxy, 1);
        dymi = xy(:,2) - repmat(ym, Nxy, 1);
        r = sqrt((dxmi/(bathy.params.Lx)).^2 + (dymi/(bathy.params.Ly)).^2);
        Wmi = interp1(ri,ai,r,'linear',0);  % sample normalized weights
        w = abs(v).*Wmi;           % final weights for fitting.

        % find span of data in x and y to determine if sufficient
        maxDx = max(max(repmat(xy(:,1),1,Nxy) - repmat(xy(:,1)',Nxy,1)));
        maxDy = max(max(repmat(xy(:,2),1,Nxy) - repmat(xy(:,2)',Nxy,1)));

        % check if sufficient data quality
        if ~(lam1Norm>bathy.params.minLam) 
            kAlpha = [nan nan];  % no, so bail
            ex = kAlpha;

            skill = nan;
            figure(i); clf
        else
            try            % yes, do solution
                % prepare nlinfit params and do nonlinear fit on surviving data.
                kmin = (2*pi*fs(i))^2/g; % smallest  and largest wavenumber
                kmax = 2*pi*fs(i)/sqrt(g*bathy.params.MINDEPTH); 
                centerInd = centerInds(i);
                OPTIONS.TolX = min([kmin/100, pi/180/10]);  % change from /1000 to /100
                statset(OPTIONS);
                callCount = 0;      % count calls to predictCSM
%                 [kAlpha,resid,jacob] = nlinfit([xy w], [real(v); imag(v)],...
%                     'predictCSM',kAlphaInit, OPTIONS);
                
                if  bathy.params.nlinfit == 1 % use nlinfit
                    [kAlpha,resid,jacob] = nlinfit([xy w], [real(v); imag(v)],...
                        'predictCSM',kAlphaInit, OPTIONS);
                elseif  bathy.params.nlinfit == 0 % if stats toolbox is no available, set the nlinfit flag to 0
                    [kAlpha,~,~, ~, ~,A,resid] = LMFnlsq('res',kAlphaInit,...
                        [xy w], [real(v); imag(v)], 'Display',0);
                    kAlpha = kAlpha';
                end
                           
                nCalls = callCount;     % record number of f-calls

                % check if outside acceptable limits
                if ((kAlpha(1)<kmin) || (kAlpha(1)>kmax) ...
                        || (kAlpha(2)>pi/2) || ...
                           (kAlpha(2)<-pi/2))
                    error('Resulting K, alpha are out of range, line 115 csmInvertKAlpha');
                end

                % get predictions then skill
                vPred = predictCSM(kAlpha, [xy abs(v)]);  
                vPred = vPred(1:end/2) + sqrt(-1)*vPred(1+end/2:end);
                skill = 1 - norm(vPred-v)^2/norm(v-mean(v))^2; % can be neg.

                if( cBDebug( bathy.params, 'DOPLOTPHASETILE' ))
                    figure(i); clf
                    plotPhaseTile(xy,v,vPred)
                    drawnow;
                    fprintf('frequency %d of %d, normalized lambda %.1f\n  ', ...
                                i, bathy.params.nKeep,lam1Norm)
                end
                
                % get confidence limits
                if bathy.params.nlinfit == 1 % use the stats toolbox 
                    ex = nlparci(real(0*kAlpha),resid,jacob); % get limits not bounds
                    ex = real(ex(:,2)); % get limit, not bounds
                elseif bathy.params.nlinfit == 0 % no-stats toolbox
                    DOF = size(v,1)*2-size(kAlpha,2); % degrees of freedom
                    rmse = norm(resid) / sqrt(DOF);
                    %ex = sigma_p*tstat3( DOF, 1-0.025, 'inv' );
                    ex = rmse*sqrt(diag(inv(A)))*tstat3( DOF, 1-0.025, 'inv' );
                end
                
                
                
            catch   % nlinfit failed with fatal errors, adding bogus
                kAlpha = [nan nan];
                ex = kAlpha;
                skill = nan;
                lam1Norm = nan;
                if( cBDebug( bathy.params, 'DOPLOTPHASETILE' ))
                    figure(i); clf
                end
            end % try
        end
    else
        kAlpha = [nan nan];
        kAlphaInit = kAlpha;
        ex = kAlpha;
        skill = nan;
        lam1Norm = nan;
        w = nan;
    end     % is valid loop
        % store results
    fDependent.k(i) = kAlpha(1); 
    fDependent.a(i) = kAlpha(2);
    fDependent.dof(i) = sum(w/(eps+max(w)));  
    fDependent.skill(i) = skill;  
    fDependent.lam1(i) = lam1Norm;
    fDependent.kErr(i) = ex(1); 
    fDependent.aErr(i) = ex(2);

    % rough estimate of depth from linear dispersion
    if ~isnan(kAlpha(1))
        fDependent.hTemp(i) = interp1(kii,hii, kAlpha(1));
        dhiidkii = diff(hii)./diff(kii);
        fDependent.hTempErr(i) = ...
            sqrt((interp1(kii(2:end),dhiidkii, kAlpha(1))).^2.* ...
                    (ex(1).^2));
    else
        fDependent.hTemp(i) = nan;
        fDependent.hTempErr(i) = nan;
    end
    if exist('v')
        fDependent.NPixels(i) = length(v);
    else
        fDependent.NPixels(i) = 0;
    end
    if exist('nCalls')
        fDependent.NCalls(i) = nCalls;
    else
        fDependent.NCalls(i) = -1;
    end
    fDependent.kSeed(i) = kAlphaInit(1);
    fDependent.aSeed(i) = kAlphaInit(2);
end  % frequency loop

if( cBDebug( bathy.params, 'DOPLOTPHASETILE' ))
    fDependent
    input('Hit enter to continue ');
end

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


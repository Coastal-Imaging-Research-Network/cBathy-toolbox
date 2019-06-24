function [fDependent, camUsed] = ...
    csmInvertKAlpha(f, GAll, xyz, cam, xm, ym, bathy)
%
% fCombined = ...
%   csmInvertKAlpha(f, G, xyz, cam, xm, ym, bathy)
%
% estimate wavennumber components from cross spectral matrix CSM
% using local nolinear model for any provided subset of Fourier values
% at any location, xm, ym.    
%
% Input
%   f   frequencies of input Fourier coefficients, Nf x 1
%   G, Fourier coeffients from a tiles worth of pixels, Nxy x 1 (complex)
%   xyz, pixel locations (Nxy of them; z column is not required
%   cam, camera number for each xyz, required for handling seams
%   xm, ym, single location for this analysis
%   bathy, building results structure with everything in it.
% Outputs:
%   fDependent: small structure of results with the following fields, each
%   of length nKeep (one for each frequency)
%       - fB,       - analysed frequencies
%       - k a h,    - wavenumber, alpha, depth
%       - kEst aEst hEst - errors in wavenumber, alpha and depth
%       - skill dof, - skill and degrees of freedom

% 03/07/10 - Holman fix to catch edge error where a tomographic point
%   an extrapolation region can get poor eXYZstimates with low error
%   because only a very few pixels are fit well.  Fix is to require
%   nGood pixels (likely > 3) and to have max(deltax) and max(deltay)
%   at least wavelengthFraction of the expected wavelength.
% 09/01/11 - Holman rewrite to finally get rid of tiling and analyze a
%   single location only
% 12/05/11 - Holman major change to base on EOFs rather than direct from CSM
% 05/22/17 - Holman major change to dynamic tile size (based on fB) and new
%               seed based on initial guess at bathy, bathy.h0

%% %%  1. constants and parameters

clear fDependent
g=9.81;                         % 'g'
minNeededPixels = 6;            % to avoid edge anomalies
minLFraction = 0.5;             % min fract of wavelength to span
kL = 1.25;                      % goal tile size compared to h0 wavelength

ri = [0:0.01:1]';       % create a hanning filter for later interp
ai = (1 - cos( pi*(0.5 + 0.5*ri) ).^2);

OPTIONS = statset('nlinfit');   % fit options
OPTIONS.MaxIter = 50;
OPTIONS.TolFun = 1e-6; %%%1e-3;

% find the dominant frequencies for this location based on the standard
% tile size Lx by Ly (passed in bathy).

fs = findDominantfBs(f, GAll, xyz, cam, xm, ym, bathy);
fDependent.fB = fs;
xyAll = xyz(:,1:2);

%% %%  Loop through frequencies from most to least coherent.  For each
%% f, find the frequency-dependent tile, then find the csm, then the 
%% first EOF.  If sufficiently coherent, fit to
%% find the k, alpha and scalar phase (no lasting value).

for i = 1:length(fs)         % frequency loop
    
    % info for depth subsequent h error estimation
    hiimax = 9.8*(1/fs(i)^2)/(2*pi)/2;  % deepest allowable = L0/2
    hii = [bathy.params.MINDEPTH:.1:hiimax]'; % find k for full range of h
    kii = dispsol(hii, fs(i),0);
    
    % estimate the rough depth, h0 then cull tile to kL times expected
    % wavelength.  Then decimate to maxNPix
    h0 = interp2(bathy.h0.x, bathy.h0.y, bathy.h0.h, xm, ym);
    LBoxx = kL * 2*pi/interp1(hii,kii,h0);          % determine reqd tile size
    LBoxy = LBoxx *bathy.params.Ly/bathy.params.Lx; 
    [G, xy, camUsed] = ...
                spatialLimitBathy(GAll, xyAll, cam, xm, ym, ...
                LBoxx/2, LBoxy/2, bathy.params.maxNPix);
    Nxy = size(xy,1);
    
    % compute the CSM
    id = find(abs(fs(i)-f) < (bathy.params.fB(2)-bathy.params.fB(1))/2);     % find the f's that match
    C = G(id,:)'*G(id,:) / length(id);   % pos 2nd leads 1st.
 
    % weightings
    dxmi = xy(:,1) - repmat(xm, Nxy, 1);
    dymi = xy(:,2) - repmat(ym, Nxy, 1);
    r = sqrt((dxmi/(bathy.params.Lx*bathy.kappa)).^2 + (dymi/(bathy.params.Ly*bathy.kappa)).^2);
    Wmi = interp1(ri,ai,r,'linear*',0);  % sample normalized weights

    % find span of data in x and y to determine if sufficient
    maxDx = max(max(repmat(xy(:,1),1,Nxy) - repmat(xy(:,1)',Nxy,1)));
    maxDy = max(max(repmat(xy(:,2),1,Nxy) - repmat(xy(:,2)',Nxy,1)));

    % prepare nlinfit params.  Note that k is radial wavenumber
    kmin = (2*pi*fs(i))^2/g; % smallest  and largest wavenumber
    kmax = 2*pi*fs(i)/sqrt(g*bathy.params.MINDEPTH); 
    LExpect = LBoxx/kL;     % expected wavelength
    seedAlpha = bathy.params.offshoreRadCCWFromx;
    LB_UB = [kmin seedAlpha-pi/2;kmax seedAlpha+pi/2];
    OPTIONS.TolX = min([kmin/1000,pi/180/1000]); % min([kmin/100,pi/180/10]);
    statset(OPTIONS);
    widILE = 'stats:nlinfit:IterationLimitExceeded';
    widRD = 'stats:nlinfit:RankDefficient';
    warning('off', widILE)
    warning('off', widRD)

    % find the eigenvector
    [v,d] = eig(C);
    lam = real(diag(d));  % order eigenvalues and remove teeny imag component
    [lam1, lamInd] = max(lam);
    lam1Norm = lam1/sum(lam)*length(lam);  % as ratio to uniform eigenvalues
    v = v(:,lamInd);           % chose only dominant EOF
    w = abs(v).*Wmi;           % final weights for fitting.
    
    % check if sufficient data quality and xy span
    if ~((lam1Norm>bathy.params.minLam) && (maxDx>LExpect) && (maxDy>LExpect))
        kAlphaPhi = [nan nan nan];
        ex = kAlphaPhi;
        skill = nan;
    else
        try
            % do nonlinear fit on surviving data.
            % use first point in eigenvector for phiInit
            k = 2*pi/LExpect; 
            alpha = findAlpha0(xy,v);
            phi = angle(v(1) - k*cos(alpha)*xy(1,1) - k*sin(alpha)*xy(1,2));
            kAlphaPhiInit = [k alpha phi];
            [kAlphaPhi,resid,jacob] = nlinfit([xy w], [real(v); imag(v)],...
                           'predictCSM',kAlphaPhiInit, OPTIONS);
            
            % check if outside acceptable limits
            if ((kAlphaPhi(1)<LB_UB(1,1)) || (kAlphaPhi(1)>LB_UB(2,1)) ...
                    || (kAlphaPhi(2)<LB_UB(1,2)) || (kAlphaPhi(2)>LB_UB(2,2)))
                error;
            end
            
            % get predictions then skill
            vPred = predictCSM(kAlphaPhi, [xy abs(v)]);
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
            ex = nlparci(real(0*kAlphaPhi),resid,jacob); % get limits not bounds
            ex = real(ex(:,2)); % get limit, not bounds
        catch   % nlinfit failed with fatal errors, adding bogus
            kAlphaPhi = [nan nan nan];
            ex = kAlphaPhi;
            skill = nan;
            lam1 = nan;
            if( cBDebug( bathy.params, 'DOPLOTPHASETILE' ))
                figure(i); clf
            end
        end % try
    end

    % store results
    fDependent.k(i) = kAlphaPhi(1); 
    fDependent.a(i) = kAlphaPhi(2);
    fDependent.dof(i) = sum(w/(eps+max(w)));  
    fDependent.skill(i) = skill;  
    fDependent.lam1(i) = lam1;
    fDependent.kErr(i) = ex(1); 
    fDependent.aErr(i) = ex(2);

    % rough estimate of depth from linear dispersion
    if ~isnan(kAlphaPhi(1))
        fDependent.hTemp(i) = interp1(kii,hii, kAlphaPhi(1));
        dhiidkii = diff(hii)./diff(kii);
        fDependent.hTempErr(i) = ...
            sqrt((interp1(kii(2:end),dhiidkii, kAlphaPhi(1))).^2.* ...
                    (ex(1).^2));
    else
        fDependent.hTemp(i) = nan;
        fDependent.hTempErr(i) = nan;
    end
end  % frequency loop

if( cBDebug( bathy.params, 'DOPLOTPHASETILE' ))
    fDependent
    input('Hit enter to continue ');
end

warning('on', widILE)
warning('on', widRD)

%
% Copyright by Oregon State University, 2011
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: csmInvertKAlpha.m,v 1.2 2012/09/24 23:15:23 stanley Exp $
%
% $Log: csmInvertKAlpha.m,v $
% Revision 1.2  2012/09/24 23:15:23  stanley
% very much changed, formatting
%
% Revision 1.1  2011/08/08 00:28:51  stanley
% Initial revision
%
%
%key whatever is right, do it
%comment  
%


function bathy = bathyFromKAlpha(bathy)
%
%  bathy = bathyFromKAlpha(bathy);
%
% pahse II in cBathy to take multi-frequency estimates of bathymetry
% and find a best solution for each tomographic location using skill
% and error weightings

OPTIONS = statset('nlinfit');   % nlinfit options
OPTIONS.MaxIter = 30;
OPTIONS.TolX = 1e-4; %%%1e-3;l
OPTIONS.Display = 'iter';
OPTIONS.Display = 'off';

g = 9.81; % gravity, it's the law!
ri = [0:0.01:1]';       % create a hanning filter for later interp
ai = (1 - cos( pi*(0.5 + 0.5*ri) ).^2);

% create sensitivity vectors gammaiBar and mu
% find the dispersion sensitivity, mu.  This will used to interp into
% gammi, mu, below.
gammai = [0.0: 0.01: 1];
gammaiBar = (gammai(1:end-1)+gammai(2:end))/2;
foo = gammai.*atanh(gammai);
dFoodGamma = diff(foo)./diff(gammai);
mu = dFoodGamma./tanh(gammaiBar);

params = bathy.params;
nFreqs = size(bathy.fDependent.fB, 3);
x = bathy.xm; y = bathy.ym;     % for ease of writing
xMin = min(x);
xMax = max(x);
X = repmat(x, [size(y,2), 1, nFreqs]);
Y = repmat(y', [1, size(x,2), nFreqs]);

% loop through all points, doing nlinfit solution for h.  Note that the init
% values of nan are returned unless solution is successful.
for ix = 1: length(x)
    for iy = 1: length(y)
        kappa = 1 + (bathy.params.kappa0-1)*(x(ix) - xMin)/ ...
            (xMax - xMin);
        % find range-based weights, Wmi to contribute to total weight
        dxmi = X - x(ix);
        dymi = Y - y(iy);
        r = sqrt((dxmi/(params.Lx*kappa)).^2 + (dymi/(params.Ly*kappa)).^2);
        Wmi = interp1(ri,ai,r,'linear',0);  % sample normalized weights
        
        id = find((Wmi > 0) & ...
            (bathy.fDependent.skill>params.QTOL) & ...
            (~isnan(bathy.fDependent.hTemp)));
        if(length(id)>=params.minValsForBathyEst)
            f = [bathy.fDependent.fB(id)];
            k = [bathy.fDependent.k(id)];
            kErr = [bathy.fDependent.kErr(id)];
            s = [bathy.fDependent.skill(id)];
            l = [bathy.fDependent.lam1(id)];
            hTemp = [bathy.fDependent.hTemp(id)];
            %% find dispersion sensitivity
            gamma = 4*pi*pi*f.*f./(g.*k);
            wMu = 1./interp1(gammaiBar, mu, gamma);
            w = Wmi(id).*wMu.*l.*s./(eps+k);    % weights depend on skill and variance (lam)
            hInit = bathy.fDependent.hTemp(id)'*s / sum(s);
            
            % nlinfit *** may be replaced with conditional statement that
            % follows
            
            if params.nlinfit == 1 % use the stats toolbox if you have it
                [h,resid,jacob] =nlinfit([f, w], k.*w, ...
                    'kInvertDepthModel',hInit, OPTIONS);
                leverage = jacob.^2./sum(jacob.^2);     % used for fBar
            elseif params.nlinfit == 0 % if you don't have the stats toolbox, or you don't want to use it
                [h,~,~, ~, ~,A,resid] = LMFnlsq('res2',hInit,[f, w], k.*w,'Display',0);
                leverage = zeros(size(f));
            end
            if (~isnan(h))      % some value returned
                if params.nlinfit == 1 % use the stats toolbox if you have it
                    hErr = bathyCI(resid,jacob, w,1);		 % get limits not bounds
                elseif params.nlinfit == 0 % if you don't have the stats toolbox, or you don't want to use it
                    
                    hErr = bathyCI(resid,A, w,0);		 % get limits not bounds
                end
                kModel = kInvertDepthModel(h, [f, w]);
                J = sqrt(sum(kModel.*k.*w)/(eps+sum(w.^2))); % skill
                if ((J~=0) && (h>=params.MINDEPTH))
                    bathy.fCombined.h(iy,ix) = h;
                    bathy.fCombined.hErr(iy,ix) = hErr;
                    bathy.fCombined.J(iy,ix) = J;
                    bathy.fCombined.fBar(iy,ix) = sum(leverage.*f);
                end
            end
        end  % default h, hErr to nan if no successful solution.
    end	%iy
end	% ix

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


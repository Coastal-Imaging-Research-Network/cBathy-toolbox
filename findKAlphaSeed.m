function [kAlpha0, centerInd] = findKAlphaSeed(xy, v, xm, ym)
%   [kAlpha0, centerInd] = findKAlphaSeed(xy, v, xm, ym)
% Given a phase tile v at locations xy, find good seed estimates for the
% wave angle and wavenumber that will be used for the nonlinear search in
% csmInvertKAlpha.  This version uses the radon transform to find the
% dominant wave direction.
% Outputs are the two parameters, k and alpha, plus the center index
% of the pixel that is closest to xm, ym.  This will be used to correct
% phase in predictCSM.
% Erwin Bergsma (erwin.bergsma@legos.obs-mip.fr)
% July 2019

%% Updates - 10/16/20
% dxy returned to 2 m to improve stability.
% fixed line 30 to be mean of Iz of good points.
% based IRot (line 51) on only good gridded points
% See doc file findKAlphaSeedUpdates101620Holman.doc

%% Phase ramp over tile:
va = angle(v);

%% Interpolation (Radon only works on equidistantly space data)
% note, dx and dy can be modified
dxy = 4;	% changed from 2 to speed things up.
x1 = min(xy(:,1)); x2 = max(xy(:,1)); y1 = min(xy(:,2)); y2 = max(xy(:,2));
x = x1: dxy: x2;
y = y1: dxy: y2;
[X, Y] = meshgrid(x,y);
Iz0 = griddata(xy(:,1), xy(:,2), va, X, Y);     % this returns nans for outside points
bad = isnan(Iz0);
Iz = Iz0;           % save original
Iz(bad) = mean(Iz(~bad(:))); % Radon does not allow for NaNs --> filled with mean

%% Apply radon over theta
theta = -pi/4: pi/100: pi/4;
R = radon(Iz,theta*180/pi);

%% Pick the direction with maximum variance (representing the incident wave angle) 
[~,c] = max(var(R));
aSeed = -theta(c); % result in radians.

%% Estimate the wave number projected in the incident wave direction.  Establish
%  a grid oriented in the wave direction that spans the original tile, then
%  interp into the original phase map to re-map to wave-directed coords.
%  Then chose the median gradient as the seed wavenumber.
corners = [x1 y1; x1 y2; x2 y1; x2 y2];
xProj = corners(:,1)*cos(aSeed) + corners(:,2)*sin(aSeed);
yProj = -corners(:,1)*sin(aSeed) + corners(:,2)*cos(aSeed);
[XProj, YProj] = meshgrid(min(xProj): dxy: max(xProj), min(yProj): dxy: max(yProj));
XUnProj = XProj(:)*cos(aSeed) - YProj(:)*sin(aSeed);
YUnProj = XProj(:)*sin(aSeed) + YProj(:)*cos(aSeed);
IRot = interp2(x,y,Iz0,XUnProj(:), YUnProj(:));
IRot = reshape(IRot, size(XProj));
dPhidx = diff(IRot')/dxy;
kSeed = -median(dPhidx(:),'omitnan');

% finally find the point closest to xm,ym for later phase setting in
% predictCSM.
d = sqrt((xy(:,1) - xm).^2 + (xy(:,2)-ym).^2);
[~,centerInd] = min(d);

kAlpha0 = [kSeed aSeed];

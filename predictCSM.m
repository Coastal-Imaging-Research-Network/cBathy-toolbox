
function q = predictCSM( kAlpha,xyw)

% q = predictCSM(kAlphaPhi, xyw)
%
% compute complex cross-spectral matrix from wavenumber and direction,
% kAlpha for x and y lags in first 2 cols of xyw.  Third column accounts
% for weightings.
% 
% Input
%   kalpha = [k, alpha], wavenumber (2*pi/L) and direction
%   (radians) and phi is a phase angle (with no later utility)
%   xyw, delta_x, delta_y, weight
%  
% Output
%   q, complex correlation q = exp(i*(kx*dx + ky*dy + phi))
%   q is returned as a list of complex values but is returned as a single
%   list of real, then imaginary coefficients.
%
%  NOTE - this is a new version that solves for phi directly from the phase
%  difference between observed (v) and modeled (q) phase at the center
%  point.  Thus phi has been dropped as an input variable.

global callCount v centerInd

kx = -kAlpha(1).*cos(kAlpha(2));
ky = -kAlpha(1).*sin(kAlpha(2));
kxky = [kx,ky];
q=exp(sqrt(-1)*(xyw(:,1:2)*kxky'));
phi = angle(v(centerInd))-angle(q(centerInd));
q = q*exp(sqrt(-1)*phi);         % phase offset
q = q.*xyw(:,3);

q = [real(q); imag(q)];
callCount = callCount+1;

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


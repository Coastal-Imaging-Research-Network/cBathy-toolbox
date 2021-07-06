function plotPhaseTile(xy, v, vPred)
%
%  plotPhaseTile(xy, v, vPred)
%
%  plots the phase and amplitude of eigenvector modes (or data) in xy space
%  using the complex eigenvector (or csm) v.  Uses scatter 3 since it does
%  not assume regular spacing.  v is assumed to be a  vector of complex
%  coefficients (solution is done as concatenated real then imaginary
%  coeffs, so you need to to assemble the complex valued list).  vPred is
%  the predicted eigenvector structure, for comparison

clf; colormap(hot);
va = angle(v)*180/pi;
vpa = angle(vPred)*180/pi;
subplot(221)
scatter3(xy(:,1), xy(:,2), va, [], va, 'filled');
view(2); caxis([-180 180]); axis equal; colorbar; 
xlabel('x (m)'); ylabel('y (m)'); title('Observed phase')

subplot(222)
scatter3(xy(:,1), xy(:,2), abs(v), [], abs(v), 'filled');
view(2); axis equal; colorbar
xlabel('x (m)'); ylabel('y (m)'); title('Observed magnitude')

subplot(223)
scatter3(xy(:,1), xy(:,2), vpa, [], vpa, 'filled');
view(2); caxis([-180 180]); axis equal; colorbar
xlabel('x (m)'); ylabel('y (m)'); title('Predicted phase')

subplot(224)
scatter3(xy(:,1), xy(:,2), abs(vPred), [], abs(vPred), 'filled');
view(2); axis equal; colorbar
xlabel('x (m)'); ylabel('y (m)'); title('Predicted magnitude')

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


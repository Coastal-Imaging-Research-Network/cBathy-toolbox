function plotBathyCollect(bathy, figNum)
%  Function to plot the bathymetry and error from cBathy.  Allows
%  optional choice of figure number, otherwise defaults to the current
%  figure.
% Usage: 
% To make the plot in the current figure 
%    plotBathyCollect(bathy)
% or to plot in an existing figure or with a set handle:
%    plotBathyCollect(bathy, figNum)
%

% set up the figure
if nargin<2
    figNum = gcf;
    figure(gcf);
else
    figure(figNum);
end

clf;
set(figNum,'Colormap',flipud(jet));

% plot the fCombined bathymetry
ax1=subplot(1,2,1);

pcolor(ax1,bathy.xm, bathy.ym, bathy.fCombined.h);
shading flat
caxis([0 10]);
set(gca, 'ydir', 'nor');
axis equal;
axis tight;
xlabel('x (m)');
ylabel('y (m)');
titstr=datestr(datenum('19700101','yyyymmdd')+str2double(bathy.epoch)/24/3600,...
    'mmm dd yyyy, HH:MM');

title( titstr );
h=colorbar('peer', gca);
% set(h, 'ydir', 'rev');
set(get(h,'title'),'string', 'h (m)')

ax2=subplot(1,2,2);

pcolor(ax2,bathy.xm, bathy.ym, -bathy.fCombined.hErr);
shading flat
caxis([-2 0]);
set(gca, 'ydir', 'nor');
axis equal;
axis tight;
xlabel('x (m)');
ylabel('y (m)');
h=colorbar('peer', gca);
set( h, 'ydir', 'rev' );
tickLabels = get( h, 'yticklabel' );
tickLabels = cellstr(tickLabels);
for ll=1:length(tickLabels)
    tickLabels{ll} = num2str( abs(str2double(tickLabels{ll})), '%.1f' );
end
drawnow
set( h, 'yticklabel', tickLabels );
set( get(h,'title'), 'string', 'hErr (m)' );

return


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

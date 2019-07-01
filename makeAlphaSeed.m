function aSeed = makeAlphaSeed(xy,v)
% Erwin Bergsma (erwin.bergsma@legos.obs-mip.fr)
% April 2019
%
%% Phase ramp over tile:
va = angle(v)*180/pi;

%% Interpolation (Radon only works on equidistantly space data)
% note, dx and dy can be modified
[Ix,Iy]         =   meshgrid(min(xy(:,1)):1:max(xy(:,1)),min(xy(:,2)):1:max(xy(:,2)));
Iz              =   griddata(xy(:,1), xy(:,2), va, Ix, Iy);
Iz(isnan(Iz))   =   0; % Radon does not allow for NaNs --> filled with 0's

%% Apply radon over theta
theta           =   -90:90;
R               =   radon(Iz,theta);

%% Pick the direction with maximum variance (representing the incident wave angle) 
[~,c]           =   max(var(R));
aSeed           =   deg2rad(theta(c)); % result in radians.

end
% EOF



%{
% testing clutter:


clear
close all
clc
fName = 'radonTestset_001.mat';

% fName = 'radonTestset_003.mat';
%  fName = 'exampleTestData1015151300GMT.mat';

load(fName)

if ~exist('va')
    va = angle(v)*180/pi;
end

[Ix,Iy]         =   meshgrid(min(xy(:,1)):1:max(xy(:,1)),min(xy(:,2)):1:max(xy(:,2)));
Iz              =   griddata(xy(:,1), xy(:,2), va, Ix, Iy);

Izz             =   Iz;
Izz(isnan(Izz)) =   0;
radAngles       =   -90:90;
R               =   radon(Izz,radAngles);

[~,c]           =   max(var(R));
ang             =   radAngles(c);

figure
subplot(221)
scatter3(xy(:,1), xy(:,2), va, [], va, 'filled');

hold on

ypl     =   75*sind(-ang+90);
xpl     =   75*cosd(-ang+90);

ypl2    =   75*sind(-ang);
xpl2    =   75*cosd(-ang);

% plot([round(mean(xy(:,1)))-xpl round(mean(xy(:,1)))+xpl], [round(mean(xy(:,2)))-ypl round(mean(xy(:,2)))+ypl],'r','linewidth', 2)

view(2); caxis([-180 180]);  colorbar
xlabel('x (m)'); ylabel('y (m)'); title('Observed phase')
set(gca, ...
        'Box'           , 'on',...
        'TickDir'       , 'out'         ,...
        'TickLength'    , [.005 .005]     ,...
        'XMinorTick'    , 'on'          ,...
        'YMinorTick'    , 'on'          ,...
        'XGrid'         , 'on'          ,...
        'YGrid'         , 'on'          ,...
        'LineWidth'     , .5           ,...
        'FontWeight'    , 'normal'      ,...
        'FontName'      ,'Times'        ,...
        'FontSize'      , 8           ,...
        'layer'         ,'top'        );
    
    axis equal

xl              =   get(gca,'XLim');
yl              =   get(gca,'YLim');

subplot(222)
pc= pcolor(Ix,Iy,Iz) ; shading flat;  caxis([-180 180]);  colorbar
pc.HandleVisibility = 'off';
hold on
plot([round(mean(xy(:,1)))-xpl round(mean(xy(:,1)))+xpl], [round(mean(xy(:,2)))-ypl round(mean(xy(:,2)))+ypl],'r','linewidth', 2)
plot([round(mean(xy(:,1)))-xpl2 round(mean(xy(:,1)))+xpl2], [round(mean(xy(:,2)))-ypl2 round(mean(xy(:,2)))+ypl2],'r--','linewidth', 1)


leg = legend('"Wave crest angle"','Incident wave angle');
leg.Position = [0.6 0.43 0.1 0.1];
leg.Box = 'off';


xlabel('x (m)'); ylabel('y (m)'); title('Interpolated Obs. phase')
xlim(xl); ylim(yl)

set(gca, ...
        'Box'           , 'on',...
        'TickDir'       , 'out'         ,...
        'TickLength'    , [.005 .005]     ,...
        'XMinorTick'    , 'on'          ,...
        'YMinorTick'    , 'on'          ,...
        'XGrid'         , 'on'          ,...
        'YGrid'         , 'on'          ,...
        'LineWidth'     , .5           ,...
        'FontWeight'    , 'normal'      ,...
        'FontName'      ,'Times'        ,...
        'FontSize'      , 8           ,...
        'layer'         ,'top'        );
 axis equal
   
    
    
    
subplot(223)
pcolor(radAngles, 1:size(R,1),R); shading flat;   colorbar
hold on; plot([radAngles(c) radAngles(c)],[1 size(R,1)],'r')
xlabel('Incident swell angle [degrees]'); ylabel('Beam length rho'); title('Radon-based Sinogram')


set(gca, ...
        'Box'           , 'on',...
        'TickDir'       , 'out'         ,...
        'TickLength'    , [.005 .005]     ,...
        'XMinorTick'    , 'on'          ,...
        'YMinorTick'    , 'on'          ,...
        'XGrid'         , 'on'          ,...
        'YGrid'         , 'on'          ,...
        'LineWidth'     , .5           ,...
        'FontWeight'    , 'normal'      ,...
        'FontName'      ,'Times'        ,...
        'FontSize'      , 8           ,...
        'layer'         ,'top'        );
    
an = annotation(gcf,'textbox',...
    [0.53 0.13 0.4 0.2],...
    'String',{ 'Zero is shore normal -- angles clockwise', '','Incident wave angle',[num2str(ang) ' Degrees ('  num2str(deg2rad(ang),'%1.3f') ' radians )'  ],'','Picked incident wave-CREST angle:',[ num2str(ang-90) ' Degrees']},...
    'FitBoxToText','off');
    
an.FontName = 'Times';
an.FontSize = 8;
an.LineStyle = 'none';
an.FontWeight = 'bold';

print(gcf,['angleSeedRadon_' fName(1:end-4)],'-dpng','-r450')
%}
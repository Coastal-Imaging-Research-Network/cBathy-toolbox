function examineSingleBathyResult(bathy)
%   examineSingleBathyResult(bathy)
%
% simple displays of variable in the bathy structure to give a visual feel
% for the elements of performance.  bathy is the user-supplied bathy
% structure.

% find the list of unique frequencies 

fB = bathy.fDependent.fB(:);
fBList = unique(fB(~isnan(fB)));

for i = 1: length(fBList)
    f = fBList(i);
    id = find(fB == f);
    fullSize = size(bathy.fDependent.fB);
    small = fullSize(1:2);
    empty = nan(small);
    [r,c,d] = ind2sub(fullSize,id);
    idSmall = sub2ind(small,r,c);
    str=datestr(datenum('19700101','yyyymmdd')+str2double(bathy.epoch)/24/3600,21);
    %str = datestr(epoch2Matlab(str2num(bathy.epoch)), 21);
    str = [str ', f = ' num2str(f,'%.3f') ' Hz'];
    % now plot figs
    figure(2); clf
    subplot(331);
    k = empty;
    k(idSmall) = bathy.fDependent.k(id);
    imagesc(bathy.xm, bathy.ym, k); 
    caxis([0 2*median(median(k,'omitnan'),'omitnan')]); colorbar, title('k')
    set(gca, 'ydir', 'norm')

    subplot(332)
    a = empty;
    a(idSmall) = bathy.fDependent.a(id);
    imagesc(bathy.xm, bathy.ym, a*180/pi); 
    caxis([-45 45]); colorbar, title(str);
    set(gca, 'ydir', 'norm')

    subplot(333)
    hTemp = empty;
    hTemp(idSmall) = bathy.fDependent.hTemp(id);
    imagesc(bathy.xm, bathy.ym,hTemp); 
    caxis([0 10]); colorbar, title('hTemp')
    set(gca, 'ydir', 'norm')

    subplot(334)
    kErr = empty;
    kErr(idSmall) = bathy.fDependent.kErr(id);
    imagesc(bathy.xm, bathy.ym,kErr); 
    caxis([0 2*median(median(kErr,'omitnan'),'omitnan')]); colorbar, title('kErr')
    set(gca, 'ydir', 'norm')

    subplot(335)
    aErr = empty;
    aErr(idSmall) = bathy.fDependent.aErr(id);
    imagesc(bathy.xm, bathy.ym,aErr*180/pi); 
    caxis([0 30]); colorbar, title('aErr')
    set(gca, 'ydir', 'norm')

    subplot(336)
    hTempErr = empty;
    hTempErr(idSmall) = bathy.fDependent.hTempErr(id);
    imagesc(bathy.xm, bathy.ym,hTempErr); 
    caxis([0 5]); colorbar, title('hTempErr')
    set(gca, 'ydir', 'norm')

    subplot(337)
    imagesc(bathy.xm, bathy.ym, bathy.fCombined.h(:,:)); 
    caxis([0 10]); colorbar, title('h')
    set(gca, 'ydir', 'norm')

    subplot(338)
    imagesc(bathy.xm, bathy.ym, bathy.fCombined.hErr(:,:)); 
    caxis([0 5]); colorbar, title('hErr')
    set(gca, 'ydir', 'norm')

    subplot(339)
    fNum = empty;
    fNum(idSmall) = d;
    fNum(isnan(fNum)) = 0;
    imagesc(bathy.xm, bathy.ym,fNum); 
    colorbar, title('f-order')
    set(gca, 'ydir', 'norm')
    input('Hit enter to see next frequency, <CR> to quit ');
end




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


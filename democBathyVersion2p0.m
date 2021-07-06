function outFileName = democBathyVersion2p0
% Demo Run of cBathy :
%
% This code will run cBathy on a sample data set located in subfolder cBathyDemoData.
% 
% The sample case is from August 0, 2015, from the Argus system at Duck,
% NC.
% 
% This comes from an example m-file to demonstrate how to run cBathy and 
% display results.  It uses a supplied example data set and does not make
% assumptions about CIL conventions or databases.

% demo data: Find the sample file:
% data_stackPnStr='1439053140.Sat.Aug.08_16_59_00.GMT.2015.argus02b.cx.mBW.mat';
dataStackName='1447691340.Mon.Nov.16_16_29_00.GMT.2015.argus02b.cx.mBW.mat';
if ~exist(dataStackName,'file')
    dataDirectory = fileparts(which('analyzeBathyCollect'));
    dataStackName = fullfile(dataDirectory,'DemoData',dataStackName);
end

% output directory and file name:
outDirectory = 'NewDemoTest';
outName = 'cBathyOutputDemo.mat';
if ~exist(outDirectory,'dir')
    mkdir(outDirectory);
end

% Input parameter file:
stationStr = 'argus02b';
eval(stationStr)        % creates the params structure.

load(dataStackName)

bathy.epoch = num2str(T(1));
bathy.sName = dataStackName;
bathy.params = params;


bathy = analyzeBathyCollect(XYZ, T, RAW, CAM, bathy);

outFileName = fullfile(outDirectory,outName);
save(outFileName,'bathy');

fprintf('Output files saved to %s\n',outDirectory);
% 
% figNum=figure('RendererMode','manual','Renderer','painters',...
%     'Units','normalized',...
%     'Position',[0.3,0.3,0.4,0.4],...
%     'Colormap',flipud(jet));
% set(figNum,'Units','pixels');
figNum=figure('RendererMode','manual','Renderer','painters',...
    'Colormap',flipud(jet));

plotBathyCollect(bathy,figNum);

return




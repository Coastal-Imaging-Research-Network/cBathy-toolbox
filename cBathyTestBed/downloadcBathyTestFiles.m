% downloadcBathyTestFiles.m
% June 2021
%
% This script shows how to automatically download cBathy input files from 
% the test data set provided by Oregon State University Coastal Imaging
% Laboratory (CIL).  CIL has produced a standard set of 39 survey test 
% dates with cBathy input data. For each test date, ground truth survey and
% environmental data is provided in the mat file bathyTestDataSet.mat. The
% mat file also provides the FTP storage location and filenames of gridded
% half-hourly cBathy input files (acquired by the Argus camera system) for 
% the 3 days prior through the survey date (for a maximum of 96 cBathy
% input data sets per survey date).
% 
% This example script demonstrates automatic download of the cBathy input
% files by downloading the first 3 files for the first test date and writes
% them to a sub-folder called 'cBathyFiles'.  The script performs the
% following steps:
%   1) loads the bathyTestDataSet.mat file
%   2) identifies the cBathy files associated with the first date
%   3) creates an output directory
%   4) connects to the CIL FTP server
%   5) loops through and downloads the first 3 data sets
%
% Requirements:
%   1) This code requires an internet connection
%   2) This file must be stored in the same folder as bathyTestDataSet.mat
%   3) cBathy is required to process the downloaded data
%       a) Version 2.0 recommended
%       b) Parameter file argus02b.m should be used
%
% This code was developed on a Windows 10 desktop in MATLAB 2020b.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1) load the test data set mat file
load('bathyTestDataSet.mat')

% 2) for the first date (5/20/15), find the list of up to 96 cBathy files
% (the variable 'bathyTestDataSet' is imported from the mat file)
date2run = 1;
cBathyFiles = bathyTestDataSet(date2run).ArguscBathyFiles;

% 3) define and create the output sub-directory
outDir = [pwd filesep 'cBathyFiles'];

% make the output directory if it doesn't exist
if ~exist(outDir); mkdir(outDir); end

% 4) connect to the CIL FTP server (the variable 'ftpServer' is imported 
% from the mat file)
ftpObj = ftp(ftpServer);

% 5) loop through and download the first 3 files for 5/20/15
for f = 1:3
    
    % split the full cBathy filename into the FTP path and file name
    slashIdx = strfind(cBathyFiles(f,:),'/');
    ftpPath = cBathyFiles(f,1:slashIdx(end));
    fileName = cBathyFiles(f,slashIdx(end)+1:end);
        
    % change directory on the FTP server to find file of interest
    cd(ftpObj,ftpPath);
    
    % download the file and save it in output directory
    mget(ftpObj,fileName,outDir);
    
end

% close the ftpObj
close(ftpObj);
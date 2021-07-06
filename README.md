# cBathy-2.0
 README for cBathy

When you type 'help {toolboxName}' where you insert your own toolbox
name, will give the Contents of the toolbox.
 
The outline below shows the order of how analysis routines are called.

Note: Version 2.0 requires Matlab 2016a or newer.
 
This toolbox has been extracted from the full CIL version and SHOULD work on a standalone basis.  In doing this, a number of checks have been removed since these depend on CIL databases and standards.
 
One demo file is provided along with example data.
'democBathyVersion2p0' runs the main cBathy processing to create phase 1 and 2 results (fDependent and fCombined) and plots the bathymetry results in fCombined.  This is currently set to analyze 
a test data set, 1447691340.Mon.Nov.16_16_29_00.GMT.2015.argus02b.cx.mBW.mat, one of the new standard testbed datat sets created by OSU.  The cBathy input data is contained the subfolder 
DemoData along with the sample bathymetry output. The demo produces and saves the bathymetry information estimated by cBathy into a new folder.
 
The demo needs only the single time stack file information to run, although if tide information is found the routine should propogate the tide fields.  The Kalman stage needs a process error routine specific to your site (findProcessError) and this usually needs the wave height, H. Adequate results can be found by guessing H, for  instance H = 1 m in this demo.  It makes no sense to Kalman filter if you have not removed the tide (averaging a non-stationary signal).  The toolbox contains a routine doKal.m which is a CIL version, included only to illustrate the steps that we normally take.  Note the use of fixBathyTide in Kalman filtering to make sure the tide has been compensated for.  If tide has been fixed in a previous step, this routine will do no harm.
 
Note that the supplied example tide routine, fixBathyTide, is a CIL
routine that normally looks for two input arguments, the first of which is the station name that we extract from the stack name (to ensure that you can't possibly call the tide routine for an incorrect station).  If the stack name is not standard, the routine will assume that this is not a CIL station and will fall back to a single input argument version (time), leaving the user responsible for chosing the correct tide location.  
 
Please let us know if problems arise
[HERE](https://github.com/Coastal-Imaging-Research-Network/cBathy-Toolbox/issues)



Logicial Outline for analyzeBathyCollect version 2

![alt text](https://github.com/Coastal-Imaging-Research-Network/cBathy-Toolbox/blob/version-2.0/manual/versionOrgCharts.png?raw=true)

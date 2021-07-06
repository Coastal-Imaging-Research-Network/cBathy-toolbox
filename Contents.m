% cBathy-Toolbox-1.3 - Estimate k-alpha and bathy from pixel data
%
% Batch Routines
%   cBathyBatch         - executes cBathy for a range of days
%   analyzeSingleBathyRun - batch analysis for a single stackName
%   analyzeSingleBathyRunFrommBW - batch from an mBW stack in cx
%   SETTINGS            - contains the params setting for each site
%
% Stack Routines: 
%   loadBathyStack      - load all cameras for a bathy stack
%
% Analysis Routines:
%   analyzeBathyCollect - single run cBathy analysis (parallel)
%   prepBathyInput      - prepare inputs for analysis
%   csmInvertKAlpha     - main cBathy inversion routine for k-alpha
%   bathyFromKAlpha     - nonlinear solver for bathy from k-alpha
%   fixBathyTide        - adjust depth estimates for tide.
%   prepareTiles        - find fs, vs, seeds for each tide
%   predictCSM          - xspectral matrix forward model for solver
%   findKAlphaSeed      - seed for nonlinear solver 
%   kInvertDepthModel   - used for bathy solver
%   bathyCI 		- modified version of nlparci for cBathy
%
% Kalman Filtering:
%   makeKalmanBathySeed - initialize the first run for K-filtering
%   runningFilterBathy  - wrapper to Kalman filter a sequence of runs
%   KalmanFilterBathy   - core Kalman filter routine
%   findProcessError    - compute sensible process error
%
% Debugging and viewing cBathy components
%   plotStacksAndPhaseMaps  - debugMode displays for whole collect
%   listfDependentResultsForOnePoint - debugMode listing of fDependents
%   examineSingleBathyResult- display all variables for any bathy
%   plotBathyCollect        - images of a single bathy and errors
%   plotBathyCollectKalman  - images of a Kalman-ed bathy and error
%   showHourlyBathyResults  - loop through a bathy sequence
%   showHourlyKalmanResults - loop through smooth sequence
%   plotBathyKalmanStep     - steps through runs showing all debug info
%   alterAnalysisArray 	    - allow change to the xm-ym values for debugging
%
% Viewing the cBathy Stack Data
%   showcBathyTimeSeriesMovie - display a sequence of cBathy "frames"
%   findInterpMap             - find mapping from pixels to regular map 
%   useInterpMap              - use the interp map from findInterpMap
%   showWaveVarianceMap       - show wave information visually

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


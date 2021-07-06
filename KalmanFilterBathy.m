function smoothBathy = KalmanFilterBathy(priorBathy, newBathy, H)
%
%   smoothBathy = KalmanFilterBathy(priorBathy, newBathy, H);
%
%  carries out a Kalman filter smoothing of a new Bathy collect adding
%  to a priorBathy using simple Kalman filtering.  Standard bathy
%  structures are assumed and passed along, updating the file name of
%  the prior.  Filtered data are stored in the sub-structure
%  runningAverage.

smoothBathy = newBathy;       % a good start
hNew = newBathy.fCombined.h; 
hNewErr = newBathy.fCombined.hErr;
hPrior = priorBathy.runningAverage.h;
dt = (str2num(newBathy.epoch) - str2num(priorBathy.epoch)) / (24*3600);  % in days
foo = parseFilename(priorBathy.sName);
Q = findProcessError(foo.station, newBathy, H)*dt;
P = sum(cat(3, priorBathy.runningAverage.P, Q),3,'omitnan');

% update everywhere then fix the nan problems in prior or new
K = P ./ (P + newBathy.fCombined.hErr.^2);
hSmoothed = hPrior + K.*(hNew-hPrior);
PNew = (1-K).*P;

% deal with nan's
badNew = find(isnan(hNew) | isnan(hNewErr)); % stick with hPrior
hSmoothed(badNew) = hPrior(badNew);
PNew(badNew) = P(badNew);   % pass along growing covariance

badPrior = find(isnan(hPrior));     % take new if no prior
hSmoothed(badPrior) = hNew(badPrior);
PNew(badPrior) = hNewErr(badPrior).^2;   % pass along covariance guess

% cap any runaway variances at a max value to avoid K=0 when P is huge
% Holman 01/22/12 fix for runaways.  
maxP = 10^4;
PNew(PNew > maxP) = maxP;

smoothBathy.runningAverage.h = hSmoothed;
smoothBathy.runningAverage.hErr = sqrt(PNew);
smoothBathy.runningAverage.P = PNew;
smoothBathy.runningAverage.Q = Q;
smoothBathy.runningAverage.K = K;
smoothBathy.runningAverage.prior = priorBathy.sName;

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


function pt = tstat3( v, tp, stat )
% TSTAT3 computes one of three t_statistics: one-sided t-probability, or
%        two-sided t-probability, or the inverse t-statistic in any single 
%        call.  It does not take vectors as arguments.  
% 
%   INPUT ARGUMENTS: 
%       v       Degrees-of freedom (integer)
% 
%       tp      T-statistic: to produce t-probability
%                   OR
%               Probability (alpha): to produce t-statistic
% 
%       stat    Desired test — 
%                   'one'   One-tailed t-probability
%                   'two'   Two-tailed t-probability
%                   'inv'   Inverse t-test
% 
%   OUTPUT ARGUMENT:
%       pt      T-probability OR T-statistic, as requested in ‘stat’
% 
%   USE:
%       FIND ONE-TAILED PROBABILITY GIVEN t-STATISTIC & DEGREES-OF-FREEDOM
%           p = tstat3(v, t, 'one')
% 
%       FIND TWO-TAILED PROBABILITY GIVEN t-STATISTIC & DEGREES-OF-FREEDOM
%           p = tstat3(v, t, 'two')
% 
%       FIND ONE-TAILED t-STATISTIC GIVEN PROBABILITY & DEGREES-OF-FREEDOM
%           t = tstat3(v, p, 'inv')
%       
%  
%  
% Star Strider — 2016 01 24 — 


% % % % T-DISTRIBUTIONS — 
% Variables: 
% t: t-statistic
% v: degrees of freedom

tDist2T = @(t,v) (1-betainc(v/(v+t^2), v/2, 0.5));                              % 2-tailed t-distribution
tDist1T = @(t,v) 1-(1-tDist2T(t,v))/2;                                          % 1-tailed t-distribution

% This calculates the inverse t-distribution (parameters given the
%   probability ‘alpha’ and degrees of freedom ‘v’: 
tInv = @(alpha,v) fzero(@(tval) (max(alpha,(1-alpha)) - tDist1T(tval,v)), 5);  % T-Statistic Given Probability ‘alpha’ & Degrees-Of-Freedom ‘v’

statcell = {'one' 'two' 'inv'};                                                 % Available Options
nc = cellfun(@(x)~isempty(x), regexp(statcell, stat));                          % Logical Match Array
n = find(nc);                                                                   % Convert ‘nc’ To Integer

if (length(v) > 1) || (length(tp) > 1)
    error('                    —> TSTAT3 does not take vectorised inputs.')
elseif isempty(n)                                                                   % Error Check ‘if’ Block
    error('                    —> The third argument must be either ''one'', ''two'', or ''inv''.')
elseif (n == 3) && ((tp < 0) || (tp > 1))
    error('                    —> The probability for ''inv'' must be between 0 and 1.')
elseif (isempty(v) || (v <= 0))
    error('                    —> The degrees-of-freedom (''v'') must be > 0.')
end

switch n                                                                        % Calculate Requested Statistics
    case 1
        pt = tDist1T(tp, v);
    case 2
        pt = tDist2T(tp, v);
    case 3
        pt = tInv(tp, v);
    otherwise
        pt = NaN;
end


end
% ———————————————————————————  END: tstat3.m  ————————————————————————————

% original code was downloaded from Matlab Central 
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

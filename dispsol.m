function [k,kh] = dispsol(h, f, flag)
%
%	k = dispsol(h, f) returns the solution to the dispersion
%	equation using a iterative minimization technique [SLOW]
%	[k,kh] = dispSol(h, f, 0) returns approximate solution to
%	dispersion equation following Hunt 1979 JWPCOD, v. 105 no. WW4
%	See also Dean & Dalrymple p. 72
%	k is radial wavenumber
%	Either h or f can be a vector, but not both unless length(f) ==
%	length(h),
%   otherwise only first f will be used if both f and h are unequal
%   length vectors.

%  modified 08/01 by Holman to accept both f vectors of h vectors
%  but not both and to return only k (returning k as the second 
%  of two argument caused lots of accidental errors

% modified by KTHolland to handle both f and h vectors.

h = h(:);
f = f(:);

switch nargin
case 2 		% range is infinite wavelength to about 0.25 m
    if length(h)==1
        for i = 1:length(f)
            k(i) =fminbnd('dispEqnK',0,20, ...
                optimset('TolX',1e-5,'Display','off'),h,f(i));
        end
   elseif length(h) == length(f) % assume 2 vectors of h,f pairs
        for i = 1:length(f)
            k(i) =fminbnd('dispEqnK',0,20, ...
                optimset('TolX',1e-5,'Display','off'),h(i),f(i));
        end
   else
        for i = 1: length(h)
            k(i) = fminbnd('dispEqnK',0,20, ...
                optimset('TolX',1e-5,'Display','off'),h(i),f(1));
        end
    end
    k = k(:);
    kh = k.*h;
    
case 3
    if length(h)==1
        sigsq = (2*pi*f).^2;
        x = (sigsq*h)/9.82;
    elseif length(h) == length(f) % assume 2 vectors of h,f pairs
        sigsq = (2*pi*f).^2;
        x = (sigsq.*h)/9.82;
    else
        sigsq = (2*pi*f(1))^2;
        x = sigsq*h/9.82;
    end
    d1 = 0.6666666666;
    d2 = 0.3555555555;
    d3 = 0.1608465608;
    d4 = 0.0632098765;
    d5 = 0.0217540484;
    d6 = 0.0065407983;
    kh = sqrt(x.^2 + x ./ (1 + d1*x + d2*x.^2 + d3*x.^3 ...
        + d4*x.^4 + d5*x.^5 + d6*x.^6));
    kh = kh(:);
    if length(h)==1
        k = kh/h;
    else
        k = kh./h;
    end
otherwise
    error('Incorrect call to dispsol.  Must use either 2 or 3 inputs')
end

%
% Copyright by Oregon State University, 2002, 2009
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: dispsol.m 177 2016-03-31 02:29:28Z stanley $
%
% $Log: dispsol.m,v $
% Revision 1.2  2009/08/27 18:44:11  stanley
% replaced old dispsol with NRL/KTHolland version based on dispsol2.
%
% Revision 1.1  2004/08/20 20:20:54  stanley
% Initial revision
%
%
%key TSA 
%comment  Solves dispersion relation for k 
%

function phi0 = findAlpha0(xy, v)
%   phi0 = findAlpha0(xy, v)
%
% Given a phase map in xy represented by the phases of complex
% eigenfunction v, find a decent estimate of the wave angle to be used as
% the seed for the nonlinear cBathy search.

a = angle(v);
x = [min(xy(:,1)): max(xy(:,1))];
y = [min(xy(:,2)): max(xy(:,2))];
[X,Y] = meshgrid(x,y);

% interpolate phase maps to regular grid
F = scatteredInterpolant(xy,a);
ai = F([X(:) Y(:)]);
ai = reshape(ai, length(y), length(x));
[gx, gy] = gradient(ai);
phi0 = atan(median(gy(:))/median(gx(:)));

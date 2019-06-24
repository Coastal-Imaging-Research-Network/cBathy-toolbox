function h0 = findh0Duck(xm, ym, hMin)
%   h0 = findh0Duck(xm, ym, hMin)
%
%  Function to provide an initial guess at depth at a specified set of
%  analysis points, xm, ym, for a cBathy analysis.  The routine can be
%  approximate, but reasonable.  For shallow depths, it should threshold to
%  a minimum, hMin, which could be taken as 1 m.  
%  Ideally tide should be included, but we really only need an approximate
%  depth.

x0 = 100; x1 = 150;         % describe as roughly two linear segments
h1 = 2;
beta1 = 0.04;
beta2 = 0.008;

[X,Y] = meshgrid(xm,ym);
ind = find(X<=x1);
h0(ind) = (X(ind)-x0)*beta1;
ind = find(X>x1);
h0(ind) = h1 + (X(ind)-x1)*beta2;
h0 = reshape(h0, length(ym), length(xm));
h0(h0<hMin) = hMin;



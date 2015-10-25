% HOMOTRANS - 2D homogeneous transformation of points/lines.
%
% Function to perform a transformation on 2D homogeneous points/lines
% The resulting points/lines are normalised to lie in the z = 1 plane
%
% Usage:
%           t = homoTrans(P,v);
%
% Arguments:
%           P  - 3 x 3 transformation matrix
%           v  - 3 x n matrix of points/lines

%  Peter Kovesi
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  April 2000

function t = homoTrans(P,v);

t = P*v;
t(1,:) = t(1,:)./t(3,:);   %  Now normalise
t(2,:) = t(2,:)./t(3,:);
t(3,:) = ones(1,size(v,2));

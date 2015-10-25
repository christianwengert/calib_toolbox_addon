%Normalizes homogenous coordinates such that the last coordinate is 1
%You can use any dimension of the vectors
%
%Author:    Christian Wengert, 
%           Institute of Computer Vision
%           Swiss Federale Institute of Technology, Zurich (ETHZ)
%           wengert@vision.ee.ethz.ch
%           www.vision.ee.ethz.ch/~cwengert/
%
%Input:     x       unnormalized homogenous coordinates
%
%Output     y       normalized homogenous coordinates
%
%Syntax:    y = normalizeHomogenousCoordinates(x)

function y = normalizeHomogenousCoordinates(x)

    %get dimension of array
    ni = size(x,1);
    nj = size(x,2);
    %go through
    for j=1:1:nj
        y(:,j) = x(:,j)./x(ni,j);
    end
    y(ni,:) = ones(1,nj);
    
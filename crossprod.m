%Defines the crossproduct as defined in hartley and zisserman
% [e2]x   = as defined on p554 =    [   0,-e3,e2;
%                                       e3,0,-e1;  
%                                       -e2.e1.0    ]    
%
%Author:    Christian Wengert, 
%           Institute of Computer Vision
%           Swiss Federale Institute of Technology, Zurich (ETHZ)
%           wengert@vision.ee.ethz.ch
%           www.vision.ee.ethz.ch/~cwengert/
%
%Input:     a       A Vector (3x1)
%
%Output:    ax      The matrix [a]x as defined above
%
%Syntax:    ax = crossprod(a)   

function ax = crossprod(a)
    if(size(a,1) ~= 3 & size(a,2) ~= 1)
        error ('crossprod::Please specify an valid argument.');        
    end
    ax = [ 0,-a(3,1),a(2,1);a(3,1),0,-a(1,1);-a(2,1),a(1,1),0 ];
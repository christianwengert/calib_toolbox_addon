% INVPERSP - Computes inverse perspective transform for plane rectification.
%
% Function calculates the 3x3 homogeneous inverse transformation matrix
% describing the perspective transformation of a planar surface in an
% image. This can then be passed to imTrans to perform a rectification of
% the surface.  Four or more known image points are required.
%
% Usage:  [T, err] = invpersp(refpts, pts)
% 
% Arguments:
%            refpts - Array of reference points [x1 x2 ... xn
%                                                y1 y2 ... yn] (n>=4)
%            pts    - Array of image points [x1 x2 ... xn
%                                            y1 y2 ... yn]
% Returns:
%            T      - The 3x3 homogeneous transformation matrix
%            err    - Consistency errors (only meaningful for n > 4 points)
% 
% See also: imTrans.

% Peter Kovesi  
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk @ csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
%
% July 2001


function [T, err] = invpersp(refpts, pts)
    
    [refrows, refnpts] = size(refpts);
    [rows, npts] = size(pts);
    if rows ~= 2 | refrows ~=2
	error('data points must be in the form of an 2xN array');
    end

    if npts ~= refnpts
        error('data arrays must be of same size');
    end
    
    if npts < 4
        error('need at least 4 data points');
    end    
    
    x = pts(1,:); y = pts(2,:);     % Extract data in a convenient form
    xref = refpts(1,:); yref = refpts(2,:);

    % Set up equations to be solved    
    M = zeros(2*npts, 8);           % Allocate memory
    XY = zeros(2*npts,1);
    
    for n = 1:npts
	M(2*n-1,:) = [x(n) y(n) 1  0    0   0 -x(n)*xref(n) -y(n)*xref(n)];
	M(2*n  ,:) = [ 0    0   0 x(n) y(n) 1 -x(n)*yref(n) -y(n)*yref(n)];
	XY(2*n-1) = xref(n);
	XY(2*n)   = yref(n);
    end
    
    A = M\XY;
    A(9) = 1;
    T = reshape(A,3,3);
    T = T';
    
    err = [];
    if npts > 4
	% Apply transformation to image points and compare against
        % reference points to check consistency.
	
	newxy = T*[x;y;ones(1,npts)];
	newxy(1,:) = newxy(1,:)./newxy(3,:);
	newxy(2,:) = newxy(2,:)./newxy(3,:);    
	
	dxdysqrd = (newxy(1:2,:) - refpts).^2;
	err = sqrt(dxdysqrd(1,:) + dxdysqrd(2,:));
    end






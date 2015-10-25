function qtype=isq(q, TOL)
% ISQ(Q) checks to see if Q is a quaternion or set of quaternions.
%     ISQ returns a value accordingly:
%
%        0 if Q is not a quaternion or vector of quaternions:
%          has more than 2 dimensions or neither dimension is of length 4
%       
%        1 if the component quaternions of Q are column vectors:
%          Q is 4xN, where N~=4, or
%          Q is 4x4 and only the columns are normalized 
%
%        2 if the component quaternions of Q are row vectors:
%          Q is Nx4, where N~=4, or
%          Q is 4x4 and only the rows are normalized 
%
%        3 if the shape of the component quaternions is indeterminant:
%          Q is 4x4, and either both the columns and rows are normalized
%          or neither the columns nor rows are normalized.
%
%     In other words, if Q is 4x4, ISQ attempts to discern the shape of
%     component quaternions by determining whether the rows or the columns
%     are normalized (i.e., it assumes that normalized quaternions are
%     the more typical use of quaternions).
%
%     The test for normalization uses 2*EPS as a tolerance.
%
% See also ISNORMQ, EPS.

% Release: $Name: quaternions-1_2_2 $
% $Revision: 1.5 $
% $Date: 2001/05/01 20:20:30 $
 
% Copyright (C) 2001, Jay A. St. Pierre.  All rights reserved.

if nargin~=1

  error('isq() requires one input argument');

else

  tol=2*eps;
  
  size_q=size(q);
  
  if ( length(size_q)~=2 | max(size_q==4)~=1 )
    qtype=0; % Not a quaternion or quaternion vector
    
  elseif ( size_q(1)==4 & ...
           ( size_q(2)~=4 | ( ~sum((sum(q.^2,1)-ones(1,4))>tol) & ...
                               sum((sum(q.^2,2)-ones(4,1))>tol)  ) ...
             ) ...
           )
    qtype=1; % Component q's are column vectors
    
  elseif ( size_q(2)==4 & ...
           ( size_q(1)~=4 | ( ~sum((sum(q.^2,2)-ones(4,1))>tol) & ...
                               sum((sum(q.^2,1)-ones(1,4))>tol)  ) ...
             ) ...
           )
    qtype=2; % Component q's are row vectors

  else
    qtype=3; % Component q's are either columns or rows (indeterminate)

  end

end


function q_out=qmult(q1,q2)
% QMULT(Q1,Q2) calculates the product of two quaternions Q1 and Q2.
%    Inputs can be vectors of quaternions, but they must either have the
%    same number of component quaternions, or one input must be a single
%    quaternion.  QMULT will determine whether the component quaternions of
%    the inputs are row or column vectors according to ISQ.
%  
%    The output will have the same shape as Q1.  If the component
%    quaternions of either Q1 or Q2 (but not both) are of indeterminate
%    shape (see ISQ), then the shapes will be assumed to be the same for
%    both inputs.  If both Q1 and Q2 are of indeterminate shape, then both
%    are assumed to be composed of row vector quaternions.
%
% See also ISQ.

% Release: $Name: quaternions-1_2_2 $
% $Revision: 1.12 $
% $Date: 2001/05/01 20:20:31 $
 
% Copyright (C) 2001, Jay A. St. Pierre.  All rights reserved.
 

if nargin~=2
  error('qmult() requires two input arguments');
else
  q1type = isq(q1);
  if ( q1type == 0 )
    error(['Invalid input: q1 must be a quaternion or a vector of' ...
          ' quaternions'])
  end
  q2type = isq(q2);
  if ( q2type == 0 )
    error(['Invalid input: q2 must be a quaternion or a vector of' ...
          ' quaternions'])
  end
end

% Make sure q1 is a column of quaternions (components are rows)
if ( q1type==1 | (q1type==3 & q2type==1) )
  q1=q1.';
end

% Make sure q2 is a column of quaternions (components are rows)
if ( q2type==1 | (q2type==3 & q1type==1) )
  q2=q2.';
end

num_q1=size(q1,1);
num_q2=size(q2,1);

if (  num_q1~=num_q2 & num_q1~=1 & num_q2~=1 )
  error(['Inputs do not have the same number of elements:', 10, ...
         '   number of quaternions in q1 = ', num2str(num_q1), 10,...
         '   number of quaternions in q2 = ', num2str(num_q2), 10,...
         'Inputs must have the same number of elements, or', 10, ...
         'one of the inputs must be a single quaternion (not a', 10, ...
         'vector of quaternions).']) 
end

% Build up full quaternion vector if one input is a single quaternion
if ( num_q1 ~= num_q2 )
  ones_length = ones(max(num_q1,num_q2),1);
  if ( num_q1 == 1 )
    q1 = [q1(1)*ones_length ...
          q1(2)*ones_length ...
          q1(3)*ones_length ...
          q1(4)*ones_length ];
  else % num_q2 == 1
    q2 = [q2(1)*ones_length ...
          q2(2)*ones_length ...
          q2(3)*ones_length ...
          q2(4)*ones_length ];    
  end
end
  
% Products

% If q1 and q2 are not vectors of quaternions, then:
%
%   q1*q2 = q1*[ q2(4) -q2(3)  q2(2) -q2(1)
%                q2(3)  q2(4) -q2(1) -q2(2)
%               -q2(2)  q2(1)  q2(4) -q2(3)
%                q2(1)  q2(2)  q2(3)  q2(4) ]
%
% But to deal with vectorized quaternions, we have to use the ugly
% commands below.

prod1 = ...
    [ q1(:,1).*q2(:,4) -q1(:,1).*q2(:,3)  q1(:,1).*q2(:,2) -q1(:,1).*q2(:,1)];
prod2 = ...
    [ q1(:,2).*q2(:,3)  q1(:,2).*q2(:,4) -q1(:,2).*q2(:,1) -q1(:,2).*q2(:,2)];
prod3 = ...
    [-q1(:,3).*q2(:,2)  q1(:,3).*q2(:,1)  q1(:,3).*q2(:,4) -q1(:,3).*q2(:,3)];
prod4 = ...
    [ q1(:,4).*q2(:,1)  q1(:,4).*q2(:,2)  q1(:,4).*q2(:,3)  q1(:,4).*q2(:,4)];

q_out = prod1 + prod2 + prod3 + prod4;

% Make sure output is same format as q1
if ( q1type==1 | (q1type==3 & q2type==1) )
  q_out=q_out.';
end

% NOTE that the following algorithm proved to be slower than the one used
% above:
%
% q_out = zeros(size(q1));
% 
% q_out(:,1:3) = ...
%     [q1(:,4) q1(:,4) q1(:,4)].*q2(:,1:3) + ...
%     [q2(:,4) q2(:,4) q2(:,4)].*q1(:,1:3) + ...
%     cross(q1(:,1:3), q2(:,1:3));
% 
% q_out(:,4) = q1(:,4).*q2(:,4) - dot(q1(:,1:3), q2(:,1:3), 2);


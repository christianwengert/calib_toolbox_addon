function R=q2dcm(q)
% Q2DCM(Q) converts quaternions into direction cosine matrices.
%
%     The resultant DCM(s) will perform the same transformations as the
%     quaternion(s) in Q, i.e.:
%
%       R*v = qvxform(q, v) 
%
%     where R is the DCM, V is a vector, and Q is the quaternion.  Note that
%     for purposes of quaternion-vector multiplication, a vector is treated
%     as a quaterion with a scalar element of zero.
%
%     If the input, Q, is a vector of quaternions, the output, R, will be
%     3x3xN where input quaternion Q(k,:) corresponds to output DCM
%     R(:,:,k).
%
%     Note that the input Q will be processed by QNORM to ensure normality.
%
% See also DCM2Q, QNORM.

% Release: $Name: quaternions-1_2_2 $
% $Revision: 1.13 $
% $Date: 2002/01/21 06:46:20 $
 
% Copyright (C) 2000-02, Jay A. St. Pierre.  All rights reserved.


if nargin~=1
  error('q2dcm() requires one input argument');
else
  qtype=isq(q);
  if ( qtype == 0 )
    error(['Invalid input: must be a quaternion or a vector of' ...
          ' quaternions'])
  end
end

% Make sure input is a column of quaternions
if( qtype==1 )
  q=q.';
end

% Make sure quaternion is normalized to prevent skewed DCM
q=qnorm(q);

% Build quaternion element products
q1q1=q(:,1).*q(:,1);
q1q2=q(:,1).*q(:,2);
q1q3=q(:,1).*q(:,3);
q1q4=q(:,1).*q(:,4);

q2q2=q(:,2).*q(:,2);
q2q3=q(:,2).*q(:,3);
q2q4=q(:,2).*q(:,4);

q3q3=q(:,3).*q(:,3);
q3q4=q(:,3).*q(:,4);
  
q4q4=q(:,4).*q(:,4);

% Build DCM
R(1,1,:) =  q1q1 - q2q2 - q3q3 + q4q4;
R(1,2,:) = 2*(q1q2 + q3q4);
R(1,3,:) = 2*(q1q3 - q2q4);
  
R(2,1,:) = 2*(q1q2 - q3q4);
R(2,2,:) = -q1q1 + q2q2 - q3q3 + q4q4;
R(2,3,:) = 2*(q2q3 + q1q4);
  
R(3,1,:) = 2*(q1q3 + q2q4);
R(3,2,:) = 2*(q2q3 - q1q4);
R(3,3,:) = -q1q1 - q2q2 + q3q3 + q4q4;

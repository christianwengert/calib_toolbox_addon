function q=dcm2q(R)
% DCM2Q(R) converts direction cosine matrices into quaternions.
%
%     The resultant quaternion(s) will perform the equivalent vector
%     transformation as the input DCM(s), i.e.:
%
%       qconj(Q)*V*Q = R*V
%
%     where R is the DCM, V is a vector, and Q is the quaternion.  Note that
%     for purposes of quaternion-vector multiplication, a vector is treated
%     as a quaterion with a scalar element of zero.
%
%     If the input is a 3x3xN array, the output will be a vector of
%     quaternions where input direction cosine matrix R(:,:,k) corresponds
%     to the output quaternion Q(k,:).
%
% See also Q2DCM.

% Release: $Name: quaternions-1_2_2 $
% $Revision: 1.9 $
% $Date: 2002/01/21 06:46:20 $
 
% Copyright (C) 2000-2002, Jay A. St. Pierre.  All rights reserved.


if nargin~=1
  error('dcm2q() requires one input argument');
else
  size_R=size(R);
  if ( size_R(1)~=3 | size_R(2)~=3 | length(size_R)>3 )
    error(['Invalid input: must be a 3x3xN array'])
  end
end

q(1,:)=0.5*sqrt(1 + R(1,1,:) - R(2,2,:) - R(3,3,:)).*sgn(R(2,3,:)-R(3,2,:));
q(2,:)=0.5*sqrt(1 - R(1,1,:) + R(2,2,:) - R(3,3,:)).*sgn(R(3,1,:)-R(1,3,:));
q(3,:)=0.5*sqrt(1 - R(1,1,:) - R(2,2,:) + R(3,3,:)).*sgn(R(1,2,:)-R(2,1,:));
q(4,:)=0.5*sqrt(1 + R(1,1,:) + R(2,2,:) + R(3,3,:));

% Make quaternion vector a column of quaternions
q=q.';

q=real(q);

% Signum function (for our purposes)
function s=sgn(x)
  s=sign(x);
  s=s+(s==0);

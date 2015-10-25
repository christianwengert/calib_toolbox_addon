function qout=qconj(qin)
% QCONJ(Q) calculates the conjugate of the quaternion Q.
%     Works on "vectors" of quaterions as well.  Will return the same shape
%     vector as input.  If input is a vector of four quaternions, QCONJ will
%     determine whether the quaternions are row or column vectors according
%     to ISQ.
%
% See also ISQ.

% Release: $Name: quaternions-1_2_2 $
% $Revision: 1.14 $
% $Date: 2001/05/01 20:20:30 $
 
% Copyright (C) 2001, Jay A. St. Pierre.  All rights reserved.


if nargin~=1
  error('qconj() requires one input argument');
else
  qtype = isq(qin);
  if ( qtype==0 )
    error(['Invalid input: must be a quaternion or a vector of' ...
          ' quaternions'])
  elseif ( qtype==3 )
    warning(['Component quaternion shape indeterminate... assuming row' ...
             ' vectors'])
  end
end

% Make sure component quaternions are row vectors
if( qtype == 1 )
  qin=qin.';
end

qout(:,1)=-qin(:,1);
qout(:,2)=-qin(:,2);
qout(:,3)=-qin(:,3);
qout(:,4)= qin(:,4);

% Make sure output is same shape as input
if( qtype == 1 )
  qout=qout.';
end

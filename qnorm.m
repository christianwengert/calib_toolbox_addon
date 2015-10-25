function qout=qnorm(qin)
% QNORM(Q) normalizes quaternions.
%     Works on vectors of quaternions too.  If input is a vector of four
%     quaternions, QNORM will determine whether the quaternions are row or
%     column vectors according to ISQ.
%
% See also ISQ.

% Release: $Name: quaternions-1_2_2 $
% $Revision: 1.9 $
% $Date: 2001/05/01 20:20:31 $
 
% Copyright (C) 2001, Jay A. St. Pierre.  All rights reserved.


if nargin~=1
  error('qnorm() requires one input argument');
else
  qtype = isq(qin);
  if ( qtype == 0 )
    error(['Invalid input: must be a quaternion or a vector of' ...
          ' quaternions'])
  elseif ( qtype==3 )
    warning(['Component quaternion shape indeterminate... assuming row' ...
             ' vectors'])
  end
end


% Make sure qin is a column of quaternions
if( qtype == 1 )
  qin=qin.';
end

% Find the magnitude of each quaternion
qmag=sqrt(sum(qin.^2,2));

% Make qmag the same size a q
qmag=[qmag qmag qmag qmag];

% Divide each element of q by appropriate qmag
qout=qin./qmag;

% Make sure output is same shape as input
if( qtype == 1 )
  qout=qout.';
end

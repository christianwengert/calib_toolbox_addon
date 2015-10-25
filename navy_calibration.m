%This computes the hand-eye calibration using the method described in 
%"Robot Sensor Calibration: Solving AX = XB on the Euclidean Group"
% from F. Park and B. Martin 
%
%Input:
%Hmarker2world      a 4x4xNumber_of_Views Matrix of the form
%                   Hmarker2world(:,:,i) = [Ri_3x3 ti_3x1;[ 0 0 0 1]] 
%                   with 
%                   i = number of the view, 
%                   Ri_3x3 the rotation matrix 
%                   ti_3x1 the translation vector.
%                   Defining the transformation of the robot hand / marker
%                   to the robot base / external tracking device
%Hgrid2cam          a 4x4xNumber_of_Views Matrix (like above)
%                   Defining the transformation of the grid to the camera
%
%Output:
%Hcam2marker_       The transformation from the camera to the marker /
%                   robot arm
%err                The residuals from the least square processes
%
%Christian Wengert
%Computer Vision Laboratory
%ETH Zurich
%Sternwartstrasse 7
%CH-8092 Zurich
%www.vision.ee.ethz.ch/cwengert
%wengert@vision.ee.ethz.ch
function [Hcam2marker_, err] = navy_calibration(Hmarker2world, Hgrid2cam)

n=size(Hmarker2world,3);
A=[];
B=[];
C=[];
d=[];
M=zeros(3,3);


% Ax = xB
for i=1:n-1
  
    B(:,:,i)=Hgrid2cam(:,:,i+1)*inv(Hgrid2cam(:,:,i));
    
    Tb(:,:,i)=B(1:3,4,i);  % translation matrix of B
    
    A(:,:,i)=inv(Hmarker2world(:,:,i+1))*Hmarker2world(:,:,i);   % multiplication A = inv(Deri+1) * Deri
   
    Ra(:,:,i)=A(1:3,1:3,i);  % tranlation and rotation matrix of A
    Ta(:,:,i)=A(1:3,4,i);
    
    alpha=logMatrix(A(:,:,i));   %matrix logarithms
    beta=logMatrix(B(:,:,i));
    
    M=M+beta*alpha';
  
end

Rx=(M'*M)^(-1/2)*M';  

for i=1:n-1
    C=[C; eye(3)-Ra(:,:,i)];
    d=[d; Ta(:,:,i)-Rx*Tb(:,:,i)];
end

Tx=inv(C'*C)*(C'*d);

Hcam2marker_=[Rx Tx; 0 0 0 1];

        
if(nargout==2)
    err=0;
end
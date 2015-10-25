%This computes the hand-eye calibration using the method described in 
%"Hand-Eye Calibration, Horaud, Radu and Dornaika, Fadi"
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
function [Hcam2marker_, err] =inria_calibration(Hmarker2world, Hgrid2cam)

n=size(Hmarker2world,3);
A=[];
B=[];
C=[];

for i=1:n-1
    Dm(:,:,i)=Hgrid2cam(:,:,i+1)*inv(Hgrid2cam(:,:,i));    
    Tm(:,:,i)=Dm(1:3,4,i);  % used later to build Matrix B and C
    
    % equation from the paper: 
    % Doff * Dmi->i+1 = inv(Deri+1) * Deri * Doff 
  
    HH(:,:,i)=inv(Hmarker2world(:,:,i+1))*Hmarker2world(:,:,i);   % multiplication HH = Deri+1 * Deri --> quaternion(HH) = z
    z=dcm2q(HH(1:3,1:3,i));
    y=dcm2q(Dm(1:3,1:3,i));  %quaternion of Dm1->i+1
    
    % quaternion(Doff) * y = z * quaternion(Doff) -> A*quaternion(Doff)=0
    
    row1=[ z(4)-y(4) -z(3)-y(3)  z(2)+y(2) z(1)-y(1)];
    row2=[ z(3)+y(3)  z(4)-y(4) -z(1)-y(1) z(2)-y(2)];
    row3=[-z(2)-y(2)  z(1)+y(1)  z(4)-y(4) z(3)-y(3)];
    row4=[-z(1)+y(1) -z(2)+y(2) -z(3)+y(3) z(4)-y(4)];

    A=[A; row1; row2; row3; row4];  % build Matrix A
    
end

[U,S,V]=svd(A);
qoff=V(:,4);        
Roff=q2dcm(qoff);
Roff=Roff';                     %  transpone Roff, maybe one of the matrices have wrong direction

% Building B and C matrix
for i=1:n-1
    B=[B; Hmarker2world(1:3,1:3,i+1)-Hmarker2world(1:3,1:3,i)];
    C=[C; Hmarker2world(1:3,4,i)-Hmarker2world(1:3,4,i+1)-Hmarker2world(1:3,1:3,i+1)*Roff*Tm(:,:,i)];
end

Toff=inv(B'*B)*B'*C;  

Hcam2marker_=[Roff Toff; 0 0 0 1];

if(nargout==2)
    err = 0;
end
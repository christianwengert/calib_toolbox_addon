%This computes the hand-eye calibration using the method described in 
%"Hand-Eye Calibration Using Dual Quaternions" from 
%Konstantinos Daniilidis
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
function [Hcam2marker_, err] = hand_eye_dual_quaternion(Hmarker2world, Hgrid2cam)
%Our quaternions are like this (q1 q2 q3,s )
    %Get n
    n = size(Hmarker2world,3);
    %Make movements (a,B) which are interposition transformations
    %(marker2wordl and cam2grid)
    %transform A,B into dual quaternions        
    for i=1:n-1
        A = inv(Hmarker2world(:,:,i+1))*Hmarker2world(:,:,i);
        B = Hgrid2cam(:,:,i+1)*inv(Hgrid2cam(:,:,i));         
        [q,qprime] = getDualQuaternion(A(1:3,1:3),A(1:3,4));               
        Qa(i).q = q;
        Qa(i).qprime = qprime;

        [q,qprime] = getDualQuaternion(B(1:3,1:3),B(1:3,4));                
        Qb(i).q = q;
        Qb(i).qprime = qprime;
    end
    
    %The dual quaternion is (Q.q + epsilon*Q.prime)
    %a = Qa.q, a' = Qa.prime  idem for b
    S = [];
    for i=1:n-1
        S(:,:,i) = [Qa(i).q(1:3)-Qb(i).q(1:3)   crossprod(Qa(i).q(1:3)+Qb(i).q(1:3)) zeros(3,1) zeros(3,3);...
                    Qa(i).qprime(1:3)-Qb(i).qprime(1:3)   crossprod(Qa(i).qprime(1:3)+Qb(i).qprime(1:3)) Qa(i).q(1:3)-Qb(i).q(1:3)   crossprod(Qa(i).q(1:3)+Qb(i).q(1:3))];                                
    end  
    
    %Construct T
    T = [];    
    for i=1:n-1
        T = [T  S(:,:,i)'];      
    end
    
    T = T';
    %SVD 
    [U,S,V] = svd(T);
    
    %Solution, right null vectors of T
    v7 = V(:,7);
    v8 = V(:,8);
    
    u1 = v7(1:4);
    v1 = v7(5:8);
    
    u2 = v8(1:4);
    v2 = v8(5:8);
    %Now lambda1*v7+lambda2*v8 = [q;qprime]
    %
    %or other:
    %
    %lambda1^2*u1'*u1+2*lambda1*lambda2*u1'*u2+lambda2^2*u2'*u2 = 1   
    %and
    %lambda1^2*u1'*v1 + lambda1*lambda2*(u1'*v2+u2'*v1)+lambda2*u2'*v1 = 0
    %Setting lambda1/lambda2 = s
    %lambda1^2/lambda2^2*u1'*v1 + lambda1*lambda2/lambda2^2*(u1'*v2+u2'*v1)+lambda2^2/lambda2^2*u2'*v1 = 0
    %s^2*u1'*v1 + s*(u1'*v2+u2'*v1)+u2'*v1 = 0
    %s^2*u1'*v1 + s*(u1'*v2+u2'*v1)+u2'*v1 = 0
    a = u1'*v1;
    b = (u1'*v2+u2'*v1);
%     c = u2'*v1;
    c = u2'*v2 ;
    s = roots([a b c]);
    
    %insert into equation
    val1 = s(1)^2*u1'*u1+2*s(1)*u1'*u2+u2'*u2;
    val2 = s(2)^2*u1'*u1+2*s(2)*u1'*u2+u2'*u2;
    %Take bigger value
    if(val1>val2)
        s = s(1);
        val = val1;
    else
        s = s(2);
        val = val2;
    end
    %Get lambdas
    lambda2 = sqrt(1/val);
    lambda1 = s*lambda2;
    
    %This algorithm gives quaternion with the form of (s, q1 q2
    %q3)->contrary to the notation we used above (q1 q2 q3,s )
    %Therefore we must rearrange the elements!        
    qfinal = lambda1*v7+lambda2*v8;    
    q = [qfinal(2:4);qfinal(1)];
    qprime = [qfinal(6:8);qfinal(5)];
    
    %Extract transformation
    R = q2dcm(q);    
    t = 2*qmult(qprime,qconj(q));
    t = t(1:3);
    
    %Assign output arguments
    Hcam2marker_ = [R -R*t;[0 0 0 1]]^-1;    
    err=[];
    

%Creates a dual quaternion from a rotation matrix and a translation vector    
function [q,qprime] = getDualQuaternion(R,t)    
    %Conversion from R,t to the screw representation [d,theta,l,m]
    
    r = rodrigues(R);
    theta = norm(r);
    l = r/norm(theta);
    %Pitch d
    d = l'*t;    
    %Make point c
    c = .5*(t-d*l)+cot(theta/2)*cross(l,t);
    %moment vector
    m = cross(c,l);
    %Rotation quaternion
    %(q1 q2 q3,s )
    q = [sin(theta/2)*l; cos(theta/2)];
    %Get dual
    qprime = [.5*(q(4)*t+cross(t,q(1:3)));-.5*q(1:3)'*t];
    


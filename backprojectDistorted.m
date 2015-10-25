function [P,xd,x] = backprojectDistorted(K,R,t,X,kc)
    
    if(nargin<4 | nargin>5)
        error('Wrong number of input arguments');
    end
    if(nargin<5)
        kc = zeros(1,5);
    end
    
    %Construct K0
    K0 = K;
    K0(1:2,3) = [0 0]';
    cc = K(1:2,3);
	fc = [K(1,1);K(2,2)];    
    
    %Construct P    
    P = K0*[R t];
    
    if(length(X)>0)
        %Backproject ideally
        x = normalizeHomogenousCoordinates(P*X);
        %now add radial distortion
        kcbp = kc./(fc(1)^-1*[fc(1)^3;fc(1)^5;fc(1)^2;fc(1)^2;1]);%(1e3*[1e6;1e12;1e3;1e3;1]);   %Account to the squared focals in the expression   
        [xd,x] = addDistortion(x,fc,cc,kcbp);
    end
    
    
    
        
        
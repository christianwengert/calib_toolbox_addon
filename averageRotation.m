function Ravg = averageRotation(R)

    n = size(R,3);
    
    tmp = zeros(3);
    for i=1:n
        tmp = tmp+R(1:3,1:3,i);
    end  
    
    Rbarre = tmp/n;
    
    RTR = Rbarre'*Rbarre;
    [V,D] = eig(RTR);
    D = diag(flipud(diag(D)));
    V = fliplr(V);
    
    sqrtD = sqrt(inv(D));
    if(det(Rbarre(1:3,1:3))<0)
        sqrtD(3,3) = sqrtD(3,3)*-1;
    end
    Ravg = Rbarre*(V*sqrtD*V');

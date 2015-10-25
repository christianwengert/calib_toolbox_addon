function [xd, xp] = addDistortion(x,fc,cc,kc)    
    
    m = length(x);
    for j=1:m %length(x)
        %Radial stuff
        r2 = x(1,j)^2+x(2,j)^2;
        %Tangential stuff
        dx = [  2*kc(3)*x(1,j)*x(2,j)+kc(4)*(r2+2*x(1,j)^2);...
                kc(3)*(r2+2*x(2,j)^2)+2*kc(4)*x(1,j)*x(2,j)];
        %Putting all together
        xd(:,j) = (1+kc(1)*r2+kc(2)*r2^2+kc(5)*r2^3)*x(1:2,j)+dx+[cc(1);cc(2)];
        xp(:,j) = x(:,j)+[cc(1);cc(2);1];
    end
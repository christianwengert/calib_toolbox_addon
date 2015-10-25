function Havg = averageTransformation(H)
    n = size(H,3);
    
    Ravg = averageRotation(H(1:3,1:3,:));
    Tavg = 0;
    for i=1:n
        Tavg = Tavg + H(1:3,4,i);
    end
    
    Havg = [Ravg Tavg/n;[0 0 0 1]];
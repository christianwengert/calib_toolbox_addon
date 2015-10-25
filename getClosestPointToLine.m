
    

function [d, ix_d,angles] = getClosestPointToLine(searchPoints, x0, dir,MAX_PTS)    
    if(nargin<4)
        MAX_PTS = 16;
    end
    n = length(searchPoints);
    d = [];
    angles = [];
    for i=1:n 
        if(searchPoints(1,i)~=0)
            d(i) = distToLine(x0(1:2), dir(1:2), searchPoints(2:3,i));
            angles(i) = angle2Vect(dir(1:2),x0(1:2)-searchPoints(2:3,i));        
        else 
            d(i) = 10000000;
            angles(i) = 10000000;
        end
    end    
    [d,ix_d] = sort(d); 
%     angles = angles(ix_d);

    d = d(1:MAX_PTS);
%     angles = angles(1:MAX_PTS);
    ix_d = ix_d(1:MAX_PTS);
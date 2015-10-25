function [ix_d, d] = getClosestNeighbours(searchPoints, x0, MAX_PTS)
    if(nargin<3)
        MAX_PTS = 10;
    end
    n = size(searchPoints,2);
    d = [];
    for i=1:n 
        if(searchPoints(1,i)~=0)
            d(i) = norm(x0(1:2) - searchPoints(2:3,i));
        else 
            d(i) = 10000000;
        end
    end    
    [d,ix_d] = sort(d); 
%     d = d(1:MAX_PTS);
%     ix_d = ix_d(1:MAX_PTS);


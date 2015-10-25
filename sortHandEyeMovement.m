function index=sortHandEyeMovement(Hm2w)
    %Number of views
    n = size(Hm2w, 3);

    cnt=1;
    used = 1:n;       %Set 0 which one is already taken
    %Go through all
    startIndex = 1;
%     angles=0.000001;
    distance = 0.0000000001;
%     while(abs(angles)>0)
    while(abs(distance)>0)
%         qa = dcm2q(H(1:3,1:3,startIndex));
        x1 = Hm2w(1:3,4,startIndex);
        used(startIndex) = 0;%Mark it as used
        index(cnt) = startIndex;
        cnt = cnt+1;
        %Check with others
%         angles=0;
        distance = 0;
        for j=1:n            
            if(startIndex ~= j & used(j)~=0) % 
%                 qb = dcm2q(H(1:3,1:3,j));
                x2  = Hm2w(1:3,4,j);
%                 theta = angleBetweenQuaternions(qa,qb);
                d = norm(x1-x2);
%                 if(theta>angles), angles =theta; theta;curIndex = j; end
                if(d>distance), distance  = d;curIndex = j; end
            end
        end
        index(cnt) = curIndex;
        startIndex = curIndex;
    end
    %remove the last entry, as it is too long
    index(cnt) = [];

    
%     for i=1:n
%         X(:,i) = Hm2w(1:3,4,i);
%     end
%     draw3DPoints(X, '', 1,1)
% 
% 
%     
%     X2 = X(:,index);
%     draw3DPoints(X2, '', 1,2)

    
    return
    
    
function theta = angleBetweenQuaternions(qa, qb)
    theta = 2*acos(qa(4)*qb(4) + qa(1)*qb(1) + qa(2)*qb(2)+ qa(3)*qb(3));
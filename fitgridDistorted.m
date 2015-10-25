%Once the image is processed using the gridextractor method, this function
%tries to fit the grid on the extraced points in order to establish the
%correspondences (use this for severely distorted images, otherwise
%(faster) use fitgrid
%
%Input:     stats   The processed blobs of this image
%           id0     The index of the main bar
%           id1     The index of the second main bar
%           searchPoints    The potential grid points
%           doshow  1/0 to display / not display the results
%
%Output:    success The flag indicating whether it worked or not
%           x_      the 2D points of the grid points
%           X_      the corresponding 3D points of the grid points    
%           searchPoints    The points
%
%Christian Wengert
%Computer Vision Laboratory
%ETH Zurich
%Sternwartstrasse 7
%CH-8092 Zurich
%www.vision.ee.ethz.ch/cwengert
%wengert@vision.ee.ethz.ch
function [success, x_, X_, searchPoints] = fitgridDistorted(stats, searchPoints, id0, id1, dx, dy, doshow)

    if(doshow), hold on, end
    %Init values
    x_ = [];
    X_ = [];    
    success = 1;
    %Important sizes
    ndx = 1;
    ndy = 0;
    MAXANGLE = 25; %[deg]
    MAXDIST2LINE = 13;    
    DISTFACTORBIG = 1.36;
    DISTFACTOR = 1.3;
    %Special values for special lines
    mainAxisX = -2;
    mainAxisY = -3;
    %Add the space for 3D coordinates
    searchPoints(4:5,:) = NaN*ones(2, length(searchPoints));      
    
    %number of searchPoints
    n = length(searchPoints);
    
    %Get main searchPoints first
    x0 = [stats(id0).Centroid(1); stats(id0).Centroid(2)];
    x1 = [stats(id1).Centroid(1); stats(id1).Centroid(2)];

    %Directions
    dir0 = (x1-x0)/(norm(x1-x0));   
    %Get a 90°angle
    dir90_ = [-dir0(2);dir0(1)];
    
    %get the orientation of main bar    
    orientation = stats(id0).Orientation;
    y = tand(orientation);   
    dir90 = [-1;y];
    dir90 = dir90/norm(dir90);
    
    %Compare direction of orientation with dir90_ and dir90
    if(sign(dir90)==sign(dir90_))
    else
        dir90 = -dir90;
    end
    
    %Show main bars + Directions
    if(doshow)          
        line([x0(1), x0(1)+dir0(1)*100], [x0(2), x0(2)+dir0(2)*100], 'Color','r');
        line([x0(1), x0(1)-dir0(1)*100], [x0(2), x0(2)-dir0(2)*100], 'Color','r');
        line([x0(1), x0(1)+dir90(1)*100], [x0(2), x0(2)+dir90(2)*100]);
        line([x0(1), x0(1)-dir90(1)*100], [x0(2), x0(2)-dir90(2)*100]);
    end
    MAXDIST = stats(id0).MajorAxisLength/2;
    %Now first follow the better line and assign values
    searchPoints = getFirstLine(searchPoints, x0, -dir0, dx, 0, dx, 0, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
    searchPoints = getFirstLine(searchPoints, x1, dir0, -3*dx, 0, -dx, 0, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
            
    %Now the other direction, therefore we give some direction hint in
    %order to better get the same coordinate system always
    searchPoints = getOtherLine(searchPoints, x0, dir90, 0, 2*dy, 0, dy, MAXDIST, DISTFACTORBIG, MAXANGLE, MAXDIST2LINE, doshow);    
    searchPoints = getOtherLine(searchPoints, x0, -dir90, 0, -2*dy, 0, -dy, MAXDIST, DISTFACTORBIG, MAXANGLE, MAXDIST2LINE, doshow);                
    
    %Try to get all positive x-values
    ixpos = find(searchPoints(4,:) > 0); %these are the already found points that lie on x-axis in positive direction
    ixneg = find(searchPoints(4,:) < 0); %these are the already found points that lie on x-axis in negative direction              
    
    %GO make new lines along x positive and y negative
    lastx = x0;

    %sort points to be closer to x0
    [a,b] = sort(searchPoints(4,ixpos));
    ixpos = ixpos(b);
    for i=ixpos
        x = searchPoints(2:3,i);
        %Also adapt the direction
        dir0 = (x-lastx)/(norm(x-lastx));    
        dir90 = [-dir0(2);dir0(1)];
        if(doshow), plot(x(1) - dir90(1)*10,x(2) - dir90(2)*10,'yx'), end
        searchPoints = getOtherLine(searchPoints, x, -dir90, searchPoints(4,i), searchPoints(5,i)+dy, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);        
        lastx = x;
    end

    %GO make new lines along x positive and y negative
    lastx = x0;
    for i=ixpos
        x = searchPoints(2:3,i);
        %Also adapt the direction
        dir0 = (x-lastx)/(norm(x-lastx));    
        dir90 = [-dir0(2);dir0(1)];
        if(doshow), plot(x(1) + dir90(1)*10,x(2) + dir90(2)*10,'yx'), end
        searchPoints = getOtherLine(searchPoints, x, dir90, searchPoints(4,i), searchPoints(5,i)-dy, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);        
        lastx = x;
    end
    
    
    
    %GO make new lines along x negative and y negative
    [a,b] = sort(searchPoints(4,ixneg),'descend');
    ixneg = ixneg(b);
    
    lastx = x1;
    for i=ixneg
        x = searchPoints(2:3,i);
        %Also adapt the direction
        dir0 = (x-lastx)/(norm(x-lastx));    
        dir90 = [-dir0(2);dir0(1)];
        if(doshow),plot(x(1) + dir90(1)*10,x(2) + dir90(2)*10,'yx'), end
        searchPoints = getOtherLine(searchPoints, x, dir90, searchPoints(4,i), searchPoints(5,i)+dy, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);        
        lastx = x;
    end

    %GO make new lines along x negative and y negative
    lastx = x1;
    for i=ixneg
         x = searchPoints(2:3,i);
        %Also adapt the direction
        dir0 = (x-lastx)/(norm(x-lastx));    
        dir90 = [-dir0(2);dir0(1)];
        if(doshow),plot(x(1) - dir90(1)*10,x(2) - dir90(2)*10,'yx'),end
        searchPoints = getOtherLine(searchPoints, x, -dir90, searchPoints(4,i), searchPoints(5,i)-dy, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);        
        lastx = x;
    end    

    % Now the two rows that are hidden by the small bar
    %Also adapt the direction
    dir0 = (x1-x0)/(norm(x1-x0));
    dir90_ = [-dir0(2);dir0(1)];
    
    orientation = stats(id1).Orientation;
    y = tand(orientation);   
    dir0 = [-1;y];
    dir0 = dir0/norm(dir0);
    dir90 = [-dir0(2);dir0(1)];
    
    %Compare direction of orientation with dir90_ and dir90
   
    if(sign(dir90)==sign(dir90_))
    else
        dir90 = -dir90;
        dir0 = -dir0;
    end
  
    x = x1+dir0*stats(id1).MajorAxisLength/3;
    if(doshow), plot(x(1), x(2), 'mx','MarkerSize',15), end
    %First
    searchPoints = getOtherLine(searchPoints, x, -dir90, -2*dx, -dy, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
    searchPoints = getOtherLine(searchPoints, x, dir90, -2*dx, dy, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);

    %Second
    x = x1-dir0*stats(id1).MajorAxisLength/3;
    if(doshow), plot(x(1), x(2), 'mx','MarkerSize',15), end
    searchPoints = getOtherLine(searchPoints, x, -dir90, -dx, -dy, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
    searchPoints = getOtherLine(searchPoints, x, dir90, -dx, dy, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
    
    %Make the points
    finalindex = find(searchPoints(1,:)==0);
    x_ = searchPoints(2:3,finalindex);
    X_ = [searchPoints(4:5,finalindex)];
    X_ = [X_;zeros(1,length(X_))];
    
    return
    


function searchPoints = getOtherLine(searchPoints, x0, dir0, sX, sY, dx, dy, d0, factor, MAXANGLE, MAXDIST2LINE, doshow)
    x = x0(1:2);
    xstart = x + dir0*10;
    dir = dir0;
    d = d0;
    cnt = 0;
    while(x(1)>0)
        if(doshow), line([x(1), x(1)+dir(1)*50], [x(2), x(2)+dir(2)*50]);end
        if(cnt==0)
            [x, d, dir, searchPoints] = getNextPointstart(searchPoints,x, xstart, dir, sX, sY, factor*d, MAXANGLE, MAXDIST2LINE, doshow);
            d = norm(x-x0);
            dir = (x - x0)/d;                       
        else
            [x, d, dir, searchPoints] = getNextPoint(searchPoints, x, dir, sX, sY, factor*d, MAXANGLE, MAXDIST2LINE, doshow);
        end
                        
        %Get the angle
%         theta = acos(dir'*dir0)/(norm(dir)*norm(dir0))/pi*180
%         %Its a wrong one
%         if(theta>MAXANGLE)
%             disp('line is over')
%             break;
%         else
            if(doshow)
                if(size(x,1)>1)
                    plot(x(1), x(2), 'r+', 'MarkerSize',25)
                end
            end            
%         end
        dir0 =dir;
%         pause
        %update stuff
        sX = sX + dx;
        sY = sY + dy;
        cnt = cnt+1;
    end    
    

    
function searchPoints = getFirstLine(searchPoints, x0, dir0, sX, sY, dx, dy, d0, factor, MAXANGLE, MAXDIST2LINE, doshow)
    x = x0(1:2);
    dir = dir0;
    d = d0;
    while(x(1)>0)
        [x, d, dir, searchPoints] = getNextPoint(searchPoints, x, dir, sX, sY, factor*d, MAXANGLE, MAXDIST2LINE, doshow);
        sX = sX + dx;
        sY = sY + dy;
    end

% function [success, x_, X_, searchPoints] = fitgridDistorted(stats, searchPoints, id0, id1, doshow)
% 
%     if(doshow), hold on, end
%     %Init values
%     x_ = [];
%     X_ = [];    
%     success = 1;
%      %Important sizes
%     dx = 2;
%     dy = 2;
%     ndx = 1;
%     ndy = 0;
%     MAXANGLE = 20; %[deg]
%     MAXDIST2LINE = 12;    
%     DISTFACTOR = 1.3;
%     
%     %Special values for special lines
%     mainAxisX = -2;
%     mainAxisY = -3;
%     %Add the space for 3D coordinates
%     searchPoints(4:5,:) = NaN*ones(2, length(searchPoints));      
%     
%     %number of searchPoints
%     n = length(searchPoints);
%     
%     %Get main searchPoints first
%     x0 = [stats(id0).Centroid(1); stats(id0).Centroid(2)];
%     x1 = [stats(id1).Centroid(1); stats(id1).Centroid(2)];
% 
%     %Directions
%     dir0 = (x1-x0)/(norm(x1-x0));   
%     %Get a 90°angle
%     dir90_ = [-dir0(2);dir0(1)];
%     
%     %get the orientation of main bar    
%     orientation = stats(id0).Orientation;
%     y = tand(orientation);   
%     dir90 = [-1;y];
%     dir90 = dir90/norm(dir90);
%     
%     %Compare direction of orientation with dir90_ and dir90
%     if(sign(dir90)==sign(dir90_))
%     else
%         dir90 = -dir90;
%     end
%     
%     %Show main bars + Directions
%     if(doshow)          
%         line([x0(1), x0(1)+dir0(1)*100], [x0(2), x0(2)+dir0(2)*100], 'Color','r');
%         line([x0(1), x0(1)-dir0(1)*100], [x0(2), x0(2)-dir0(2)*100], 'Color','r');
%         line([x0(1), x0(1)+dir90(1)*100], [x0(2), x0(2)+dir90(2)*100]);
%         line([x0(1), x0(1)-dir90(1)*100], [x0(2), x0(2)-dir90(2)*100]);
%     end
%     MAXDIST = stats(id0).MajorAxisLength/2;
%     %Now first follow the better line and assign values
%     searchPoints = getFirstLine(searchPoints, x0, -dir0, 2, 0, dx, 0, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
%     searchPoints = getFirstLine(searchPoints, x1, dir0, -6, 0, -dx, 0, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
%             
%     %Now the other direction, therefore we give some direction hint in
%     %order to better get the same coordinate system always
% %     searchPoints = getOtherLine(searchPoints, x0, dir90, 0, sign(orientation)*-4, 0, sign(orientation)*-dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);    
% %     searchPoints = getOtherLine(searchPoints, x0, -dir90, 0, sign(orientation)*4, 0, sign(orientation)*dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);            
%     searchPoints = getOtherLine(searchPoints, x0, dir90, 0, 4, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);    
%     searchPoints = getOtherLine(searchPoints, x0, -dir90, 0, -4, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);                
% 
% %     searchPoints = getFirstLine(searchPoints, x0+30*dir90, dir90, 0, sign(orientation)*4, 0, sign(orientation)*dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);    
% %     searchPoints = getFirstLine(searchPoints, x0-30*dir90, -dir90, 0, sign(orientation)*-4, 0, sign(orientation)*-dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);            
% 
%     
%     %Try to get all positive x-values
%     ixpos = find(searchPoints(4,:) > 0); %these are the already found points that lie on x-axis in positive direction
%     ixneg = find(searchPoints(4,:) < 0); %these are the already found points that lie on x-axis in negative direction              
%     
%     %GO make new lines along x positive and y negative
%     lastx = x0;
% 
%     %sort points to be closer to x0
%     [a,b] = sort(searchPoints(4,ixpos));
%     ixpos = ixpos(b);
%     for i=ixpos
%         x = searchPoints(2:3,i);
%         %Also adapt the direction
%         dir0 = (x-lastx)/(norm(x-lastx));    
%         dir90 = [-dir0(2);dir0(1)];
%         if(doshow), plot(x(1) - dir90(1)*10,x(2) - dir90(2)*10,'yx'), end
%         searchPoints = getOtherLine(searchPoints, x, -dir90, searchPoints(4,i), searchPoints(5,i)+dy, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);        
%         lastx = x;
%     end
% 
%     %GO make new lines along x positive and y negative
%     lastx = x0;
%     for i=ixpos
%         x = searchPoints(2:3,i);
%         %Also adapt the direction
%         dir0 = (x-lastx)/(norm(x-lastx));    
%         dir90 = [-dir0(2);dir0(1)];
%         if(doshow), plot(x(1) + dir90(1)*10,x(2) + dir90(2)*10,'yx'), end
%         searchPoints = getOtherLine(searchPoints, x, dir90, searchPoints(4,i), searchPoints(5,i)-dy, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);        
%         lastx = x;
%     end
%     
%     
%     
%     %GO make new lines along x negative and y negative
%     [a,b] = sort(searchPoints(4,ixneg),'descend');
%     ixneg = ixneg(b);
%     
%     lastx = x1;
%     for i=ixneg
%         x = searchPoints(2:3,i);
%         %Also adapt the direction
%         dir0 = (x-lastx)/(norm(x-lastx));    
%         dir90 = [-dir0(2);dir0(1)];
%         if(doshow),plot(x(1) + dir90(1)*10,x(2) + dir90(2)*10,'yx'), end
%         searchPoints = getOtherLine(searchPoints, x, dir90, searchPoints(4,i), searchPoints(5,i)+dy, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);        
%         lastx = x;
%     end
% 
%     %GO make new lines along x negative and y negative
%     lastx = x1;
%     for i=ixneg
%          x = searchPoints(2:3,i);
%         %Also adapt the direction
%         dir0 = (x-lastx)/(norm(x-lastx));    
%         dir90 = [-dir0(2);dir0(1)];
%         if(doshow),plot(x(1) - dir90(1)*10,x(2) - dir90(2)*10,'yx'),end
%         searchPoints = getOtherLine(searchPoints, x, -dir90, searchPoints(4,i), searchPoints(5,i)-dy, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);        
%         lastx = x;
%     end    
% 
%     % Now the two rows that are hidden by the small bar
%     %Alos adapt the direction
%     dir0 = (x1-x0)/(norm(x1-x0));
%     dir90 = [-dir0(2);dir0(1)];
%     x = x1+dir0*stats(id1).MajorAxisLength/3;
%     if(doshow), plot(x(1), x(2), 'mx','MarkerSize',15), end
%     %First
%     searchPoints = getOtherLine(searchPoints, x, -dir90, -4, -dy, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
%     searchPoints = getOtherLine(searchPoints, x, dir90, -4, dy, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
% 
%     %Second
%     x = x1-dir0*stats(id1).MajorAxisLength/3;
%     if(doshow), plot(x(1), x(2), 'mx','MarkerSize',15), end
%     searchPoints = getOtherLine(searchPoints, x, -dir90, -2, -dy, 0, -dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
%     searchPoints = getOtherLine(searchPoints, x, dir90, -2, dy, 0, dy, MAXDIST, DISTFACTOR, MAXANGLE, MAXDIST2LINE, doshow);
%     
%     %Make the points
%     finalindex = find(searchPoints(1,:)==0);
%     x_ = searchPoints(2:3,finalindex);
%     X_ = [searchPoints(4:5,finalindex)];
%     X_ = [X_;zeros(1,length(X_))];
%     
%     return
%     
% 
% 
% function searchPoints = getOtherLine(searchPoints, x0, dir0, sX, sY, dx, dy, d0, factor, MAXANGLE, MAXDIST2LINE, doshow)
%     x = x0(1:2);
%     xstart = x + dir0*10;
%     dir = dir0;
%     d = d0;
%     cnt = 0;
%     while(x(1)>0)
%         if(doshow), line([x(1), x(1)+dir(1)*50], [x(2), x(2)+dir(2)*50]);end
%         if(cnt==0)
%             [x, d, dir, searchPoints] = getNextPoint(searchPoints, xstart, dir, sX, sY, factor*d, MAXANGLE, MAXDIST2LINE, doshow);
%             d = norm(x-x0);
%             dir = (x - x0)/d;                       
%         else
%             [x, d, dir, searchPoints] = getNextPoint(searchPoints, x, dir, sX, sY, factor*d, MAXANGLE, MAXDIST2LINE, doshow);
%         end
%                         
%         %Get the angle
% %         theta = acos(dir'*dir0)/(norm(dir)*norm(dir0))/pi*180
% %         %Its a wrong one
% %         if(theta>MAXANGLE)
% %             disp('line is over')
% %             break;
% %         else
%             if(doshow)
%                 if(size(x,1)>1)
%                     plot(x(1), x(2), 'r+', 'MarkerSize',25)
%                 end
%             end            
% %         end
%         dir0 =dir;
% %         pause
%         %update stuff
%         sX = sX + dx;
%         sY = sY + dy;
%         cnt = cnt+1;
%     end    
%     
% 
%     
% function searchPoints = getFirstLine(searchPoints, x0, dir0, sX, sY, dx, dy, d0, factor, MAXANGLE, MAXDIST2LINE, doshow)
%     x = x0(1:2);
%     dir = dir0;
%     d = d0;
%     while(x(1)>0)
%         [x, d, dir, searchPoints] = getNextPoint(searchPoints, x, dir, sX, sY, factor*d, MAXANGLE, MAXDIST2LINE, doshow);
%         sX = sX + dx;
%         sY = sY + dy;
%     end
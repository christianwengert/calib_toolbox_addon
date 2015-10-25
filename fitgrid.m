%Once the image is processed using the gridextractor method, this function
%tries to fit the grid on the extraced points in order to establish the
%correspondences 
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
%This file uses some functions from Peter Kovesi's Matlab functions
%http://www.csse.uwa.edu.au/~pk/Research/MatlabFns/index.html
%
%Christian Wengert
%Computer Vision Laboratory
%ETH Zurich
%Sternwartstrasse 7
%CH-8092 Zurich
%www.vision.ee.ethz.ch/cwengert
%wengert@vision.ee.ethz.ch
function [success, x_, X_, searchPoints, error] = fitgrid(stats, searchPoints, id0, id1, dX, dY, show)
    
    %Grid small
    xmin = -12*dX;
    xmax = 12*dX;
    ymin = -12*dY;
    ymax = 12*dY;
    %Define a delta distance
    delta = 7; %[pixel]

    %Init
    x0 = [stats(id0).Centroid(1);stats(id0).Centroid(2)];
    x1 = [stats(id1).Centroid(1);stats(id1).Centroid(2)];
    dir = (x1-x0)/(norm(x1-x0));
    %Get a 90?angle
    dir90_ = [-dir(2);dir(1)];
    %get the orientation of main bar
    orientation = stats(id0).Orientation;   
    y = tand(orientation);   
    dir90 = [-1;y];
    dir90 = dir90/norm(dir90);
    
    %Compare direction of orientation with dir90_ and dir90
    sd90 = sign(dir90); sd90_  =sign(dir90_);
%     [dir90,dir90_]    
    if(abs(1-abs(dir90_(1)))<0.01 & sd90(1)~=sd90_(1))
        dir90 = -dir90;
    elseif(abs(1-abs(dir90_(2)))<0.01 & sd90(2)~=sd90_(2))
        dir90 = -dir90;
    elseif(~(sd90(1)==sd90_(1) |sd90(2)==sd90_(2)))
        dir90 = -dir90;
    end

    
    error = 0;
    %Draw the initial lines
    if(show)
        line([x0(1), x0(1)+dir(1)*100], [x0(2), x0(2)+dir(2)*100],'Color','r');
        line([x0(1), x0(1)-dir(1)*100], [x0(2), x0(2)-dir(2)*100],'Color','r');
        line([x0(1), x0(1)+dir90(1)*100], [x0(2), x0(2)+dir90(2)*100]);
        line([x0(1), x0(1)-dir90(1)*100], [x0(2), x0(2)-dir90(2)*100]);
    end
    deltaDist2Line = 10;
    try    
        %Create search Points
        a1 = x0+dir90*stats(id0).MajorAxisLength/2;
        a2 = x0-dir90*stats(id0).MajorAxisLength/2;
        b1 = x0-dir*stats(id1).MajorAxisLength/2;        
        b2 = x1+dir*stats(id1).MajorAxisLength/2;
        if(show)
            plot(a1(1),a1(2),'mo','MarkerSize',40,'LineWidth',2)
            plot(a2(1),a2(2),'bo','MarkerSize',40,'LineWidth',2)
            plot(b1(1),b1(2),'co','MarkerSize',40,'LineWidth',2)
            plot(b2(1),b2(2),'ro','MarkerSize',40,'LineWidth',2)
        end
        da1 = [];da2 = []; db1 = []; db2 = [];
        for i=1:length(searchPoints)
            da1 = [da1;norm(a1 - searchPoints(2:3,i))];
            da2 = [da2;norm(a2 - searchPoints(2:3,i))];
            db1 = [db1;norm(b1 - searchPoints(2:3,i))];
            db2 = [db2;norm(b2 - searchPoints(2:3,i))];
        end
        [da1,ia1] = sort(da1);
        [da2,ia2] = sort(da2);
        [db1,ib1] = sort(db1);
        [db2,ib2] = sort(db2);        
        ix0 = ia1(1);
        ix1 = ia2(1);
        iy(1) = ib1(1);
        iy(2) = ib2(1);
        
        
        %Show the points
        if(show)
            plot(searchPoints(2,ix0(1)),searchPoints(3,ix0(1)),'mx','MarkerSize',25,'LineWidth',2)
            plot(searchPoints(2,ix1(1)),searchPoints(3,ix1(1)),'bx','MarkerSize',25,'LineWidth',2)
            plot(searchPoints(2,iy(1)),searchPoints(3,iy(1)),'cx','MarkerSize',25,'LineWidth',2)
            plot(searchPoints(2,iy(2)),searchPoints(3,iy(2)),'rx','MarkerSize',25,'LineWidth',2)
        end
        %Refine the line
        dir = searchPoints(2:3,ix0(1)) - searchPoints(2:3,ix1(1));
        dir90 = searchPoints(2:3,iy(1)) - searchPoints(2:3,iy(2));
 
        %Make the initial grid
        [x,y] = meshgrid(xmin:dX:xmax, ymin:dY:ymax);
        x = reshape(x, 1, numel(x));
        y = reshape(y, 1, numel(y));
        xy = [x;y];
        usedPtsIndex = ones(1,length(x));
        %Get the homography
        %the points we have are: [pixels]        
        xy__ = [searchPoints(2:3,ix0(1)), searchPoints(2:3,ix1(1)),searchPoints(2:3,iy(1)),searchPoints(2:3,iy(2))];
        xy_  = [[0;-2*dX],[0;2*dX], [-dY;0],[3*dY;0]];
        %Compute H
        [H, err] = invpersp(xy__, xy_);
        xyp = homoTrans(H,[xy;ones(1,length(xy))]);
               
        %Distance check
        for i=1:length(searchPoints)
            for j=1:length(xyp)
                d = norm(searchPoints(2:3,i)-xyp(1:2,j));                
                error = error+d;
                %Check whether its good
                if(d<=delta)
                    
                    if(show)
                        text(searchPoints(2,i)+5,searchPoints(3,i)+5,[num2str(xy(1,j)) ',' num2str(xy(2,j))],'Color','b')
                        plot(searchPoints(2,i), searchPoints(3,i),'r+');
                    end
                    searchPoints(4:5,i) = xy(1:2,j);
                    %Update the point vectors that they have been assigned
                    searchPoints(1,i) = 0;
                    usedPtsIndex(j) = 0;
                end
            end
        end
        success  = 1;
        finalindex = find(searchPoints(1,:)==0);
        x_ = searchPoints(2:3,finalindex);
        X_ = [searchPoints(4:5,finalindex)];
        X_ = [X_;zeros(1,length(X_))];
        
        error = error/length(x_)/length(xyp);
    catch
        disp('fitgrid::Could not find extension points')
        success = 0;        
        x_ = []; X_ = [];
    end
    

    
    
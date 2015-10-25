    
%Simply returns the next point which is closest to the startpoint and as close as possible on the line    
function [x, dist, dir, searchPoints] = getNextPoint(searchPoints, x0, dir0, X, Y, MAXDIST, MAXANGLE, MAXDIST2LINE, doshow)

    %REturn values in case of its not working
    x = -1;
    dir = [0;0];
    dist = -1;
    %Returns the index of points which are close to the line
    [dl, ix_l,angles] = getClosestPointToLine(searchPoints, x0, dir0, 32);
    
    %for i=1:length(dl)
    %    dl(i)
    %end
    %Only take those points that are less than MAXPIXEL away from the line
    ix = find(dl < MAXDIST2LINE);
    ix_l = ix_l(ix);
    
    %Returns the index of points which are close to the start point   
    [ix_n, d] = getClosestNeighbours(searchPoints(:, ix_l), x0, 16); %x0 important

    %Make a new index with closest points that are close to the line!
    ix = ix_l(ix_n);
    if(numel(ix)>0)
        d = norm(searchPoints(2:3, ix(1))-x0); %x0 important
        if(d < MAXDIST)
            %Check that there ar epoints, otherwise return a zero value
            if(length(ix) > 0 )
                %Take the best match
                x = searchPoints(2:3,ix(1));
                %Recompute direction
                dir = x-x0(1:2);  %x0 faux
                dist = norm(dir);
                dir = dir/dist;
                %Get the angle
                theta = acos(dir'*dir0)/(norm(dir)*norm(dir0))/pi*180;

%                 if(theta<85 | theta>105)
                if(theta<MAXANGLE)
                    %Mark it as used and store the point correspondance
                    searchPoints(1,ix(1)) = 0;
                    searchPoints(4:5, ix(1)) = [X;Y];
                    if(doshow)
                        text(searchPoints(2,ix(1))+5,searchPoints(3,ix(1))+5,[num2str(searchPoints(4,ix(1))) ',' num2str(searchPoints(5,ix(1)))],'Color','m')
                    end
                else
                    x = -1;
                end                                                
            end       
        end
    end

    


        
    
    


%     
% %Simply returns the next point which is closest to the startpoint and as close as possible on the line    
% function [x, dist, dir, searchPoints] = getNextPoint(searchPoints, x0, dir0, X, Y, MAXDIST, MAXANGLE, MAXDIST2LINE, doshow)
% 
%     %REturn values in case of its not working
%     x = -1;
%     dir = [0;0];
%     dist = -1;
%     %Returns the index of points which are close to the line
%     [dl, ix_l,angles] = getClosestPointToLine(searchPoints, x0, dir0, 8);
%     %Only take those points that are less than MAXPIXEL away from the line
%     ix = find(dl < MAXDIST2LINE);
%     ix_l = ix_l(ix);
%     
%     %Returns the index of points which are close to the start point   
%     [ix_n, d] = getClosestNeighbours(searchPoints(:, ix_l), x0, 16);
% 
%     %Make a new index with closest points that are close to the line!
%     ix = ix_l(ix_n);
%     if(numel(ix)>0)
%         d = norm(searchPoints(2:3, ix(1))-x0);
%         if(d < MAXDIST)
%             %Check that there ar epoints, otherwise return a zero value
%             if(length(ix) > 0 )
%                 %Take the best match
%                 x = searchPoints(2:3,ix(1));
%                 %Recompute direction
%                 dir = x-x0(1:2);
%                 dist = norm(dir);
%                 dir = dir/dist;
%                 %Get the angle
%                 theta = acos(dir'*dir0)/(norm(dir)*norm(dir0))/pi*180;
% 
% %                 if(theta<85 | theta>105)
%                 if(theta<MAXANGLE)
%                     %Mark it as used and store the point correspondance
%                     searchPoints(1,ix(1)) = 0;
%                     searchPoints(4:5, ix(1)) = [X;Y];
%                     if(doshow)
%                         text(searchPoints(2,ix(1))+5,searchPoints(3,ix(1))+5,[num2str(searchPoints(4,ix(1))) ',' num2str(searchPoints(5,ix(1)))],'Color','m')
%                     end
%                 else
%                     x = -1;
%                 end                                                
%             end       
%         end
%     end
% 
%     
% 
% 
%         
%     
%     
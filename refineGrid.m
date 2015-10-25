function refineGrid(im, success, stats, cnt, id0, id1, searchPoints)

    %Refine with a bigger grid
    xymin = -30;
    xystep = 2;
    xymax = 30;
    %Define a delta distance
    delta = 7; %[pixel]
    [x,y] = meshgrid([xymin:xystep:xymax]);
    x = reshape(x, 1, numel(x));
    y = reshape(y, 1, numel(y));
    xy = [x;y];
    usedPtsIndex = ones(1,length(x));

    %Go through the points
    [H, err] = invpersp(searchPoints(2:3,:), searchPoints(4:5,:));
    xyp = homoTrans(H,[xy;ones(1,length(xy))]);
    plot(xyp(1,:),xyp(2,:),'r+')
           
    
    
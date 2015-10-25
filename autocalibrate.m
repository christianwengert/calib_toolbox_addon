%Autocalibration. 
%
%This add on allows to compute the hand to eye calibration based ont he
%calibration toolbox from Jean-Yves Bouguet
%see http://www.vision.caltech.edu/bouguetj/calib_doc/
%more information can be found here:
%http://www.vision.ee.ethz.ch/~cwengert/calibration_toolbox.php
%
%It performs the calibration 100% automatically, but uses a different
%pattern for calibration which can be found here:
%http://www.vision.ee.ethz.ch/~cwengert/calibration_toolbox.php
%
%See also "Fully Automatic Endoscope Calibration for Intraoperative Use,
%Wengert C., Reeff M., Cattin P., Szekely G."
%
%You can set up some variables to change the behavior of the code:
%doShow	[default=0]
%Set doShow = 1 if you want to see what the calibration is doing
%doRefineGrid [default = 0]
%Set doRefineGrid = 1 if the grid should be refined after detection 
%(does not really change much)
%isStronglyDistorted [default = 0]
%Set isStronglyDistorted = 1, if your images show severe distortion, such 
%as from an endoscope or extremely wide optics
%doIterateCalibration [default = 1]
%Set doIterateCalibration = 1, if you want the system to give the best 
%results. This will try to detect wrong correspondences and calibrate 
%again, set to 0 if you dont want to use this feature.
%
%Christian Wengert
%Computer Vision Laboratory
%ETH Zurich
%Sternwartstrasse 7
%CH-8092 Zurich
%www.vision.ee.ethz.ch/cwengert
%wengert@vision.ee.ethz.ch

%Needed for the gridextractor, depending on your images, change this
minArea =15;maxArea = 14000;    
%maximum backprojkection error
MAX_ERROR = 4000;

%With the doShow flag you can show the results
if(~exist('doShow')) 
    doShow = 0;
end

if(~exist('dX_default'))     
	dX_default = 2;
end

if(~exist('dY_default'))     
	dY_default = 2;
end

if(~exist('dX'))     
    dX = dX_default;
end
if(~exist('dY'))     
    dY = dY_default;
end

   

%Give best accuracy
if(~exist('doIterateCalibration'))
    doIterateCalibration =0;
end
%Check the flag for refining the grid
if(~exist('doRefineGrid')) 
    doRefineGrid = 0;
end
%Set it to zero anyway, it is not yet ready!
doRefineGrid = 0;

%Check the distortion flag
if(~exist('isStronglyDistorted'))
    isStronglyDistorted = 0;
end

%Check whether we have images
if(n_ima<=0)
    disp(['autocalibrate:: No images available']);
    return
end
    %CORNER EXTRACTION PART
    active_images = zeros(1,n_ima);
    for i=1:n_ima
        disp(['autocalibrate:: Processing image ' num2str(i)]);
        %Needs to be done for toolbox
        eval(['x_' num2str(i) ' = NaN*ones(2,1);']);
        eval(['X_' num2str(i) ' = NaN*ones(3,1);']);
        eval(['im = I_' num2str(i) ';'])
        if(doShow)  %Show if necessary
            figure;hold on;title(['Image ' num2str(i)]);
        end
        %Extract the grid points
        [success, stats, cnt, id0, id1, searchPoints] = gridextractor(im, doShow, minArea, maxArea);

        %Sometimes if we can find the two main marks, we dont process this
        %image
        if(success & cnt==2 & length(stats)>0)
            %Fit the grid
            if(isStronglyDistorted)
                [success, x_, X_, searchPoints] = fitgridDistorted(stats, searchPoints, id0, id1, dX, dY, doShow);
            else
                [success, x_, X_, searchPoints, err] = fitgrid(stats, searchPoints, id0, id1, dX, dY, doShow);
            end
            %Grid was fitted succesfully
            if(success)
                %Refine grid if wanted
                if(doRefineGrid)
                    refineGrid(im, success, stats, cnt, id0, id1, searchPoints);
                end
                %Update calib toollbox 
                active_images(i) = i;
                eval(['X_' num2str(i) '=X_;']);
                eval(['x_' num2str(i) '=x_;']);
                
                %Check for error
                if(exist('err')==1)                    
                    if(err>MAX_ERROR)
                        active_images(i) = 0;
                        disp(['autocalibrate:: Image ' num2str(i) ' has rather huge gridprojection error. Setting it to inactive.']);
                    end
                end
            end
        else
            disp(['autocalibrate:: Not enough image information in image ' num2str(i) '. Setting it to inactive.']);
        end
    end
    %Make a backup
    old_active_images = active_images;
    %NOW WE START THE CAMERA CALIBRATION
    %Do this for calibtoolbox compatibility
    [ny,nx,bpp] = size(im);    
    center_optim=1;
    est_aspect_ratio = 1;
    est_alpha=0;
    est_dist = [1 1 1 1 0]';
    init_intrinsic_param;
    %Calibrate camera
    try
        while(~exist('err_std'))
            go_calib_optim_iter;
        end
    catch
        disp(['autocalibrate:: Could not calibrate']);
        s = lasterror;
        disp(['autocalibrate:: ' s.message ' in function ' s.stack.name ' in ' s.stack.file ' @line ' num2str(s.stack.line)])
    end
    
    
    if(doIterateCalibration)
        %Improve
        maxIter=10;
        iter=0;

        %Max Error to eliminate points which have a backprojectionerror bigger than
        %that
        BP_ERROR = 1.5;
        while(norm(err_std)>0.5 & iter<maxIter)
            for i=active_images             
                if(i>0)
                    eval(['error = ex_' num2str(i) ';']);
                    ix=find(error(1,:)>BP_ERROR);
                    iy=find(error(2,:)>BP_ERROR);
                    ixx = union(ix,iy);
                    eval(['x_' num2str(i) '(:,ixx) = [];']);
                    eval(['X_' num2str(i) '(:,ixx) = [];']);
                end

            end
            go_calib_optim_iter;
           iter=iter+1; 
        end
    end
  
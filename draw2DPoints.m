%Simply draws / plots the points in 2D
%
%Author:    Christian Wengert, 
%           Institute of Computer Vision
%           Swiss Federale Institute of Technology, Zurich (ETHZ)
%           wengert@vision.ee.ethz.ch
%           www.vision.ee.ethz.ch/~cwengert/
%
%Input:     x           The 2D points to draw
%           name        Specifiy a title for your plot
%           numbers     1 if you want to have the point numbers on the plot, 0 otherwise (default)
%           handle      A handle to a figure
%
%Syntax:    draw3DPoints(x, name, numbers, handle)

function draw2DPoints(x, name, numbers, handle, color)
        if (nargin<1 | nargin>5)
            error('draw2DPoints::Syntax:    draw2DPoints(X, name, numbers, handle,color)');
        end
        %Check for default
        if(nargin<5)
            color = 'r+';
            if(nargin<=4)
                figure(handle)
                if(nargin<3)
                    numbers=0;
                    if(nargin<2)
                        name = '';
                    end
                end
            end
        end
        
%         plot(x(1,1),x(2,1),'kd'), hold on
        plot(x(1,1),x(2,1),color), hold on
        plot(x(1,2:end),x(2,2:end),color), grid on, title('3D'),axis on,xlabel('x'),ylabel('y')
        
        grid on
        title(name)
        xlabel('x')
        ylabel('y')
        
        %Draw point numbers
        if(numbers)
            hold on
            drawPointNumbers(x)
            hold off
        end
        
        

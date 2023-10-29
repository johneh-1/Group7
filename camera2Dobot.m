classdef camera2Dobot < handle
    % CAMERA2DOBOT Convert from camera coordinate frame to DoBot frame
    % Class containing calculation functions.
    
    properties (Constant)
        % Properties of camera (Intel RealSense D435i, mounted 330mm above
        % desk)
        cameraVertOffset = 0.325;                                           % Mounted 325mm (0.325m) above desk
        cameraXOffset = 0.130;                                              % Mounted 130mm (0.130m) along x-axis of DoBot frame
        cameraYOffset = -0.215;                                             % Mounted 200mm (0.200m) along y-axis of DoBot frame

        % Properties of DoBot
        doBotVertOffset = -0.0693;                                          % End of suction end effector sits 69.3mm (0.0693m) below DoBot vertical 0 when flat on desk

        % Camera intrinsic properties (from calibration)
        pX = 0;                                                             % Principal point offset (x)
        pY = 0;                                                             % Principal point offset (y)
        f = 0;                                                              % Focal length

    end

    properties (Access = public)
        % Allocate and array of points for /clicked_point
        % point = [];
    end
    
    methods
        function self = camera2Dobot()
            % CAMERA2DOBOT Define all functions required in the class
            % self.GetCameraPoint(point);
            self.PixelToDistance(u,v,z);
            self.Convert(x,y,z);
        end
    end

    methods (Static) 
        % function [xC,yC,zC] = GetCameraPoint(point)
        %     % GETCAMERAPOINT Function to get the coordinates of a point in
        %     % the camera's frame
        %     % Points are either determined via subscription to a ROS topic
        %     % that outputs the coordinates of a point clicked in the
        %     % environment OR via a centrepoint output by an object
        %     % detection function
        %     % Parameters:
        %         % [IN] type = (1) clicked point OR (2) detected object
        %         % [OUT] xC = x-coordinate in camera's frame
        %         % [OUT] yC = y-coordinate in camera's frame
        %         % [OUT] zC = z-coordinate in camera's frame
        % 
        %     switch type
        %         case 1
        %             % Clicked point
        %             % Subscribe to /clicked_point topic
        %             pointSub = rossubscriber('/clicked_point');
        % 
        %             % Extract values from topic
        %             point = pointSub.LatestMessage.Point;
        %             xC = point.X;
        %             yC = point.Y;
        %             zC = point.Z;
        % 
        %             % pointSub = rossubscriber('/clicked_point',camera2Dobot.pointCallback);
        %         case 2
        %             % Detected object
        %             % Get object coordinates
        %             objects = imageProcessing.ObjectRecognition(img);
        %     end
        % end

        function [x,y] = PixelToDistance(u,v,f)
            % PIXELTODISTANCE
            % Note @Brayden, access properties via
               u =  camera2Dobot.px;
               v = camera2Dobot.py;
               f = camera2Dobot.f;

               x = (u - principalPoint(1)) * z / f;
                
               y = (v - principalPoint(2)) * z / f;     
        end

        function [xD,yD,zD] = Convert(xC,yC,zC)
            % CONVERT Function to convert from camera's frame to DoBot's
            % frame (Cartesian)
            % Points sourced from the camera are taken in and converted to
            % the DoBot's Cartesian frame. Ground truthing has been
            % undertaken to confirm relationship between coordinate frames.
            % @NOTE: DoBot calculation is calibrated for the suction end
            % effector attachment
            % Parameters:
                % [IN] xC = x-coordinate in camera's frame
                % [IN] yC = y-coordinate in camera's frame
                % [IN] zC = z-coordinate in camera's frame
                % [OUT] xD = x-coordinate in DoBot's frame
                % [OUT] yD = y-coordinate in DoBot's frame
                % [OUT] zD = z-coordinate in DoBot's frame

           % Convert to get x-coordinate
           xD = (zC) + camera2Dobot.cameraXOffset;

           % Convert to get y-coordinate
           yD = -1*((yC) + camera2Dobot.cameraYOffset);

           % Convert to get z-coordinate
           zD = (xC) + camera2Dobot.cameraVertOffset + camera2Dobot.eeLength;
        end
    end
end


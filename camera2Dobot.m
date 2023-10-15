classdef camera2Dobot < handle
    % CAMERA2DOBOT Convert from camera coordinate frame to DoBot
    %   Detailed explanation goes here
    
    properties (Constant)
        % Properties of camera (Intel RealSense D435i, mounted 330mm above
        % desk)
        cameraVertOffset = 0.330;                                           % Mounted 330mm (0.330m) above desk
        cameraXOffset = 0;                                                  % Mounted on y-axis of DoBot frame
        cameraYOffset = -0.200;                                             % Mounted 200mm (0.200m) along y-axis of DoBot frame
        % Horizontal FOV
        % Vertical FOV

        % Properties of DoBot
        doBotVertOffset = -0.0693;                                          % End off suction end effector sits 69.3mm (0.0693m) below DoBot vertical 0 when flat on desk

    end

    properties
        % Other properties
    end
    
    methods
        function self = camera2Dobot()
            % CAMERA2DOBOT Define all functions required in the class
            %   Detailed explanation goes here
            self.GetCameraPoint(type);
            self.Convert(type);
        end
    end

    methods (Static) 
        function [xC,yC,zC] = GetCameraPoint(type)
            % GETCAMERAPOINT Function to get the coordinates of a point in
            % the camera's frame
            % Points are either determined via subscription to a ROS topic
            % that outputs the coordinates of a point clicked in the
            % environment OR via a centrepoint output by an object
            % detection function
            % Parameters:
                % [IN] type = (1) clicked point OR (2) detected object
                % [OUT] xC = x-coordinate in camera's frame
                % [OUT] yC = y-coordinate in camera's frame
                % [OUT] zC = z-coordinate in camera's frame
            
            switch type
                case 1
                    % Clicked point
                    % Subscribe to /clicked_point topic
                    
                    % Extract values from topic
                case 2
                    % Detected object
                    % Get object coordinates
                        % From function developed by Alex
            end
        end

        function [xD,yD,zD] = Convert(type)
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

           % Get the point in the camera's frame
           [xC,yC,zC] = GetCameraPoint(type);

           % Convert to get x-coordinate
           xD = zC + camera2Dobot.cameraXOffset;

           % Convert to get y-coordinate
           yD = yC + camera2Dobot.cameraYOffset;

           % Convert to get z-coordinate
           zD = xC + camera2Dobot.cameraVertOffset;
        end
    end
end

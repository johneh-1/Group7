classdef imageProcessing < handle
    % IMAGEPROCESSING Image processing class for analysis
    % Processing of images received from RGB-D sensor

    properties (Constant)
        triangleSide = 0;
        triangleTolerance = 0;

        squareSide = 0;
        squareTolerance = 0;

        side = 0;
        sideTolerance = 0;

        divide = 0;
    end
    
    methods
        function self = imageProcessing()
            % IMAGEPROCESSING Define all functions for the class
            self.ObjectRecognition(img);
            self.TwoObjects(img);
            self.DetectCube(img);
            self.MatchFeatures(img,reference);
            self.CalcTransform(matchedPoints,matchedPointsReference);
        end
    end
    methods (Static)
        % % function objects = ObjectRecognition(img)
        % %     % OBJECTRECOGNITION Description
        % %     % Parameters:
        % %         % [IN] img = grayscale image
        % %         % [OUT] objects = array of objects
        % %     img = imread("workspaceSampleImage.jpg");
        % %     img = rgb2gray(img);
        % %     points = detectHarrisFeatures(img,"MinQuality",0.01);
        % % 
        % %     % Value that seperates reference image from whole (current) image
        % %     n = 370;
        % % 
        % %     type = input('reference, current ', 's');
        % % 
        % %     switch type
        % %         case 'reference'
        % %             points = points.Location;
        % %         case 'current'
        % %             points = points.Location;
        % %             points(points(:, 1) < n, :) = [];
        % %         otherwise
        % %             printf('Error: what image is this?')
        % %     end
        % % 
        % %     % Determine shapes by finding points close to each other
        % %     % Number of points
        % %     numPoints = size(points, 1);
        % % 
        % %     % Value that sets distance between each point
        % %     d = 50;
        % % 
        % %     for shape = square, rectangle, diamond, triangle
        % %         switch shape
        % %             case square
        % %                 % Iterate through the points and calculate distances
        % %                 for i = 1:numPoints
        % %                     for j = i+1:numPoints
        % %                         % Calculate the Euclidean distance between point i and point j
        % %                         distance = norm(points(i, :) - points(j, :));
        % %                     end
        % %                 end
        % %                if distance < d 
        % %                    points_of_shape = []
        % %                    points_of_shape.append([x,y]) 
        % %                end
        % %                polyin = polyshape(points_of_shape);
        % %                 end
        % % 
        % %             case rectangle
        % %                 for [x,y] = stored_points
        % %                        distance = [x+1,y+1] - [x,y]
        % %                        if distance < m
        % %                            points_of_shape = []
        % %                            points_of_shape.append([x,y]) 
        % %                        end
        % %                        polyin = polyshape(points_of_shape);
        % %                 end
        % % 
        % %             case diamond
        % %                 for [x,y] = stored_points
        % %                        distance = [x+1,y+1] - [x,y]
        % %                        if distance < m
        % %                            points_of_shape = []
        % %                            points_of_shape.append([x,y]) 
        % %                        end
        % %                        polyin = polyshape(points_of_shape);
        % %                 end
        % % 
        % %             case triangle
        % %                 for [x,y] = stored_points
        % %                        distance = [x+1,y+1] - [x,y]
        % %                        if distance < m
        % %                            points_of_shape = []
        % %                            points_of_shape.append([x,y]) 
        % %                        end
        % %                        polyin = polyshape(points_of_shape);
        % %                 end
        % % 
        % %             % ignore circle for now
        % %             % case circle
        % %             %     for [x,y] = stored_points
        % %             %            distance = [x+1,y+1] - [x,y]
        % %             %            if distance < m
        % %             %                points_of_shape = []
        % %             %                points_of_shape.append([x,y]) 
        % %             %            end
        % %             %            polyin = polyshape(points_of_shape);
        % %             %     end
        % % 
        % %             otherwise
        % %                 printf("This ain't a shape!");
        % %         end
        % %     end
        % % 
        % %     objects = [];
        % % 
        % %     % Deterine centre point of shape
        % %     for centre = shape             
        % %         [x,y] = centroid(polyin);
        % %         objects.append([x,y]);
        % %     end
        % % 
        % %     objects;
        % % end

        function objects = TwoObjects(img)
            % TWOOBJECTS Description
            % Parameters:
                % [IN] img = grayscale image
                % [OUT] objects = array of objects
            
            % Extract corners using Harris Features
            corners = detectHarrisFeatures(img,"MinQuality",0.08);

            % Allocate space for sides
            sides = [];

            % Identify objects based on corners and store
            for i = 1:size(corners.Count)-1
                % Calculate distance between points
                deltaX0 = corners.Location(i,1);
                deltaX1 = corners.Location(i+1,1);
                deltaY0 = corners.Location(i,2);
                deltaY1 = corners.Location(i+1,2);
                
                deltaX = deltaX1 - deltaX0;
                deltaY = deltaY1 - deltaY0;

                delta = sqrt(deltaX^2 + deltaY^2);
                
                % Check if a side is detected and store index
                if delta > imageProcessing.side - imageProcessing.sideTolerance && delta < imageProcessing.side + imageProcessing.sideTolerance
                    sides(end+1) = i;
                end
            end

            % Allocate space for 2 shapes to be detected
            rectangle = [];                                                 % Rectangle on LHS of divide
            triangle = [];                                                  % Triangle on RHS of divide

            for i = 1:size(sides)-1
                if corners.Location(sides(i),1) < imageProcessing.divide
                    rectangle(end+1) = sides(i);
                elseif corners.Location(sides(i),1) > imageProcessing.divide
                    triangle(end+1) = sides(i);
                end
            end

            % Calculate centroid of rectangle
            rectangleX = [];
            rectangleY = [];
            for i = 1:size(rectangle)
                rectangleX(end+1) = corners.Location(i,1);
                rectangleY(end+1) = corners.Location(i,2);
            end

            rectangleU = sum(rectangleX)/size(rectangleX);
            rectangleV = sum(rectangleY)/size(rectangleY);

            % Calculate centroid of triangle
            triangleX = [];
            triangleY = [];
            for i = 1:size(rectangle)
                triangleX(end+1) = corners.Location(i,1);
                triangleY(end+1) = corners.Location(i,2);
            end

            triangleU = sum(triangleX)/size(triangleX);
            triangleV = sum(triangleY)/size(triangleY);

            % Allocate objects as a 2x2 matrix
                % Row 1: Coordinates of triangle
                % Row 2: Coordinates of square
            objects = [rectangleU,rectangleV;triangleU,triangleV];

            % % % Extract sides into shapes
            % % for i = 1:size(sides)-1
            % %     % Calculate distance between points
            % %     deltaX0 = corners.Location(sides(i),1);
            % %     deltaX1 = corners.Location(sides(i+1),1);
            % %     deltaY0 = corners.Location(sides(i),2);
            % %     deltaY1 = corners.Location(sides(i+1),2);
            % % 
            % %     deltaX = deltaX1 - deltaX0;
            % %     deltaY = deltaY1 - deltaY0;
            % % 
            % %     delta = sqrt(deltaX^2 + deltaY^2);
            % % 
            % %     % Check if a side is NOT from the same shape
            % %     if delta > imageProcessing.side + imageProcessing.sideTolerance
            % % 
            % %     else
            % %         shape1(end+1) = i;
            % %     end
            % % end
        end

        function objects = DetectCube(img)
            % TWOOBJECTS Description
            % Parameters:
                % [IN] img = grayscale image
                % [OUT] objects = array of objects

            divideX = 280;
            divideY = 230;
            
            % Extract corners using Harris Features
            corners = detectHarrisFeatures(img,"MinQuality",0.07);

            rectangle = [];                                                 % Rectangle on LHS of divide
            target = [];

            for i = 1:size(corners.Location,1)
                if corners.Location(i,1) > divideX && corners.Location(i,2) > divideY
                    rectangle(end+1) = i;
                end
                if corners.Location(i,1) > divideX && corners.Location(i,2) < divideY
                    target(end+1) = i;
                end
            end

            rectangleX = [];
            rectangleY = [];

            for i = 1:size(rectangle,2)
                rectangleX(end+1) = corners.Location(rectangle(i),1)
                rectangleY(end+1) = corners.Location(rectangle(i),2)
            end

            rectangleU = sum(rectangleX)/size(rectangleX,2)
            rectangleV = sum(rectangleY)/size(rectangleY,2);

            targetX = [];
            targetY = [];

            for i = 1:size(target,2)
                targetX(end+1) = corners.Location(target(i),1)
                targetY(end+1) = corners.Location(target(i),2)
            end

            targetU = sum(targetX)/size(targetX,2);
            targetV = sum(targetY)/size(targetY,2);

            objects = [rectangleU,rectangleV,targetU,targetV];

        end

        function [matchedPoints,matchedPointsReference] = MatchFeatures(img,reference)
            % MATCHFEATURES Feature matching function using SURF algorithm
            % Parameters:
                % [IN] img = current image
                % [IN] reference = reference image
                % [OUT] matchedPoints = matched points in current image
                % [OUT] matchePointsReference = matched points in reference
            
            % Use SURF algorithm to detect features and store
            points = detectSURFFeatures(img);
            pointsRef = detectSURFFeatures(reference);

            % Extract features
            [features1, validPoints1] = extractFeatures(img,points);
            [features2, validPoints2] = extractFeatures(reference,pointsRef);

            % Index pairs
            indexPairs = matchFeatures(features1,features2);

            % Store matched points based on the index
            matchedPoints = validPoints1(indexPairs(:,1));
            matchedPointsReference = validPoints2(indexPairs(:,2));
        end

        function theta = CalcTransform(matchedPoints,matchedPointsReference)

            [tform,inlier,inlierReference] = estimateGeometricTransform(matchedPoints,matchedPointsReference,'similarity');

            Tinv = tform.invert.T;
            ss = Tinv(2,1);
            sc = Tinv(1,1);
            scale = sqrt(ss*ss + sc*sc);
            theta = atan2(ss,sc)*180/pi;

            % NOTE: ThetaRecovered is the rotation between images. This is
            % what ultimately needs to be input to the end effector pose

            % @TODO: Check status output by estimateGeo function
                % If status = 0, no error. 1, not enough points. 2, not
                % enough inliers have been found
        end
    end
end


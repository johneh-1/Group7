classdef imageProcessing < handle
    % IMAGEPROCESSING Image processing class for analysis
    % Processing of images received from RGB-D sensor
    
    methods
        function self = imageProcessing()
            % IMAGEPROCESSING Define all functions for the class
            self.ObjectRecognition(img);
            self.MatchFeatures(img,reference);
            self.CalcTransform(matchedPoints,matchedPointsReference);
        end
    end
    methods (Static)
        function objects = ObjectRecognition(img)
            % OBJECTRECOGNITION Description
            % Parameters:
                % [IN] img = grayscale image
                % [OUT] objects = array of objects
            img = imread("workspaceSampleImage.jpg");
            img = rgb2gray(img);
            points = detectHarrisFeatures(img,"MinQuality",0.01);

            % Value that seperates reference image from whole (current) image
            n = 370;

            type = input('reference, current ', 's');

            switch type
                case 'reference'
                    points = points.Location;
                case 'current'
                    points = points.Location;
                    points(points(:, 1) < n, :) = [];
                otherwise
                    printf('Error: what image is this?')
            end
            
            % Determine shapes by finding points close to each other
            % Number of points
            numPoints = size(points, 1);

            % Value that sets distance between each point
            d = 50;

            for shape = square, rectangle, diamond, triangle
                switch shape
                    case square
                        % Iterate through the points and calculate distances
                        for i = 1:numPoints
                            for j = i+1:numPoints
                                % Calculate the Euclidean distance between point i and point j
                                distance = norm(points(i, :) - points(j, :));
                            end
                        end
                       if distance < d 
                           points_of_shape = []
                           points_of_shape.append([x,y]) 
                       end
                       polyin = polyshape(points_of_shape);
                        end
    
                    case rectangle
                        for [x,y] = stored_points
                               distance = [x+1,y+1] - [x,y]
                               if distance < m
                                   points_of_shape = []
                                   points_of_shape.append([x,y]) 
                               end
                               polyin = polyshape(points_of_shape);
                        end
    
                    case diamond
                        for [x,y] = stored_points
                               distance = [x+1,y+1] - [x,y]
                               if distance < m
                                   points_of_shape = []
                                   points_of_shape.append([x,y]) 
                               end
                               polyin = polyshape(points_of_shape);
                        end
    
                    case triangle
                        for [x,y] = stored_points
                               distance = [x+1,y+1] - [x,y]
                               if distance < m
                                   points_of_shape = []
                                   points_of_shape.append([x,y]) 
                               end
                               polyin = polyshape(points_of_shape);
                        end
    
                    % ignore circle for now
                    % case circle
                    %     for [x,y] = stored_points
                    %            distance = [x+1,y+1] - [x,y]
                    %            if distance < m
                    %                points_of_shape = []
                    %                points_of_shape.append([x,y]) 
                    %            end
                    %            polyin = polyshape(points_of_shape);
                    %     end
    
                    otherwise
                        printf("This ain't a shape!");
                end
            end

            objects = [];

            % Deterine centre point of shape
            for centre = shape             
                [x,y] = centroid(polyin);
                objects.append([x,y]);
            end

            objects;
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


classdef imageProcessing < handle
    %IMAGEPROCESSING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        % Property1
    end
    
    methods
        function self = imageProcessing()
            %IMAGEPROCESSING Construct an instance of this class
            %   Detailed explanation goes here
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
            % From Alex
            objects = [];
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


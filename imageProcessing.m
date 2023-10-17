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
            self.ObjectRecognition();
            self.CalcTransform();
        end
    end
    methods (Static)
        function ObjectRecognition()
            % From Alex
        end

        function CalcTransform(matchedPoints,matchedPointsReference)

            [tform,inlier,inlierReference] = estimateGeometricTransform(matchedPoints,matchedPointsReference,'similarity');

            Tinv = tform.invert.T;
            ss = Tinv(2,1);
            sc = Tinv(1,1);
            scaleRecovered = sqrt(ss*ss + sc*sc)
            thetaRecovered = atan2(ss,sc)*180/pi

            % NOTE: ThetaRecovered is the rotation between images. This is
            % what ultimately needs to be input to the end effector pose

            % @TODO: Check status output by estimateGeo function
                % If status = 0, no error. 1, not enough points. 2, not
                % enough inliers have been found
        end
    end
end


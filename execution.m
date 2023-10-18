%% Script for execution
% This script for execution controls the pick and place movement of the
% DoBot Magician, guided by the Intel RealSense D435i.
    % @NOTE: Camera calibration is separate to this script and is a
    % requirement to be undertaken prior to running this script.
%% Initialisation
% Initialise ROS
rosinit;

% Launch DoBot driver through terminal
    % roslaunch dobot_magician_driver dobot_magician.launch

% Launch RealSense driver through terminal
    % roslaunch realsense2_camera rs_rgbd.launch

% Initialise subscribers
    % @NOTE: Other specific subscribers are initialised within functions
rgbSub = rossubscriber('/camera/color/image_raw');                          % RGB stream subscriber
pointsSub = rossubscriber('/camera/depth_registered/points');               % Depth points stream subscriber
%% Detect targets in box within initial environment state
% Load current RGB image and store as the reference
reference = readImage(rgbSub.LatestMessage);
reference = rgb2gray(reference);

% Store recognised objects from the box
    % @NOTE: 
    % Object 1 = square
    % Object 2 = rectangle
    % Object 3 = diamond
    % Object 4 = triangle
    % Object 5 = circle
targets = imageProcessing.ObjectRecognition(reference);

% User to randomly place pieces in environment
fprintf('Please place the pieces\n');
fprintf('Press enter to continue\n');
pause
%% Detect pieces in environment
% Get current RGB image
image = readImage(rgbSub.LatestMessage);
image = rgb2gray(image);

% Store recognised objects
objects = imageProcessing.ObjectRecognition(image);
%% Pick and place objects
% Iterate through objects
for i=1:size(targets,1)
    % Get current RGB image
    img = readImage(rgbSub.LatestMessage);
    img = rgb2gray(img);

    % Calculate the rotation transform
    [matchedPoints,matchedPointsReference] = imageProcessing.MatchFeatures(img,reference);
    theta = imageProcessing.CalcTransform(matchedPoints,matchedPointsReference);

    % Identify the starting location of the piece
    [xC,yC] = objects(i,:);
    pointMsg = pointsSub.LatestMessage;
    pointMsg.PreserveStructureOnRead = true;
    depthPoints = readXYZ(pointMsg);
    zPoints = depthPoints(:,:,3);
    z = zPoints(320,:);
    sumZ = sum(z);
    sizeZ = size(z,2);
    zC = sumZ/sizeZ;
    [xD,yD,zD] = Convert(xC,yC,zC);

    % Move and collect piece
    DoBotControl.MoveCart(xD,yD,zD+0.025,0,0,0);
    pause(1);
    DoBotControl.MoveCart(xD,yD,zD,0,0,0);
    pause(1);
    EndEffectorControl.On();
    pause(1);

    % Move to target for piece
    
end
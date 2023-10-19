%% Script for execution
% This script for execution controls the pick and place movement of the
% DoBot Magician, guided by the Intel RealSense D435i.
    % @NOTE: Camera calibration is separate to this script and is a
    % requirement to be undertaken prior to running this script.
%% Initialisation
% Initialise ROS
% rosinit;

% Launch DoBot driver through terminal
    % roslaunch dobot_magician_driver dobot_magician.launch

% Launch RealSense driver through terminal
    % roslaunch realsense2_camera rs_rgbd.launch

% Initialise subscribers
    % @NOTE: Other specific subscribers are initialised within functions
rgbSub = rossubscriber('/camera/color/image_raw');                          % RGB stream subscriber
pointsSub = rossubscriber('/camera/depth_registered/points');               % Depth points stream subscriber

% Define point on top of target box, in camera's frame
boxX = 0;
boxY = 0;

% Move DoBot to side of workspace
DoBotControl.MoveCart(0.15,0,0,0,0,0);
%% Detect targets in box within initial environment state
% Load current RGB image and store as the reference
reference = readImage(rgbSub.LatestMessage);
reference = rgb2gray(reference);
if isempty(reference)
    fprintf('Reference image failed to load! Terminating\n');
    return
else
    fprintf('Reference image loaded\n');
end

% Store recognised objects from the box
    % @NOTE: 
    % Object 1 = square
    % Object 2 = rectangle
    % Object 3 = diamond
    % Object 4 = triangle
    % Object 5 = circle
targets = imageProcessing.ObjectRecognition(reference);
fprintf('%d targets loaded!\n',size(targets,1));

% User to randomly place pieces in environment
fprintf('Please place the pieces\n');
pause(1);
fprintf('Press enter to continue\n');
pause
%% Detect pieces in environment
% Get current RGB image
image = readImage(rgbSub.LatestMessage);
image = rgb2gray(image);
if isempty(image)
    fprintf('Piece detection image failed to load! Terminating\n');
    return
else
    fprintf('Piece detection image loaded\n');
end

% Store recognised objects
objects = imageProcessing.ObjectRecognition(image);
fprintf('%d objects loaded!\n',size(objects,1));
%% Pick and place objects
% Iterate through objects
for i=1:size(objects,1)
    % Get current RGB image
    img = readImage(rgbSub.LatestMessage);
    img = rgb2gray(img);

    % Calculate the rotation transform
    [matchedPoints,matchedPointsReference] = imageProcessing.MatchFeatures(img,reference);
    theta = imageProcessing.CalcTransform(matchedPoints,matchedPointsReference);

    % Identify the starting location of the piece
    [xC,yC] = objects(i,:);
    % Brayden's conversion function for xC,yC into distances
    pointMsg = pointsSub.LatestMessage;
    pointMsg.PreserveStructureOnRead = true;
    depthPoints = readXYZ(pointMsg);
    zPoints = depthPoints(:,:,3);
    z = zPoints(320,:);
    sumZ = sum(z);
    sizeZ = size(z,2);
    zC = sumZ/sizeZ;
    [xD,yD,zD] = camera2Dobot.Convert(xC,yC,zC);

    % Move and collect piece
    DoBotControl.MoveCart(xD,yD,zD+0.025,0,0,0);
    pause(1);
    DoBotControl.MoveCart(xD,yD,zD,0,0,0);
    pause(1);
    EndEffectorControl.On();
    pause(1);
        % Get joint state
    [base,rearArm,foreArm,ee] = DoBotControl.GetJointState();
    pause(1);
    DoBotControl.MoveCart(xD,yD,zD+0.025,0,0,0);
    pause(1);

    % Identify the target location of the piece
    [xCT,yCT] = targets(i,:);
    % Brayden's conversion function for xC,yC into distances
    pointMsgT = pointsSub.LatestMessage;
    pointMsgT.PreserveStructureOnRead = true;
    depthPointsT = readXYZ(pointMsgT);
    zPointsT = depthPointsT(:,:,3);
    zCT = zPointsT(boxX,boxY);
    % sumZT = sum(zT);
    % sizeZT = size(zT,2);
    % zCT = sumZT/sizeZT;
    [xDT,yDT,zDT] = camera2Dobot.Convert(xCT,yCT,zCT);

    % Move and deposit piece
        % Move to 25mm above target
    DoBotControl.MoveCart(xDT,yDT,zDT+0.025,0,0,0);
    pause(1);
        % Calculate alignment of piece
    eeT = DoBotControl.CalcEEReqRot([xD,yD,zD],[base,rearArm,foreArm,ee],[xDT,yDT,zDT],theta);
    [base,rearArm,foreArm,ee] = DoBotControl.GetJointState();
    pause(1);
        % Rotate end effector to align piece to target
    DoBotControl.RotateEndEffector(base,rearArm,foreArm,eeT);
    pause(1);
        % Place piece
    DoBotControl.MoveCart(xD,yD,zD,0,0,0);
    pause(1);
    EndEffectorControl.Off();
    pause(1);
        % Move to 25mm above target
    DoBotControl.MoveCart(xD,yD,zD+0.025,0,0,0);
    pause(1);
end
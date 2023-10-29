%% Script for demonstration execution
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

% Move DoBot to side of workspace
DoBotControl.MoveCart(0.15,0,0,0,0,0);
%% Detect shapes in environment
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
objects = imageProcessing.DetectCube(image);
fprintf('Objects loaded!\n');
%% Pick and place objects
% Iterate through objects
% for i=1:size(objects,1)
%     % Get current RGB image
%     img = readImage(rgbSub.LatestMessage);
%     img = rgb2gray(img);
% 
%     % Calculate the rotation transform
%     [matchedPoints,matchedPointsReference] = imageProcessing.MatchFeatures(img,reference);
%     theta = imageProcessing.CalcTransform(matchedPoints,matchedPointsReference);
% 
%     % Identify the starting location of the piece
%     [u,v] = objects(i,:);
    pointMsg = pointsSub.LatestMessage;
    pointMsg.PreserveStructureOnRead = true;
    depthPoints = readXYZ(pointMsg);
    zPoints = depthPoints(:,:,3);
    % z = zPoints(320,:);
    % sumZ = sum(z);
    % sizeZ = size(z,2);
    % zC = sumZ/sizeZ;
        % Extract the z value for the coordinate
    zC = zPoints(objects(1),objects(2));
        % Convert the coordinates into centimetres from pixels
    [xC,yC] = camera2Dobot.PixelToDistance(objects(1),objects(2),zC);
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

    % % % Identify the target location of the piece
    % [uT,vT] = targets(i,:);
    pointMsgT = pointsSub.LatestMessage;
    pointMsgT.PreserveStructureOnRead = true;
    depthPointsT = readXYZ(pointMsgT);
    zPointsT = depthPointsT(:,:,3);
    % % zCT = zPointsT(boxX,boxY);
    % % sumZT = sum(zT);
    % % sizeZT = size(zT,2);
    % % zCT = sumZT/sizeZT;
        % Extract the z value for the coordinate
    zCT = zPointsT(objects(3),objects(4));
        % Convert the coordinates into centimetres from pixels
    [xCT,yCT] = camera2Dobot.PixelToDistance(objects(3),objects(4),zCT);
    [xDT,yDT,zDT] = camera2Dobot.Convert(xCT,yCT,zCT);

    % Move and deposit piece
        % Move to 25mm above target
    DoBotControl.MoveCart(xDT,yDT,zDT+0.025,0,0,0);
    pause(1);
    % %     % Calculate alignment of piece
    % % eeT = DoBotControl.CalcEEReqRot([xD,yD,zD],[base,rearArm,foreArm,ee],[xDT,yDT,zDT],theta);
    % % [base,rearArm,foreArm,ee] = DoBotControl.GetJointState();
    % % pause(1);
    % %     % Rotate end effector to align piece to target
    % % DoBotControl.RotateEndEffector(base,rearArm,foreArm,eeT);
    % % pause(1);
        % Place piece
    DoBotControl.MoveCart(xD,yD,zD,0,0,0);
    pause(1);
    EndEffectorControl.Off();
    pause(1);
        % Move to 25mm above target
    DoBotControl.MoveCart(xD,yD,zD+0.025,0,0,0);
    pause(1);
% end
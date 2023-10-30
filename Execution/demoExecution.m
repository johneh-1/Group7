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

% Store recognised objects and show outputs
objects = imageProcessing.DetectCube(image)
imshow(image);
hold on
plot(objects(1),objects(2),'b*');
plot(objects(3),objects(4),'g*');
fprintf('Objects loaded!\n');
%% Pick and place objects
% Calculate the rotation transform
[matchedPoints,matchedPointsReference] = imageProcessing.MatchFeatures(img,reference);
theta = imageProcessing.CalcTransform(matchedPoints,matchedPointsReference);

% Identify the starting location of the piece
u = objects(1,1);
v = objects(1,2);

% Extract depth values from depth stream
pointMsg = pointsSub.LatestMessage;
pointMsg.PreserveStructureOnRead = true;
depthPoints = readXYZ(pointMsg);
zPoints = depthPoints(:,:,3);

% Extract the z value for the piece coordinate
zC = zPoints(round(u),round(v));

% Convert the coordinates into metres from pixels
[xC,yC] = camera2Dobot.PixelToDistance(round(u),round(v),zC);
[xD,yD,zD] = camera2Dobot.Convert(xC,yC,zC);

% Move and collect piece
    % Waypoint to avoid collision with DoBot base
DoBotControl.MoveCart(0.13,-0.15,0,0,0,0);
pause(1);
    % Move to 25mm (0.025m) above piece to avoid knocking it
DoBotControl.MoveCart(xD,yD,zD+0.025,0,0,0);
pause(1);
    % Lower end effector to top of piece
DoBotControl.MoveCart(xD,yD,zD,0,0,0);
pause(1);
    % Turn on suction
EndEffectorControl.On();
pause(1);
    % Get joint state
[base,rearArm,foreArm,ee] = DoBotControl.GetJointState();
pause(1);
    % Move to 25mm (0.025m) above piece to avoid knocking it
DoBotControl.MoveCart(xD,yD,zD+0.025,0,0,0);
pause(1);

% Identify the target location of the piece
uT = objects(1,3);
vT = objects(1,4);
pointMsgT = pointsSub.LatestMessage;
pointMsgT.PreserveStructureOnRead = true;
depthPointsT = readXYZ(pointMsgT);
zPointsT = depthPointsT(:,:,3);

% Extract the z value for the target coordinate
zCT = zPointsT(round(uT),round(vT));
% Convert the coordinates into centimetres from pixels
[xCT,yCT] = camera2Dobot.PixelToDistance(round(uT),round(vT),zCT);
[xDT,yDT,zDT] = camera2Dobot.Convert(xCT,yCT,zCT);

% Move and deposit piece
    % Move to 25mm (0.025m) above target to avoid knocking it with piece
DoBotControl.MoveCart(xDT,yDT,zDT+0.02+0.025,0,0,0);
pause(1);
    % Calculate alignment of piece
eeT = DoBotControl.CalcEEReqRot([xD,yD,zD],[base,rearArm,foreArm,ee],[xDT,yDT,zDT],theta);
[base,rearArm,foreArm,ee] = DoBotControl.GetJointState();
pause(1);
    % Rotate end effector to align piece to target
DoBotControl.RotateEndEffector(base,rearArm,foreArm,eeT);
pause(1);
    % Place piece
DoBotControl.MoveCart(xDT,yDT,zDT+0.02,0,0,0);
pause(1);
    % Turn off suction
EndEffectorControl.Off();
pause(1);
    % Move to 25mm (0.025m) above target to avoid knocking it or the piece
DoBotControl.MoveCart(xDT,yDT,zDT+0.02+0.025,0,0,0);
pause(1);
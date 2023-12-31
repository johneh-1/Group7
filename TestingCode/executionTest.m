%% Script of execution
%% Notes for DoBot
% 1. Get target xyz for collection
% 2. Move to target xyz for collection + 25mm above piece
% 3. Lower EE to target xyz to sit on piece
% 4. Turn on suction
% 5. Raise EE by 25mm from current xyz (current state, z=z+0.025)
% 6. Invert transform between positions to find transformation matrix
% required for end effector to move
% 7. Convert (6) into an xyz coordinate
% 8. Get current joint states (incl. EE)
% 9. Compute final required EE orientation, subtract movement to be made by
% base
    % 9.1 This may require trigonometry to calcualte angle transcribed by
    % base during movement
    % 9.2 Subtract (9.1) from (9), this produces final EE joint state
% 10. Send target xyz + 25mm for deposition
% 11. At 25mm above target point, send required EE joint state. Other
% joints to remain at current state
% 12. Lower EE to target xyz to deposit piece
% 13. Turn off suction

%% Execution test for pick and place
DoBotControl.MoveCart(-0.0119,-0.2762,0,0,0,0);
pause(1);
DoBotControl.MoveCart(-0.0119,-0.2762,-0.0490,0,0,0);
pause(1);
EndEffectorControl.On();
pause(1);
DoBotControl.MoveCart(-0.0119,-0.2762,0,0,0,0);
pause(1);
DoBotControl.MoveCart(0.1100,-0.2050,0.0295,0,0,0);
pause(1);
[base,rearArm,foreArm,ee] = DoBotControl.GetJointState();
pause(1);
DoBotControl.RotateEndEffector(base,rearArm,foreArm,ee+pi/4);
pause(1);
[base,rearArm,foreArm,ee] = DoBotControl.GetJointState();
pause(1);
DoBotControl.MoveCart(0.1100,-0.2050,0.0055,0,0,ee);
pause(1);
EndEffectorControl.Off();
pause(1);
DoBotControl.MoveCart(0.1100,-0.2050,0.0295,0,0,ee);
pause(1);
DoBotControl.MoveCart(0,-0.2,0.05,0,0,0);
%% Execution test with object recognition
% find average value of each point

% Image processing
% Subscribers
rgbSub = rossubscriber('/camera/color/image_raw');
pointsSub = rossubscriber('/camera/depth_registered/points');

% RGB
img = readImage(rgbSub.LatestMessage);
img = rgb2gray(img);
points = detectHarrisFeatures(img,'MinQuality',0.1);

% Calculate location, using the output of the last 3 points as vertices
% X = sum(points.Location(8,1)+points.Location(9,1)+points.Location(10,1));
% X = X/3;
x = 458.2235;
% Y = sum(points.Location(8,2)+points.Location(9,2)+points.Location(10,2));
% Y = Y/3;
y = 248.2973;

% Depth
pointMsg = pointsSub.LatestMessage;
pointMsg.PreserveStructureOnRead = true;
depthPoints = readXYZ(pointMsg);
zPoints = depthPoints(:,:,3);
z = zPoints(320,:);
sumZ = sum(z);
sizeZ = size(z,2);
aveZ = sumZ/sizeZ;

% Target point for collection
% xC,yC,aveZ

% Convert camera to DoBot
[xD,yD,zD] = camera2Dobot.Convert(x,y,aveZ);

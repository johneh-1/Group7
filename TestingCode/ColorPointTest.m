function ColorPointTest()
close all;
% rgbSub = rossubscriber('/camera/aligned_depth_to_color/image_raw');
rgbSub = rossubscriber('/camera/color/image_raw');
pointsSub = rossubscriber('/camera/depth_registered/points');
pause(5); 

% Get the first message and plot the non coloured data
pointMsg = pointsSub.LatestMessage;
pointMsg.PreserveStructureOnRead = true;
cloudPlot_h = scatter3(pointMsg,'Parent',gca);
drawnow();

% Loop until user breaks with ctrl+c
while 1
    % Get latest data and preserve structure in point cloud
    pointMsg = pointsSub.LatestMessage;
    pointMsg.PreserveStructureOnRead = true;             
    
    % Extract data from msg to matlab
    cloud = readXYZ(pointMsg); 
    img = readImage(rgbSub.LatestMessage);
    % imshow(img)
    
    % Put in format to update the scatter3 plot quickly
    x = cloud(:,:,1);
    y = cloud(:,:,2);
    z = cloud(:,:,3);
    % r = img(:,:,1);
    % g = img(:,:,2);
    % b = img(:,:,3);
    
    % Update the plot
    % set(cloudPlot_h,'CData',[r(:),g(:),b(:)]);
    % set(cloudPlot_h,'XData',x(:),'YData',y(:),'ZData',z(:));
    drawnow();
end

% NOTES:
% z is 480x640
% depthPoints = readXYZ(pointMsg);
% z = depthPoints(:,:,3);
% zSample = z(:,240) is a strip across the middle of the page
% OR
% zSample = z(320,:)
% sumZ = sum(zSample)
% sizeZs = size(zSample,1)
% aveZ = sumZ/sizeZs
    % Example: aveZ = 0.3151

%% Show video
% rgbSub = rossubscriber('/camera/color/image_raw');
% img = readImage(rgbSub.LatestMessage);
% imshow(img)
% 
% rgbSub = rossubscriber('/camera/color/image_raw');

rgbSub = rossubscriber('/camera/color/image_raw');
pointsSub = rossubscriber('/camera/depth_registered/points');
while 1
    img = readImage(rgbSub.LatestMessage);
    imshow(img)
end
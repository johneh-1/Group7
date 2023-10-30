clear
% scratch
% Read in camera and detect corners of base in one location

img1 = imread('workspaceSampleImage.jpg');
img1 = rgb2gray(img1);
points1 = detectHarrisFeatures(img1,"MinQuality",0.01);
base_corner_locations = points1.Location;

% imshow(img1); 
% hold on
% plot(points1)


% Number of points
% numPoints = size(base_corner_locations, 1);

% Iterate through the points and calculate distances
% for i = 1:numPoints
%     for j = i+1:numPoints
%         % Calculate the Euclidean distance between point i and point j
%         distance = norm(base_corner_locations(i, :) - base_corner_locations(j, :));
%         fprintf('Distance between point %d and point %d: %.4f\n', i, j, distance);
%     end
% end



% Calculate distances and display them
numPoints = size(base_corner_locations,1);

for i = 1:numPoints
    for j = i+1:numPoints
        point1 = base_corner_locations(i,:);
        point2 = base_corner_locations(j,:);
        
        % Calculate the Euclidean distance between point1 and point2
        distance = norm(point1 - point2);
        
        fprintf('Distance between point (%.4f, %.4f) and point (%.4f, %.4f): %.4f\n', ...
            point1(1), point1(2), point2(1), point2(2), distance);
    end
end



% Left=img1(:,1:round(end/2));
% Right=img1(:,round(end/2)+1:end);
% imshow(Right)

% base_corner_locations(:,1);

n = 370; % Your threshold value

% % Create a logical index to filter rows where x < n
% logical_index = base_corner_locations(:, 1) < n;
% 
% % Use the logical index to extract the rows you want
% filtered_data = base_corner_locations(logical_index, :);
% 
% % Display the filtered data
% filtered_data;

% base_corner_locations(base_corner_locations(:, 1) < n, :) = [];

% Display the modified data
% base_corner_locations




% Read in camera again and detect corners of individual shapes

% img2 = imread('workspaceSampleImage2.jpg');
% img2 = rgb2gray(img2);
% points2 = detectHarrisFeatures(img2,"MinQuality",0.01);
% shapes_corner_locations = points2.Location;
% imshow(img2)
% hold on;
% plot(points2);

% Match images
% [features1, validPoints1] = extractFeatures(img1,points1);
% [features2, validPoints2] = extractFeatures(img2,points2);
% 
% indexPairs = matchFeatures(features1,features2);
% 
% matchedPoints1 = validPoints1(indexPairs(:,1));
% matchedPoints2 = validPoints2(indexPairs(:,2));
% 
% showMatchedFeatures(img1,img2,matchedPoints1,matchedPoints2,'montage');

% % Draw shapes???
% pgon1 = polyshape(base_corner_locations);
% pgon2 = polyshape(shapes_corner_locations);
% 
% % Calculate centre points of shapes
% polyarray = regions(polyin);
% [x,y] = centroid(polyarray);


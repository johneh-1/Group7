clc;
close all;

% Read in camera and detect corners of base in one location

img1 = imread('shapesandslotstopview.PNG');
img1 = rgb2gray(img1);
points1 = detectHarrisFeatures(img1,"MinQuality",0.01);
base_corner_locations = points1.Location;

% Pause operation as Dobot orients itself to individual shapes location
pause(10);

% Read in camera again and detect corners of individual shapes

img2 = imread('squaretopview.PNG');
img2 = rgb2gray(img2);
points2 = detectHarrisFeatures(img2,"MinQuality",0.01);
shapes_corner_locations = points2.Location;

% Match images
[features1, validPoints1] = extractFeatures(img1,points1);
[features2, validPoints2] = extractFeatures(img2,points2);

indexPairs = matchFeatures(features1,features2);

matchedPoints1 = validPoints1(indexPairs(:,1));
matchedPoints2 = validPoints2(indexPairs(:,2));

% Draw shapes???
pgon1 = polyshape(base_corner_locations);
pgon2 = polyshape(shapes_corner_locations);

% Calculate centre points of shapes
polyarray = regions(polyin);
[x,y] = centroid(polyarray);


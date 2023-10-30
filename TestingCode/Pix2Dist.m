function [X,Y,Z] = Pix2Dist(pix_X,pix_Y,pix_Z)

principalPoint = [680 480];
focalLength = 1000;

X = ((pix_X - principalPoint(1)) * Z) / focalLength;

Y = ((pix_Y - principalPoint(2)) * Z) / focalLength;

Z = ((pix_Z - principalPoint(3)) * Z) / focalLength;

end


function [X,Y,Z] = Pix2Dist(pix_X,pix_Y,Z)

X = (pix_X - Principal point) * Z/focal length

Y = (pix_Y - Principal point) * Z/focal length

end


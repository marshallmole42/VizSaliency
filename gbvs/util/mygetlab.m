function [ l,a,b,ii ] = mygetlab( img )
%MYGETLAB Summary of this function goes here
%   Detailed explanation goes here

labimg = rgb2lab(img);

l = labimg(:,:,1);
a = labimg(:,:,2);
b = labimg(:,:,3);



end


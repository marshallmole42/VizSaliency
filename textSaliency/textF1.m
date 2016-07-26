function F = textF1(grayimg, boxes)

[gmag, ~] = imgradient(grayimg);

F = zeros(size(grayimg));

for i=1:length(boxes)

    xmin = boxes(i,1);
    xmax = boxes(i,2);
    ymin = boxes(i,3);
    ymax = boxes(i,4);
    
    xcent = round((xmin+xmax)/2);
    ycent = round((ymin+ymax)/2);

    patch = gmag(xmin:xmax, ymin:ymax);
    
    F(xcent, ycent) = (mean(patch(:)))/(std(patch(:))+1);

end

end
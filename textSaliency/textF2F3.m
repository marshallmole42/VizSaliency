function [F2, F3] = textF2F3(img, boxes)


dim_img = size(img);

F2 = zeros(dim_img(1), dim_img(2));
F3 = F2;

if length(dim_img) == 3 && dim_img(3) == 3
    
    ycbcr = rgb2ycbcr(img);
    
    Y = ycbcr(:,:,1);
    Y = normalize01(Y);
    BWy = edge(Y, 'Canny');
    
    Cb = ycbcr(:,:,2);
    Cb = normalize01(Cb);
    BWcb = edge(Cb, 'Canny');
    
    Cr = ycbcr(:,:,3);
    Cr = normalize01(Cr);
    BWcr = edge(Cr, 'Canny');
    
    for i=1:size(boxes,1)
        
        xmin = boxes(i,1);
        xmax = boxes(i,2);
        ymin = boxes(i,3);
        ymax = boxes(i,4);

        xcent = round((xmin+xmax)/2);
        ycent = round((ymin+ymax)/2);
        
        patch1 = BWy(xmin:xmax, ymin:ymax);
        patch2 = BWcb(xmin:xmax, ymin:ymax);
        patch3 = BWcr(xmin:xmax, ymin:ymax);
        
        F2(xcent,ycent) = F2(xcent, ycent) + patchF2(patch1);
        F2(xcent,ycent) = F2(xcent, ycent) + patchF2(patch2);
        F2(xcent,ycent) = F2(xcent, ycent) + patchF2(patch3);
        
        F3(xcent,ycent) = F3(xcent, ycent) + patchF3(patch1);
        F3(xcent,ycent) = F3(xcent, ycent) + patchF3(patch2);
        F3(xcent,ycent) = F3(xcent, ycent) + patchF3(patch3);
    end
    
    F2 = F2/3;
    F3 = F3/3;
    
elseif length(dim_img) == 2
    
    img = normalize01(img);
    BW = edge(img,'Canny');
    
    for i=1:size(boxes,1)
        
        xmin = boxes(i,1);
        xmax = boxes(i,2);
        ymin = boxes(i,3);
        ymax = boxes(i,4);

        xcent = round((xmin+xmax)/2);
        ycent = round((ymin+ymax)/2);
        
        patch = BW(xmin:xmax, ymin:ymax);
        
        F2(xcent, ycent) = patchF2(patch);
        
        F3(xcent, ycent) = patchF3(patch);
        
    end
    
end
function [ S ] = textSaliency( img_in )
%TEXTSALIENCY Summary of this function goes here
% main function that computes the 'saliency' or probability that there is
% text at a specific location of the input image

% 'img_in': input image array
% 'S': output map of the same size as input image

% Marshall Wang 06/21/16


%   Detailed explanation goes here


scales = 0.4:0.2:1.4;

imgsize = size(img_in);

S = zeros(imgsize(1),imgsize(2));

for scale = scales  % loop through each scale

    scaledimg = imresize(img_in, scale);
    
    dim_img = size(scaledimg);
    
    if length(dim_img) == 3 && dim_img(3) == 3
        
        grayimg = rgb2gray(scaledimg);
        
    elseif length(dim_img) == 2
        
        grayimg = scaledimg;
        
    end
    
    H = dim_img(1);
    W = dim_img(2);
    
    [Regions, conComp] = detectMSERFeatures(grayimg, 'RegionAreaRange', round([20, 8000]*scale), 'ThresholdDelta', 1);
    
    mserStats = regionprops(conComp, 'BoundingBox', 'Eccentricity', 'Solidity', 'Extent', 'Euler', 'Image');
    
    bbox = vertcat(mserStats.BoundingBox);
    if isempty(bbox)
        continue;
    end
    
    w = bbox(:,3);
    h = bbox(:,4);
    aspectRatio = w./h;
    
    filterIdx = [];
    
    filterIdx = aspectRatio' > 3;
    filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
    filterIdx = filterIdx | [mserStats.Solidity] < .3;
    filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
    filterIdx = filterIdx | [mserStats.EulerNumber] < -4;
    
    mserStats(filterIdx) = [];
    Regions(filterIdx) = [];
    
    strokeWidthThreshold = 0.3;
    strokeWidthFilterIdx = [];
    
    for j = 1:numel(mserStats)

    regionImage = mserStats(j).Image;
    regionImage = padarray(regionImage, [1 1], 0);

    distanceImage = bwdist(~regionImage);
    skeletonImage = bwmorph(regionImage, 'thin', inf);

    strokeWidthValues = distanceImage(skeletonImage);

    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

    strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;

    end
    
    strokeWidthFilterIdx = logical(strokeWidthFilterIdx);
    
    % Remove regions based on the stroke width variation
    if ~isempty(strokeWidthFilterIdx)
        
        if size(Regions,1)==1 && size(Regions,2)==1 && strokeWidthFilterIdx == 1
            Regions = [];
            mserStats = [];
            continue;
        else
            Regions(strokeWidthFilterIdx) = [];
            mserStats(strokeWidthFilterIdx) = [];
        end
    end
    
    % show MSER
%     handle = figure;
%     imshow(grayimg)
%     hold on
%     plot(Regions, 'showPixelList', true,'showEllipses',false)
%     
    % write MSER
%     outfilename = ['MSER_' filename];
%     print(outfilename,'-dpng');
    
    
%     close(handle);
    
    % use the filtered MSER bounding boxes to create mask for edge maps
    
    
    
    bboxes = vertcat(mserStats.BoundingBox);
    
    if isempty(bboxes)
        continue;
    end
    
    ymin = bboxes(:,2)*0.98-2;
    xmin = bboxes(:,1)*0.98-2;
    xmax = xmin + round(bboxes(:,3)*1.02) + 1;
    ymax = ymin + round(bboxes(:,4)*1.02) + 1;
    
    xmin = floor(xmin);
    ymin = floor(ymin);
    xmax = ceil(xmax);
    ymax = ceil(ymax);
    
    idx = xmin<1;
    xmin(idx)=1;
    idx = ymin<1;
    ymin(idx)=1;
    idx = xmax>W;
    xmax(idx) = W;  % x is the column subscript
    idx = ymax>H;
    ymax(idx) = H;  % y in the row subscript
    
    boxes = [ymin ymax xmin xmax];
    
%     mask = zeros(size(grayimg));
%     
%     for k = 1:length(xmin)  % loop through all bounding boxes
%         mask(xmin(k):xmax(k), ymin(k):ymax(k)) = 1;
%     end
    
    % write mask
%     outfilename = ['Mask_' filename];
%     imwrite(mask, outfilename);
    
    
    % compute three features
    
    if isempty(boxes)
        continue;
    end
    
    F1 = textF1(grayimg, boxes);  % gradient contrast feature
    [F2, F3] = textF2F3(scaledimg, boxes);
    
    F1 = imgaussfilt(F1, sqrt(H*W)/52);
    F2 = imgaussfilt(F2, sqrt(H*W)/52);
    F3 = imgaussfilt(F3, sqrt(H*W)/52);
    
    
    F1 = F1*10;
    F2 = F2*10;
    F3 = F3*10;
    
%     f1 = normalize01(F1);
%     imshow(f1);
%     f2 = normalize01(F2);
%     imshow(f2);
%     f3 = normalize01(F3);
%     imshow(f3);
    
    S0 = F1+F2+F3;
    
    S = S + imresize(S0, size(S));
    
end

S = S/length(scales);

S(S<=0) = eps;   % fix negative values

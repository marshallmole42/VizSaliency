% run all 393 Visualizations

% compute itti-koch map, combine itti-koch map with text map

% compute MIT metrics with text alone, itti-koch alone, and the two
% combined (two different combinations)

tic 

load('/home/marshall/Documents/targets393/allImages.mat');

for visnum = 1:length(allImages)
    
    imagefname = allImages(visnum).filename;
    imgpath = ['/home/marshall/Documents/targets393/targets/' imagefname];
    
    img = imread(imgpath);
    
    % compute text saliency
    S = textSaliency(img);    % 'img' is the image matrix (either grayscale or RGB)
    S0 = mat2gray(S);
    
    % compute Itti-Koch saliency map
    ikout = ittikochmap(img);
    ikmap = ikout.master_map_resized;
    
    % make linear combinations (with normalization to 0 to 1)
    comb1 = mat2gray(S0+ikmap);
    comb2 = mat2gray(ikmap+S0/3);
    
    
    % get fixation map in binary
    img_size = [size(img,1) size(img,2)];
    whichrow = visnum;
    fixmap_b = zeros(img_size);
    
    for usr = 1:length(allImages(whichrow).userdata)
        
        if ~isempty(allImages(whichrow).userdata(usr).fixations)
            
            ind = sub2ind(img_size, ceil(allImages(whichrow).userdata(usr).fixations.enc(:,2)), ...
                ceil(allImages(whichrow).userdata(usr).fixations.enc(:,1)));
            fixmap_b(ind) = 1;
        end
        
    end
    
    % smooth fixation map with Gaussian
    fixmap_s = antonioGaussian(fixmap_b,8);
    fixmap_s(fixmap_s(:) < 0) = eps;
    
    
    % get control fixation map based on randomly selected other images'
    % fixations
    
    otherimages = allImages;
    otherimages(visnum) = [];
    
    rindx = randsample(1:length(otherimages),10);
    selected = otherimages(rindx);
    
    selectedsizes = zeros(length(selected),2);
    
    for fid = 1:length(selected)
        othimgsz = selected(fid).imsize;
        selectedsizes(fid,:) = othimgsz(1:2);
    end
    maxsize = max(selectedsizes);
    
    maxsize(1) = max([maxsize(1),img_size(1)]);
    maxsize(2) = max([maxsize(2),img_size(2)]);
    
    othfixmap = zeros(maxsize);
    
    for fid = 1:length(selected)
        for usr = 1:length(selected(fid).userdata)
            if ~isempty(selected(fid).userdata(usr).fixations)
                ind = sub2ind(selectedsizes(fid,:), ceil(selected(fid).userdata(usr).fixations.enc(:,2)),...
                    ceil(selected(fid).userdata(usr).fixations.enc(:,1)));
                othfixmap(ind)=1;
            end
        end
    end
    
    othfixmap = othfixmap(1:img_size(1), 1:img_size(2));
    
    [~, name, ~] = fileparts(imagefname);
    matpath = [name '.mat'];
    save(matname, 'img','S', 'S0', 'ikmap', 'fixmap_b', 'fixmap_s', 'othfixmap');
    
    % compute metrics
    results_ts.aucJ(visnum) = AUC_Judd(S, fixmap_b, 1, 0);
    results_ts.sim(visnum) = similarity(S, fixmap_s);
    results_ts.emd(visnum) = EMD(S, fixmap_s);
    results_ts.aucB(visnum) = AUC_Borji(S, fixmap_b);
    results_ts.sAUC(visnum) = AUC_Shuffled(S,fixmap_b, othfixmap);
    results_ts.cc(visnum) = CC(S, fixmap_s);
    results_ts.nss(visnum) = NSS(S,fixmap_b);
    results_ts.KL(visnum) = KLdiv(S, fixmap_s);
    
    results_ik.aucJ(visnum) = AUC_Judd(ikmap, fixmap_b, 1, 0);
    results_ik.sim(visnum) = similarity(ikmap, fixmap_s);
    results_ik.emd(visnum) = EMD(ikmap, fixmap_s);
    results_ik.aucB(visnum) = AUC_Borji(ikmap, fixmap_b);
    results_ik.sAUC(visnum) = AUC_Shuffled(ikmap,fixmap_b, othfixmap);
    results_ik.cc(visnum) = CC(ikmap, fixmap_s);
    results_ik.nss(visnum) = NSS(ikmap,fixmap_b);
    results_ik.KL(visnum) = KLdiv(ikmap, fixmap_s);
    
    results_c1.aucJ(visnum) = AUC_Judd(comb1, fixmap_b, 1, 0);
    results_c1.sim(visnum) = similarity(comb1, fixmap_s);
    results_c1.emd(visnum) = EMD(comb1, fixmap_s);
    results_c1.aucB(visnum) = AUC_Borji(comb1, fixmap_b);
    results_c1.sAUC(visnum) = AUC_Shuffled(comb1,fixmap_b, othfixmap);
    results_c1.cc(visnum) = CC(comb1, fixmap_s);
    results_c1.nss(visnum) = NSS(comb1,fixmap_b);
    results_c1.KL(visnum) = KLdiv(comb1, fixmap_s);
    
    results_c2.aucJ(visnum) = AUC_Judd(comb2, fixmap_b, 1, 0);
    results_c2.sim(visnum) = similarity(comb2, fixmap_s);
    results_c2.emd(visnum) = EMD(comb2, fixmap_s);
    results_c2.aucB(visnum) = AUC_Borji(comb2, fixmap_b);
    results_c2.sAUC(visnum) = AUC_Shuffled(comb2,fixmap_b, othfixmap);
    results_c2.cc(visnum) = CC(comb2, fixmap_s);
    results_c2.nss(visnum) = NSS(comb2,fixmap_b);
    results_c2.KL(visnum) = KLdiv(comb2, fixmap_s);
    
    fprintf('Done for %d\n',visnum);
    
end

toc
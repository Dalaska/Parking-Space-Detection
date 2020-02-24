%Lin Zhang, School of Software Engineering, Tongji University, Jan. 2017
%this script is used to view the groundtruth parking-slot labeling info
%before running it, make sure the folder "viewGT" is available. The image
%with labeling parking-slots will be output to the folder "viewGT"
%the 500 testing images is in the folder "testing images" 
%the groundtruth labeling infor is stored in gt.mat
GT = load('gt.mat');
GTSlots = GT.parkingSlots;

for imageIndex = 1:length(GTSlots)
    imageName = num2str(imageIndex);
    if imageIndex < 10
        imageName = ['00' imageName];
    elseif imageIndex >= 10 && imageIndex < 100
        imageName = ['0' imageName];
    end
    
    img = imread(['testing images\' imageName '.bmp']);
    slotsForThisImage = GTSlots{imageIndex};
    if ~isempty(slotsForThisImage)
        imgWithSlotsDrawn = insertShape(img,'Polygon',slotsForThisImage(:,1:8),'Color','blue','linewidth',2);   
    else
        imgWithSlotsDrawn =  img;
    end
    figure;
    imshow(imgWithSlotsDrawn);
    print(['viewGT\' imageName], '-dbmp');
    close all;
end



%Lin Zhang, School of Software Engineering, Tongji University
%We have proposed a learning-based approach PSDL for vision-based
%parking-slot detection. The algorithm deployed on vehicles is implemented
%in C++.
%This is the matlab source code of PSDL which can get the same results
%with the C++ version, only a litte slower.
addpath(genpath('./'));

%before running this demo, please make sure that the test image set is at
%the local foloder 'test images'
%the trained marking-point detector in stored in 'slotDetectors1.0.mat'
detectors = load('slotDetectors1.0.mat');
detectors = detectors.detectors;

%the gaussian line template, used to examine the local parking-slot line
%patterns
gauLineTemplate = load('gauLineTemplate.mat');
gauLineTemplate = gauLineTemplate.gabor;
acosTable = load('acosTable.mat');
acosTable = acosTable.acosTable;
halfGaussianWidth = (size(gauLineTemplate,1)-1)/2;
lastSlots = zeros(0,8);
testFiles = dir('test images\*.bmp');

stepForDet = 2;
threshForSoftCascade = -1; 

%the parking-slot detection results are stored in a cell structure
detectResults = cell(500,1);
for index = 1:length(testFiles)
    currentFileName = testFiles(index).name;

    oriImage = imread(['test images\' currentFileName]);
    smallImage = imresize(oriImage, 0.5, 'method', 'bilinear');
    
    slots = myDetect(smallImage,detectors,gauLineTemplate,acosTable,halfGaussianWidth, stepForDet, threshForSoftCascade);
    if ~isempty(slots)
        slots(:,1:8) = slots(:,1:8) *2;
    end
    detectResults{index,1} = slots;
      
    %if you want to visually view the detection results, please uncomment
    %the following section. It will also output the results in a local
    %folder "results"
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(slots)
            imgWithSlotsDrawn = insertShape(oriImage,'Polygon',slots(:,1:8),'Color','blue','linewidth',2);   
        else
            imgWithSlotsDrawn =  oriImage;
        end
       
        figure;
        imshow(imgWithSlotsDrawn,[]);
        print(['results\' currentFileName], '-dbmp');
        close all;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
save('detectResults.mat','detectResults');
 

%Lin Zhang, School of Software Engineering, Tongji University, Jan. 2017
%This script is used to calculate the precision-recall metric of the
%parking-slot detection results on the test image set against the
%ground-truths

%gt.mat contains the ground-truth
GT = load('gt.mat');
%the parking-slot detection results should be stored in detectResults.mat.
%In this example, the provided detectResults.mat contains the detection
%results of our algorithm PSDL
DR = load('detectResults.mat');
countGT = 0;
countDR = 0;
garageNum = 0;

radiusSquare = 100;

for k = 1:length(GT.parkingSlots)
    GTNum = GT.parkingSlots{k,1};
    DRNum = DR.detectResults{k,1};
    countGT = countGT + size(GTNum,1);
    countDR = countDR + size(DRNum,1);
    for m = 1:size(DRNum,1)
        for n = 1:size(GTNum,1)
            compareP1 = (GTNum(n,1) - DRNum(m,1))^2 + (GTNum(n,2) - DRNum(m,2))^2;
            compareP2 = (GTNum(n,3) - DRNum(m,3))^2 + (GTNum(n,4) - DRNum(m,4))^2;
            compareN1 = (GTNum(n,3) - DRNum(m,1))^2 + (GTNum(n,4) - DRNum(m,2))^2;
            compareN2 = (GTNum(n,1) - DRNum(m,3))^2 + (GTNum(n,2) - DRNum(m,4))^2;
            
            if ((compareP1 < radiusSquare) && (compareP2 < radiusSquare) && (GTNum(n,9) == DRNum(m,9))) || ((compareN1 < radiusSquare) && (compareN2 < radiusSquare) && (GTNum(n,9) == -DRNum(m,9)))
                garageNum = garageNum + 1;
                GTNum(n,:) = [];
                break;
            end           
        end
    end
end

precision = garageNum/countDR
recall = garageNum/countGT
% Fbeta = (1 + beta^2) * precision * recall/(precision + recall);
function slots = acfDetect( I, detector, overlap, threshForKP, gabor,acosTable,...
                            halfGaussianWidth,...
                            threshForRespRatioForValidSlotLine,...
                            matchedGaborRespThreshSeparator, matchedGaborRespThreshBridge,...
                            sumOfGaborRespTwoBridgesThreh,...
                            sumOfGaborRespTwoSeparatorsThreh,...
                            KPScoreSumThresh,...
                            stepForDet, threshForSoftCascade)
%the following two constants should be consistent with the ones in the file
%"decideValidSlotline"
[rows, cols] = size(I);

    xStart = 1;
    xEnd = cols;
    yStart = 1;
    yEnd = rows;
    %when searching on the full screen, step can be set as a larger number
    step = stepForDet; 
    
IForDetect = I(yStart:yEnd, xStart:xEnd);
pyramidData = chnsPyramid(IForDetect,acosTable); 
bbsForDetect=cell(1, 4);
for j=1:4
        bb = acfDetect1(pyramidData,detector{j},2, 24,24,step,threshForSoftCascade);
        bbsForDetect{1,j}=bb;
end

bbs = zeros(0,5);
for cellIndex = 1:4
        bbsCurrent = bbsForDetect{cellIndex};
        if ~isempty(bbsCurrent)
            bbs = [bbs; bbsCurrent];
        end
end

if isempty(bbs)
        slots = [];
        return;
end

bbs(:,1)=bbs(:,1)-3;
bbs(:,2)=bbs(:,2)-3;
bbs(:,3)=18;
bbs(:,4)=18;
bbs=bbNms(bbs,overlap); 

if size(bbs,1)>=10
   bbs(10:end,:) = [];
end
bbs =  bbs(bbs(:,5)>threshForKP,:);
bbs(:,1) = bbs(:,1) + xStart - 1;
bbs(:,2) = bbs(:,2) + yStart - 1;
    
keyPoints = zeros(size(bbs,1),3);
keyPoints(:,1) = bbs(:,1) + bbs(:,3)/2+1;
keyPoints(:,2) = bbs(:,2) + bbs(:,4)/2+1;
keyPoints(:,3) = bbs(:,5);  

%  figure; 
%  imshow(I,[]); 
%  bbApply('draw',bbs); 
%  figure;
%  imshow(I,[]);
%  hold on;
%  plot(keyPoints(:,1),keyPoints(:,2),'go','markersize',8);
%  for pointIndex = 1:size(keyPoints,1)
%     text(keyPoints(pointIndex,1)+7, keyPoints(pointIndex,2),num2str(pointIndex), 'color','y','fontsize' ,12);
%  end

 %Then, we need to predict the parking slots information based on keyPoints

 slots = estimateSlots(I, keyPoints, gabor,...
                                    halfGaussianWidth,...
                                    threshForRespRatioForValidSlotLine,...
                                    matchedGaborRespThreshSeparator, matchedGaborRespThreshBridge,...
                                    sumOfGaborRespTwoBridgesThreh,...
                                    sumOfGaborRespTwoSeparatorsThreh,...
                                    KPScoreSumThresh);

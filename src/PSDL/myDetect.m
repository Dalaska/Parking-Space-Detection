function slotsResult = myDetect(oriImage,detectors,gauLineTemplate,acosTable, halfGaussianWidth, stepForDet, threshForSoftCascade)

threshForKP = 145; %cannot be smaller than 150 2016-11-23
threshForRespRatioForValidSlotLine = 1.18; %cannot be greater than 1.25 cannot be smaller than 1.18 2016-10-11
matchedGaborRespThreshSeparator = 41.1; %cannot be smaller than 41.1 2016-10-11
matchedGaborRespThreshBridge = 36.21;%cannot be smaller than 36.21 2016-11-23
sumOfGaborRespTwoBridgesThreh = 116.4; %cannot be smaller than 116.4 %lin 2016-11-23
sumOfGaborRespTwoSeparatorsThreh = 120.17; %cannot be smaller than 120.17 2016-11-23;
KPScoreSumThresh = 197.2;  

% scaleFactor = 0.624;
% scaleFactor = 0.50; %for car1 it is 0.624; for car2, it is 0.5
% imgScaled = single(imresize(oriImage, scaleFactor, 'method', 'bilinear'));
imgScaled = single(oriImage);
imgScaled = 0.299 * imgScaled(:,:,1) + 0.587 * imgScaled(:,:,2) + 0.114 * imgScaled(:,:,3);
minV = min(imgScaled(:));
maxV = max(imgScaled(:));
imgScaled = (imgScaled - minV)/(maxV - minV) * 255;

overlap = 0.10;
slots = acfDetect(imgScaled,detectors, overlap, threshForKP, gauLineTemplate,acosTable,...
                            halfGaussianWidth,...
                            threshForRespRatioForValidSlotLine,...
                            matchedGaborRespThreshSeparator, matchedGaborRespThreshBridge,...
                            sumOfGaborRespTwoBridgesThreh,...
                            sumOfGaborRespTwoSeparatorsThreh,...
                            KPScoreSumThresh,...
                            stepForDet, threshForSoftCascade); 

if ~isempty(slots)
   slotsResult = slots(:,1:9);
else
   slotsResult = [];
end
end

function bbsResult = detectFromPyramid(bbs, detector, opts, pyramidData,shrink,Pscaleshw1,Pscaleshw2,shift1,shift2,Pscales,pNms)

bb = zeros(100,5);
coder.varsize('bb');
% apply sliding window classifiers
nScales = 24;
clf  = detector.clf;
% modelDsPad = opts.modelDsPad;
for i=1:nScales
    modelDsPad=opts.modelDsPad; 
    modelDs=opts.modelDs;
    bb = acfDetectZSY(pyramidData{i},clf,shrink,modelDsPad(1), modelDsPad(2),5,-1);
    bb(:,1)=(bb(:,1)+shift2)/Pscaleshw2(i);
    bb(:,2)=(bb(:,2)+shift1)/Pscaleshw1(i);
    bb(:,3)= modelDs(2)/Pscales(i);
    bb(:,4)= modelDs(1)/Pscales(i);
    bbs{i}=bb;
end

numBBs = 0;
for scaleIndex = 1:nScales
    numBBs = numBBs + size(bbs{scaleIndex}, 1);
end
catbbs = zeros(numBBs, 5);

cursor = 1;
 for scaleIndex = 1:nScales
     numBBsThisScale = size(bbs{scaleIndex}, 1);
     catbbs(cursor:cursor+numBBsThisScale-1,:) = bbs{scaleIndex}; 
     cursor = cursor + numBBsThisScale;
 end
 
 %for non-maximum suppression, type should be max or maxg, DONOT set other
 %types Lin Zhang
 bbsResult=bbNms(catbbs,pNms); 
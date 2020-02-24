function finalSlot = estimateSlots(image, keyPoints, gabor,...
                                                halfGaussianWidth,...
                                                threshForRespRatioForValidSlotLine,...
                                                matchedGaborRespThreshSeparator, matchedGaborRespThreshBridge,...
                                                sumOfGaborRespTwoBridgesThreh,...
                                                sumOfGaborRespTwoSeparatorsThreh,...
                                                KPScoreSumThresh)
%this function estimates the parking slots info based on keypoints 
%slots has n rows, where each row indicates a parking slot; each row
%contains [x1P y1P x2P y2P x3P y3P x4P y4P x1W y1W x2W y2W x3W y3W x4W y4W]
%P means coordinates in image and W means world coordinates whose origiin is at the middle point of the rear axis of the car
zeroVec = zeros(size(keyPoints,1),1);
keyPoints = [keyPoints zeroVec]; %for each keypoint record, [x,y,score,refs] where refs indicates the number of lines using it as an endpoint

imagePadded = padarray(image, [halfGaussianWidth*2+1 halfGaussianWidth*2+1], 'symmetric');
%since we need to use Gaussian filter to test the local pattern, at the
%image boundary the patch may be not complete. Thus, we need to pad the image. 
%The slots are determined totally on the padded image, so the KP
%coordinates should be compensated at first
keyPointsInPadImg = zeros(size(keyPoints,1), size(keyPoints,2), 3);
keyPointsInPadImg(:,1) = keyPoints(:,1) + halfGaussianWidth*2+1; 
keyPointsInPadImg(:,2) = keyPoints(:,2) + halfGaussianWidth*2+1;
keyPointsInPadImg(:,3) = keyPoints(:,3);
    
%at first, we need to determine the candidate slot lines simply based on the
%KPs
 candidateSlotLines = zeros(10,6);
 coder.varsize('candidateSlotLines', [10 6]);
 %generate candidate parking slot lines
 slotLineCount = 0;
 for keyPointIndex = 1:size(keyPoints,1)-1
     currentKP = keyPointsInPadImg(keyPointIndex,:);
     for remainingKPIndex = keyPointIndex+1:size(keyPoints,1)
         secKP = keyPointsInPadImg(remainingKPIndex,:);
         [valid, type, orientation] = decideValidSlotLine(currentKP, secKP, imagePadded, gabor,...
                                                  halfGaussianWidth,...
                                                  threshForRespRatioForValidSlotLine,...
                                                  matchedGaborRespThreshSeparator, matchedGaborRespThreshBridge,...
                                                  sumOfGaborRespTwoBridgesThreh,...
                                                  sumOfGaborRespTwoSeparatorsThreh,...
                                                  KPScoreSumThresh);
         
         if valid
             slotLineCount = slotLineCount + 1;
             candidateSlotLines(slotLineCount,:) = [keyPointIndex remainingKPIndex type orientation currentKP(3)+secKP(3) 1];
             keyPoints(keyPointIndex, 4) = keyPoints(keyPointIndex, 4)  + 1;
             keyPoints(remainingKPIndex, 4) = keyPoints(remainingKPIndex, 4) + 1;
         end
         if slotLineCount == 9;
             break;
         end
     end
     if slotLineCount == 9;
             break;
     end
 end
 
 slots = zeros(10,9);
 coder.varsize('slots', [10 9]);
%  finalSlot = zeros(1,8);
 if isempty(candidateSlotLines)
     finalSlot = [];
     return;
 end
 candidateSlotLines(slotLineCount+1:10,:) = [];
 
 %Some slot lines may contradict with other, we need to disseminate these
 %contradictions. 
 %At first, for some long lines (type = 2 or 3) passing valid keypoints, these long lines
 %need to be removed.
 while (true)
     bCollide = false;
     for slotLineIndex = 1:size(candidateSlotLines,1)
         bCollide = false;
         %at first, we check whether there are KPs on this line
         if candidateSlotLines(slotLineIndex,6) == 0
             continue;
         end
         
         endPoint1 = keyPoints(candidateSlotLines(slotLineIndex,1),1:2);
         endPoint2 = keyPoints(candidateSlotLines(slotLineIndex,2),1:2);
         vecFrom1To2 = endPoint2 - endPoint1;
         normVecFrom1To2 = norm(endPoint2 - endPoint1);
         for kpIndex = 1:size(keyPoints,1)
              if keyPoints(kpIndex,4) > 0 && kpIndex ~= candidateSlotLines(slotLineIndex,1) && kpIndex ~= candidateSlotLines(slotLineIndex,2) 
                  %it is a valid KP and is none of endpoints of this line
                  vecFrom1To3 = keyPoints(kpIndex,1:2) - endPoint1;
                  cos12with13 = dot(vecFrom1To2,vecFrom1To3) / (normVecFrom1To2 * norm(vecFrom1To3));
                  vecFrom2To3 = keyPoints(kpIndex,1:2) - endPoint2;
                  cos21with23 = dot(-vecFrom1To2,vecFrom2To3) / (normVecFrom1To2 * norm(vecFrom2To3));

                  if abs(cos12with13-1) < 0.020 && abs(cos21with23-1) < 0.020 %this point is on this slot line
                      bCollide = true;
                      for tmpLineIndex = 1:size(candidateSlotLines,1)
                          if candidateSlotLines(tmpLineIndex,6) == 0 %it is not a valid line
                              continue;
                          end
                          if candidateSlotLines(tmpLineIndex,1) == kpIndex || candidateSlotLines(tmpLineIndex,2) == kpIndex
                              if candidateSlotLines(slotLineIndex,3) == 2 || candidateSlotLines(slotLineIndex,3) == 3%a side-way long line
                                  candidateSlotLines(slotLineIndex, 6) = 0;
                                  firstKPIndex = candidateSlotLines(slotLineIndex, 1); 
                                  secKPIndex = candidateSlotLines(slotLineIndex, 2);
                                  keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                                  keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                              elseif candidateSlotLines(tmpLineIndex,3) == 2 || candidateSlotLines(tmpLineIndex,3) == 3 %a side-way long line
                                  candidateSlotLines(tmpLineIndex, 6) = 0;
                                  firstKPIndex = candidateSlotLines(tmpLineIndex, 1); 
                                  secKPIndex = candidateSlotLines(tmpLineIndex, 2);
                                  keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                                  keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                              elseif candidateSlotLines(slotLineIndex,5) > candidateSlotLines(tmpLineIndex,5)
                                  candidateSlotLines(tmpLineIndex, 6) = 0;
                                  firstKPIndex = candidateSlotLines(tmpLineIndex, 1); 
                                  secKPIndex = candidateSlotLines(tmpLineIndex, 2);
                                  keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                                  keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                              else
                                  candidateSlotLines(slotLineIndex, 6) = 0;
                                  firstKPIndex = candidateSlotLines(slotLineIndex, 1); 
                                  secKPIndex = candidateSlotLines(slotLineIndex, 2);
                                  keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                                  keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                              end
                              break;
                          end
                      end
                   end
              end
              if bCollide
                  break;
              end
         end
     end
  
     candidateSlotLines(candidateSlotLines(:,6)==0,:) = [];
     %There may be several lines sharing the same KP, we need to remove
     %some inconsistent ones
     for kpIndex = 1:size(keyPoints,1)
         if keyPoints(kpIndex, 4) < 2 %we only deal with KPs with refs>=2
             continue;
         end
         
         lineIndicesSharingThisKP = find(candidateSlotLines(:,1) == kpIndex | candidateSlotLines(:,2) == kpIndex);
         [~, index] = max(candidateSlotLines(lineIndicesSharingThisKP,5));
         strongLineIndex = lineIndicesSharingThisKP(index);
         strongLine = candidateSlotLines(strongLineIndex,:);
         %decide the orientation vector, starting from current KP
         if strongLine(1) == kpIndex
             strongVec = keyPoints(strongLine(2),1:2) - keyPoints(strongLine(1),1:2);
         else
             strongVec = keyPoints(strongLine(1),1:2) - keyPoints(strongLine(2),1:2);
         end
         normStrongVec = norm(strongVec);
         %for the other lines sharing this KP, compute their orientations
         %and then perform disentangle
         for tmpIndex = 1:size(lineIndicesSharingThisKP,1)
             lineIndexSharingKP = lineIndicesSharingThisKP(tmpIndex);
             if lineIndexSharingKP == strongLineIndex
                 continue;
             end
             lineSharingKP = candidateSlotLines(lineIndexSharingKP,:);
             if lineSharingKP(1) == kpIndex
                currentLineVec = keyPoints(lineSharingKP(2),1:2) - keyPoints(lineSharingKP(1),1:2);
             else
                currentLineVec = keyPoints(lineSharingKP(1),1:2) - keyPoints(lineSharingKP(2),1:2);
             end
             
             cosStrongVecCurrentLineVec = dot(strongVec,currentLineVec) / (normStrongVec * norm(currentLineVec));
             if (cosStrongVecCurrentLineVec<0.955 && cosStrongVecCurrentLineVec > 0.045) ||...
                (cosStrongVecCurrentLineVec<-0.020 && cosStrongVecCurrentLineVec > -0.980) %it is an invalid line
                
                if (strongLine(3) == 2 || strongLine(3) == 3) &&...
                   (candidateSlotLines(lineIndexSharingKP,3) ~= 2 && candidateSlotLines(lineIndexSharingKP,3)  ~= 3)
                    candidateSlotLines(strongLineIndex, 6) = 0;
                    firstKPIndex = candidateSlotLines(strongLineIndex, 1); 
                    secKPIndex = candidateSlotLines(strongLineIndex, 2);
                    keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                    keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                else
                    candidateSlotLines(lineIndexSharingKP, 6) = 0;
                    firstKPIndex = candidateSlotLines(lineIndexSharingKP, 1); 
                    secKPIndex = candidateSlotLines(lineIndexSharingKP, 2);
                    keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                    keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                end
                bCollide = true;
             else %the two lines having the opposite directions or are perpendicular to each other
                if cosStrongVecCurrentLineVec>-0.05 && cosStrongVecCurrentLineVec < 0.05 %the two lines are perpendicular 
                    if strongLine(3) == lineSharingKP(3) %having same line types, it is impossible
                        bCollide = true;
                        candidateSlotLines(lineIndexSharingKP, 6) = 0;
                        firstKPIndex = candidateSlotLines(lineIndexSharingKP, 1); 
                        secKPIndex = candidateSlotLines(lineIndexSharingKP, 2);
                        keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                        keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                    end
                else %the two lines are on the same line, having different directions
                    if strongLine(3) ~= lineSharingKP(3) %having different line types, it is impossible
                        bCollide = true;
                        if strongLine(3) == 2 || strongLine(3) == 3%if the strong line is of type 2 or 3, remove it 
                           candidateSlotLines(strongLineIndex, 6) = 0;
                           firstKPIndex = candidateSlotLines(strongLineIndex, 1); 
                           secKPIndex = candidateSlotLines(strongLineIndex, 2);
                           keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                           keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                        else
                           candidateSlotLines(lineIndexSharingKP, 6) = 0;
                           firstKPIndex = candidateSlotLines(lineIndexSharingKP, 1); 
                           secKPIndex = candidateSlotLines(lineIndexSharingKP, 2);
                           keyPoints(firstKPIndex,4) = keyPoints(firstKPIndex,4) - 1;
                           keyPoints(secKPIndex,4) = keyPoints(secKPIndex,4) - 1;
                        end
                    end
                end
             end
             if bCollide == true
                 break
             end
         end
         if bCollide == true
                 break
         end
     end
     
     candidateSlotLines(candidateSlotLines(:,6)==0,:) = [];
     if bCollide == false
         break;
     end
 end
 
 %for each slot line, we estimate a parking slot region based on its type
 %and orientation

 slotCount = 0;
 for slotLineIdex = 1:size(candidateSlotLines,1)
     firstKP = keyPoints(candidateSlotLines(slotLineIdex,1),1:2);
     secKP = keyPoints(candidateSlotLines(slotLineIdex,2),1:2);
     scoreFirstKP = keyPoints(candidateSlotLines(slotLineIdex,1),3);
     scoreSecKP = keyPoints(candidateSlotLines(slotLineIdex,2),3);
     
     sideLength = 0;
     if candidateSlotLines(slotLineIdex,3) == 1
         sideLength = 140;
     elseif candidateSlotLines(slotLineIdex,3) == 2
         sideLength = 67.5;
     elseif candidateSlotLines(slotLineIdex,3) == 3
         sideLength = 75;
     end
     
     vectFromFirstToSecKP = secKP - firstKP;
     if candidateSlotLines(slotLineIdex,4) == 0 %the orientation is anti-clockwise
         directionVec = vectFromFirstToSecKP*[0 -1; 1 0];
         orientation = 1;
     else %the orientation is clockwise
         directionVec = vectFromFirstToSecKP*[0 1; -1 0];
         orientation = -1;
     end 
     directionVec = directionVec / norm(directionVec);
     thirdP = secKP + directionVec * sideLength;
     fourthP = firstKP + directionVec * sideLength;
     
     slotCount = slotCount + 1;
     slots(slotCount,:) = [firstKP secKP thirdP fourthP orientation];
 end
 slots(slotCount+1:10,:) = [];
 %for some slots, they may contradict with others. Here we will merge some
 %slots that conflicts with each other
 %At first, we need to decide whether the two slots intersect with each
 %other
 slotVerticesMat = zeros(4,2);
 while(true)
     bCollide = false;
     for slotIndex = 1:size(slots,1)-1
         P1Line1 = slots(slotIndex,1:2);
         P2Line1 = slots(slotIndex,3:4);
         P3Line1 = slots(slotIndex,5:6);
         P4Line1 = slots(slotIndex,7:8);
         for tmpIndex = slotIndex+1:size(slots,1)
             slotVerticesMat(:,1) = slots(tmpIndex,1:2:end-1);
             slotVerticesMat(:,2) = slots(tmpIndex,2:2:end-1);
             distToFourVertices = sum(abs(repmat(P1Line1,4,1) - slotVerticesMat),2);
             P1MinDist = min(distToFourVertices);
             distToFourVertices = sum(abs(repmat(P2Line1,4,1) - slotVerticesMat),2);
             P2MinDist = min(distToFourVertices);
             distToFourVertices = sum(abs(repmat(P3Line1,4,1) - slotVerticesMat),2);
             P3MinDist = min(distToFourVertices);
             distToFourVertices = sum(abs(repmat(P4Line1,4,1) - slotVerticesMat),2);
             P4MinDist = min(distToFourVertices);
             
             if P1MinDist + P2MinDist + P3MinDist + P4MinDist < 140
                 bCollide = true;
                 dist11Prime = sum(abs(P1Line1 - slots(tmpIndex,1:2)));
                 dist12Prime = sum(abs(P1Line1 - slots(tmpIndex,3:4)));
                 dist21Prime = sum(abs(P2Line1 - slots(tmpIndex,1:2)));
                 dist22Prime = sum(abs(P2Line1 - slots(tmpIndex,3:4)));
                 
                 if dist11Prime > 75 && dist12Prime > 75 && dist21Prime>75 && dist22Prime>75 
                     if dist11Prime>dist12Prime
                        slots(slotIndex,5:6) = slots(tmpIndex,1:2);
                        slots(slotIndex,7:8) = slots(tmpIndex,3:4);
                     else
                        slots(slotIndex,5:6) = slots(tmpIndex,3:4);
                        slots(slotIndex,7:8) = slots(tmpIndex,1:2);
                     end
                 end
                 slots(tmpIndex,:) = [];
             end
             if bCollide == true
                break;
             end
         end
         if bCollide == true
                break;
         end
     end
     if bCollide == false
         break;
     end
 end

 %for automobile control resons, we only need to return one 
  if isempty(slots)
     finalSlot = [];
     return;
  end
 
finalSlot = slots(:,1:9); %all slots are returned
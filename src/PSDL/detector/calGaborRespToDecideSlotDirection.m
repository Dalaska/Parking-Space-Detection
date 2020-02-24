function [respAnticlock1, respAnticlock2, respClock1, respClock2, alongLineResp1, alongLineResp2] ...
              = calGaborRespToDecideSlotDirection(firstKP, secKP, gabor, ...
                                                                             halfGaussianWidth, image)

    %compute the Gabor response at anticlockwise directions
    vectFromFirstToSecKP = secKP(1:2) - firstKP(1:2);
    vectFromFirstToSecKP = vectFromFirstToSecKP / norm(vectFromFirstToSecKP);
%     theta = pi/2;
    unticlockWiseVec = vectFromFirstToSecKP*[0 -1; 1 0];
%     unticlockWiseVec = unticlockWiseVec / norm(unticlockWiseVec);
    gaborTestCenter = ceil(firstKP(1:2) + unticlockWiseVec * halfGaussianWidth);
    angle = atan((-unticlockWiseVec(2))/unticlockWiseVec(1));
    
    rotatedGabor = imrotate(gabor,angle/pi*180,'bilinear', 'crop');
    imgPatch = image(gaborTestCenter(2) - halfGaussianWidth:gaborTestCenter(2) + halfGaussianWidth, ...
                                   gaborTestCenter(1) - halfGaussianWidth:gaborTestCenter(1) + halfGaussianWidth);
    
    imgPatch = (imgPatch - mean2(imgPatch))/(0.000001+std(imgPatch(:)));
    respAnticlock1 = sum(sum(imgPatch.*rotatedGabor));
                            
    gaborTestCenter = ceil(secKP(1:2) +  unticlockWiseVec * halfGaussianWidth);
    imgPatch = image(gaborTestCenter(2) - halfGaussianWidth:gaborTestCenter(2) + halfGaussianWidth, ...
                                   gaborTestCenter(1) - halfGaussianWidth:gaborTestCenter(1) + halfGaussianWidth);
    imgPatch = (imgPatch - mean2(imgPatch))/(0.000001+std(imgPatch(:)));
    respAnticlock2 = sum(sum(imgPatch.*rotatedGabor));
    
     %compute the Gabor response at clockwise directions
    clockWiseVec = vectFromFirstToSecKP*[0 1; -1 0];
    gaborTestCenter = ceil(firstKP(1:2) + clockWiseVec * halfGaussianWidth);
    angle = atan((-clockWiseVec(2))/clockWiseVec(1));
    rotatedGabor = imrotate(gabor,angle/pi*180,'bilinear', 'crop');
    imgPatch = image(gaborTestCenter(2) - halfGaussianWidth:gaborTestCenter(2) + halfGaussianWidth, ...
                                   gaborTestCenter(1) - halfGaussianWidth:gaborTestCenter(1) + halfGaussianWidth);
    imgPatch = (imgPatch - mean2(imgPatch))/(0.000001+std(imgPatch(:)));
    respClock1 = sum(sum(imgPatch.*rotatedGabor));
                            
    gaborTestCenter = ceil(secKP(1:2) + clockWiseVec * halfGaussianWidth);
    imgPatch = image(gaborTestCenter(2) - halfGaussianWidth:gaborTestCenter(2) + halfGaussianWidth, ...
                                   gaborTestCenter(1) - halfGaussianWidth:gaborTestCenter(1) + halfGaussianWidth);
    imgPatch = (imgPatch - mean2(imgPatch))/(0.000001 + std(imgPatch(:)));
    respClock2 = sum(sum(imgPatch.*rotatedGabor));
    
       %compute the Gabor response along the direction of the line linking
       %KP1 and KP2
    angle = atan((-vectFromFirstToSecKP(2))/vectFromFirstToSecKP(1));
    rotatedGabor = imrotate(gabor,angle/pi*180,'bilinear', 'crop');
    gaborTestCenter = ceil(firstKP(1:2) + vectFromFirstToSecKP * halfGaussianWidth);
    imgPatch = image(gaborTestCenter(2) - halfGaussianWidth:gaborTestCenter(2) + halfGaussianWidth, ...
                                   gaborTestCenter(1) - halfGaussianWidth:gaborTestCenter(1) + halfGaussianWidth);
    imgPatch = (imgPatch - mean2(imgPatch))/(0.000001+std(imgPatch(:)));
    alongLineResp1 = sum(sum(imgPatch.*rotatedGabor));
    
    gaborTestCenter = ceil(secKP(1:2) + (-vectFromFirstToSecKP * halfGaussianWidth));
    imgPatch = image(gaborTestCenter(2) - halfGaussianWidth:gaborTestCenter(2) + halfGaussianWidth, ...
                                   gaborTestCenter(1) - halfGaussianWidth:gaborTestCenter(1) + halfGaussianWidth);
    imgPatch = (imgPatch - mean2(imgPatch))/(0.000001 + std(imgPatch(:)));
    alongLineResp2 = sum(sum(imgPatch.*rotatedGabor));
    
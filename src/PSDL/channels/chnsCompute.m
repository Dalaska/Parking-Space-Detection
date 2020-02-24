function chnsData = chnsCompute(I,acosTable)
% Compute channel features at a single scale given an input image.
[rows,cols] = size(I);
chnsData = single(zeros(rows/2,cols/2,8));
chnsData(:,:,1) = imresize(I,[rows/2 cols/2],'method','bilinear'); 

% % compute gradient magnitude channel
[M,O] = gradientMag(I,5,0.005,acosTable);
chnsData(:,:,2) = imresize(M, [rows/2 cols/2],'method','bilinear'); 

% compute gradient histgoram channels
H=gradientHist(M,O);
chnsData(:,:,3:8) = H; 
end


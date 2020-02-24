function pyramidData = chnsPyramid(I,acosTable)
% Compute channel feature pyramid given an input image.
% convert I to appropriate color space (or simply normalize)
    data=chnsCompute(I,acosTable); 
%     for i=1:10
%         data(:,:,i)=convTri(data(:,:,i),1); 
%     end
    data = convTri(data,1); 
    
%     for i=1:10
%          pyramidData(:,:,i)=imPad(data(:,:,i),[3 3],'replicate'); 
%     end
    pyramidData = imPad(data,[3 3],'replicate'); 
end
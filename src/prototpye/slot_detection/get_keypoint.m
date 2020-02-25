% use tample get line 
%A = imread('dst.bmp')
A = imread('canny.bmp')

%load('')
% display image
imshow(A)
imshow(gabor)


point_left = [17, 10];
point_right = [187, 10];

stride = 10

x = 10
y = 10
B = A(x:x+24,y:y+24)
imshow(B)
z = conv2(gabor,B)
z = corr2(gabor,B)
% for x = 10:170
%     z = gabor*B
% end
kernel = gabor
blurredImage = conv2(A, kernel, 'same');

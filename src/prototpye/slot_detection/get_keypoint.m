% use tample get line 
%scr = imread('dst.bmp')
src = imread('canny.bmp');

%load('')
% display image
%imshow(src)
%imshow(gabor)

% input: marker point
% output
pt1 = [17, 10];
pt2 = [187, 10];
stride = 10;

RGB = insertShape(src,'circle',[pt1(1) pt1(2) 2],'LineWidth',2); % center x,y, radius
RGB = insertShape(RGB,'circle',[pt2(1) pt2(2) 2],'LineWidth',2); % center x,y, radius

imshow(RGB)
[len,width] = size(src)


window_width
offset = 5

win_l = pt1[1]-5:pt1[1]+5
win_r = pt2[1]-5:pt2[1]+5
n = 30
scan = src(win_l,:)

for x = 1:len/10
    
end

src_tilt = imrotate(src,35,'bilinear');
imshowpair(scr,src_tilt,'montage')


% x = 10
% y = 10
% B = A(x:x+24,y:y+24)
% imshow(B)
% z = conv2(gabor,B)
% z = corr2(gabor,B)
% for x = 10:170
%     z = gabor*B
% end
% kernel = gabor
% blurredImage = conv2(A, kernel, 'same');

function J = imPad( I, pad, type )
% Pad an image along its four boundaries.
%
% Similar to Matlab's padarray, with the following differences:
%  (1) limited to padding along height and width
%  (2) input format allows for separate padding along each dimension
%  (3) padding values may be negative, in which case performs *cropping*
%  (4) optimized (speedup can be significant, esp. for small arrays)
%
% The amount of padding along each of the four boundaries (referred to as
% T/B/L/R) is determined by the parameter "pad" as follows:
%  if(numel(pad)==1): T=B=L=R=pad
%  if(numel(pad)==2): T=B=pad(1), L=R=pad(2)
%  if(numel(pad)==4): T=pad(1), B=pad(2), L=pad(3), R=pad(4)
%
% USAGE
%  J = imPad( I, pad, type )
%
% INPUTS
%  I      - [hxwxk] input image (single, double or uint8 array)
%  pad    - pad or crop amount: 1, 2, or 4 element vector (see above)
%  type   - pad value or 'replicate', 'symmetric', 'circular'
%
% OUTPUTS
%  J      - [T+h+B x L+w+R x k] padded image
%
% EXAMPLE
%  I=imread('peppers.png'); pad=[10 20]; type=50;
%  tic, J1=imPad(I,pad,type); toc
%  tic, J2=padarray(I,pad,type,'both'); toc
%  figure(1); im(J1); isequal(J1,J2)
%
% See also padarray
%
% Piotr's Computer Vision Matlab Toolbox      Version 3.00
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

% J = imPadMex( I, pad, type );

%%% OLD Matlab code - slower (although still faster than padarray)
[h,w,~]=size(I); 
p=zeros(1,4); 
k=length(pad);
if(k==1)
    p=[pad pad pad pad]; 
elseif(k==2) 
    p=[pad(1) pad(1) pad(2) pad(2)]; 
end

if( strcmp(type,'replicate') )
  rs = [uint32(ones(1,p(1))) 1:h h*ones(1,p(2))];
  cs = [uint32(ones(1,p(3))) 1:w w*ones(1,p(4))];
elseif( strcmp(type,'symmetric') )
  rs = uint32([1:h h:-1:1]); rs=rs(mod(-p(1):h+p(2)-1,2*h)+1);
  cs = uint32([1:w w:-1:1]); cs=cs(mod(-p(3):w+p(4)-1,2*w)+1);
elseif( strcmp(type,'circular') )
  rs = uint32(1:h); rs=rs(mod(-p(1):h+p(2)-1,h)+1);
  cs = uint32(1:w); cs=cs(mod(-p(3):w+p(4)-1,w)+1);
end
J = I(rs,cs,:);

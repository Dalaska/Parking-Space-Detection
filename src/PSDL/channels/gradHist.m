function [O0,O1,M0,M1] = gradHist( M,O)

% sInv = 1/bin/bin;
% oMult = nOrients/pi;
% oMult = 1.909859317102744;
o = O.*	1.909859317102744;
O0 = fix(o);
od = o - O0;
% [i,j,~] = find(O0>=oMax);
% O0(i,j) = 0;
indicator = O0>=6;
O0(indicator) = 0;

O1 = O0+1;
% [a,b,~] = find(O1>=oMax);
% for i = 1 : size(a,1)
%     O1(a(i),b(i)) = 0;
% end
indicator = O1>=6;
O1(indicator) = 0;

m = M.*0.25;
M1 = od.*m;
M0 = m - M1;








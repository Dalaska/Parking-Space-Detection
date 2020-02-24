function [M,O] = gradientMag( I, normRad, normConst,acosTable)
% Compute gradient magnitude and orientation at each image location.
%     Compute gradients [Gx,Gy] with the maximum squared magnitude M2
    [rows,cols]=size(I);
    acMult=10000;
    Gx=zeros(rows,cols);
    Gy=zeros(rows,cols);
   
    Gx(:,2:cols-1)=0.5*(I(:,3:cols)-I(:,1:cols-2));
    Gy(2:rows-1,:)=0.5*(I(3:rows,:)-I(1:rows-2,:));
    Gx(:,1)=I(:,2)-I(:,1);
    Gx(:,cols)=I(:,cols)-I(:,cols-1);
    Gy(1,:)=I(2,:)-I(1,:);
    Gy(rows,:)=I(rows,:)-I(rows-1,:);
    Gy(2:rows-1,1)=0.5*(I(3:rows,1)-I(1:rows-2,1));
    Gy(2:rows-1,cols)=0.5*(I(3:rows,cols)-I(1:rows-2,cols));
    Gx(1,2:cols-1)=0.5*(I(1,3:cols)-I(1,1:cols-2));
    Gx(rows,2:cols-1)=0.5*(I(rows,3:cols)-I(rows,1:cols-2));

    M2=Gx.^2 + Gy.^2;
        
    % Compute gradient magnitude M and normalize Gx
    M=single(max(sqrt(M2),1e-10));
    Gx=acMult*(Gx./M);
    Gx=((-2).*(Gy<=0)+1).*Gx;
    
    % Construct acos[] to store cos-theta pairs
%     n=10000;
%     b=10;
%     acosTable=zeros(n*2+b*2,1);
%     offset=n+b+1; % Array begin from 1 in Matlab
% 
%     acosTable(-n-b+offset:-n-1+offset)=pi;
%     acosTable(-n+offset:n-1+offset)=real(acos((-n:n-1)/n));
%     acosTable(n+offset:n+b-1+offset)=0;
%          
%     indicator = acosTable(-n-b+offset:n/10-1+offset) > pi-1e-6;
%     acosTable(indicator) = pi-1e-6;
    
    % Compute gradient orientation O 
    offset = 10011;
    O = acosTable(round(Gx)+offset);
    S = convTri( M, normRad );
    M=M./(S + normConst);
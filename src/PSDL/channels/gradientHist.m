function H = gradientHist(M, O)
% Compute oriented gradient histograms.
    [w,h] = size(M);
    [O0,O1,M0,M1] = gradHist(M,O);
    H = single(zeros(w/2,h/2,6));
    sizeH1 = size(H,1)-1;
    hBinSize = h/2-1;
    halfBinsize = 1;

    xb = -0.25;
    for i=1:h
        if(xb>=0)
            hasLf = 1;
           xb0 = fix(xb);
        else
            hasLf = 0;
           xb0 = -1;
        end
        if(xb0 < hBinSize)
            hasRt = 1;
        else
            hasRt = 0;
        end
        xd = xb - xb0;
        xb = xb + 0.5;
        yb = -0.25;
        for y=1:w
            if (y<=halfBinsize)
                yb0=-1;
                yd = yb - yb0; 
                yb = yb + 0.5; 
                xyd = xd*yd;
                ms1 = yd-xyd;
                if(hasLf)
                    H(yb0+2,xb0+1,O0(y,i)+1) = H(yb0+2,xb0+1,O0(y,i)+1) + ms1 * M0(y,i);
                    H(yb0+2,xb0+1,O1(y,i)+1) = H(yb0+2,xb0+1,O1(y,i)+1) + ms1 * M1(y,i);
                end
                if(hasRt)
                    H(yb0+2,xb0+2,O0(y,i)+1) = H(yb0+2,xb0+2,O0(y,i)+1) + xyd * M0(y,i);
                    H(yb0+2,xb0+2,O1(y,i)+1) = H(yb0+2,xb0+2,O1(y,i)+1) + xyd * M1(y,i);
                end
            else
                yb0 = fix(yb);
                if(yb0 < sizeH1)
                    yd = yb - yb0; yb = yb + 0.5; xyd = xd*yd;
                    ms1 = 1-xd-yd+xyd;
                    ms2 = yd-xyd;
                    ms3 = xd-xyd;
                    if(hasLf)
                            H(yb0+1,xb0+1,O0(y,i)+1) = H(yb0+1,xb0+1,O0(y,i)+1) + ms1 * M0(y,i);
                            H(yb0+2,xb0+1,O0(y,i)+1) = H(yb0+2,xb0+1,O0(y,i)+1) + ms2 * M0(y,i);
                            H(yb0+1,xb0+1,O1(y,i)+1) = H(yb0+1,xb0+1,O1(y,i)+1) + ms1 * M1(y,i);
                            H(yb0+2,xb0+1,O1(y,i)+1) = H(yb0+2,xb0+1,O1(y,i)+1) + ms2 * M1(y,i);
                    end
                    if(hasRt)
                            H(yb0+1,xb0+2,O0(y,i)+1) = H(yb0+1,xb0+2,O0(y,i)+1) + ms3 * M0(y,i);
                            H(yb0+2,xb0+2,O0(y,i)+1) = H(yb0+2,xb0+2,O0(y,i)+1) + xyd * M0(y,i);
                            H(yb0+1,xb0+2,O1(y,i)+1) = H(yb0+1,xb0+2,O1(y,i)+1) + ms3 * M1(y,i);
                            H(yb0+2,xb0+2,O1(y,i)+1) = H(yb0+2,xb0+2,O1(y,i)+1) + xyd * M1(y,i);
                    end
                else
                    yd = yb - yb0; yb = yb + 0.5; xyd = xd*yd;
                    ms1 = 1-xd-yd+xyd;
                    ms2 = xd-xyd;
                    if(hasLf)
                        H(yb0+1,xb0+1,O0(y,i)+1) = H(yb0+1,xb0+1,O0(y,i)+1) + ms1 * M0(y,i);
                        H(yb0+1,xb0+1,O1(y,i)+1) = H(yb0+1,xb0+1,O1(y,i)+1) + ms1 * M1(y,i);
                    end
                    if(hasRt)
                        H(yb0+1,xb0+2,O0(y,i)+1) = H(yb0+1,xb0+2,O0(y,i)+1) + ms2 * M0(y,i);
                        H(yb0+1,xb0+2,O1(y,i)+1) = H(yb0+1,xb0+2,O1(y,i)+1) + ms2 * M1(y,i);
                    end
                end
            end
        end
        
    end

% if(mod(softBin,2) ~= 0 )
    H(1,:,:) = H(1,:,:).*(8/7);
    H(:,1,:) = H(:,1,:).*(8/7);
    H(size(H,1),:,:) = H(size(H,1),:,:).*(8/7);
    H(:,size(H,2),:) = H(:,size(H,2),:).*(8/7);
% end
%   H = single(H);

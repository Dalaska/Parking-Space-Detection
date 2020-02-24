function bbs = bbNms( bbs, overlap )
% Bounding box (bb) non-maximal suppression (nms).
%
% type=='max': nms of bbs using area of overlap criteria. For each pair of
% bbs, if their overlap, defined by:
%  overlap(bb1,bb2) = area(intersect(bb1,bb2))/area(union(bb1,bb2))
% is greater than overlap, then the bb with the lower score is suppressed.
% In the Pascal critieria two bbs are considered a match if overlap>=.5. If
% ovrDnm='min', the 'union' in the above formula is replaced with 'min'.
%
% type=='maxg': Similar to 'max', except performs the nms in a greedy
% fashion. Bbs are processed in order of decreasing score, and, unlike in
% 'max' nms, once a bb is suppressed it can no longer suppress other bbs.
%
% type='cover': Perform nms by attempting to choose the smallest subset of
% the bbs such that each remaining bb is within overlap of one of the
% chosen bbs. The above reduces to the weighted set cover problem which is
% NP but greedy optimization yields provably good solutions. The score of
% each bb is set to the sum of the scores of the bbs it covers (the max can
% also be used). In practice similar to 'maxg'.
%
% type=='ms': Mean shift nms of bbs with a variable width kernel. radii is
% a 4 element vector (x,y,w,h) that controls the amount of suppression
% along each dim. Typically the first two elements should be the same, as
% should the last two. Distance between w/h are computed in log2 space (ie
% w and w*2 are 1 unit apart), and the radii should be set accordingly.
% radii may need to change depending on spatial and scale stride of bbs.
%
% Although efficient, nms is O(n^2). To speed things up for large n, can
% divide data into two parts (according to x or y coordinate), run nms on
% each part, combine and run nms on the result. If maxn is specified, will
% split the data in half if n>maxn. Note that this is a heuristic and can
% change the results of nms. Moreover, setting maxn too small will cause an
% increase in overall performance time.
%
% Finally, the bbs are optionally resized before performing nms. The
% resizing is important as some detectors return bbs that are padded. For
% example, if a detector returns a bounding box of size 128x64 around
% objects of size 100x43 (as is typical for some pedestrian detectors on
% the INRIA pedestrian database), the resize parameters should be {100/128,
% 43/64, 0}, see bbApply>resize() for more info.
%
% USAGE
%  bbs = bbNms( bbs, [varargin] )
%
% INPUTS
%  bbs        - original bbs (must be of form [x y w h wt bbType])
%  varargin   - additional params (struct or name/value pairs)
%   .type       - ['max'] 'max', 'maxg', 'ms', 'cover', or 'none'
%   .thr        - [-inf] threshold below which to discard (0 for 'ms')
%   .maxn       - [inf] if n>maxn split and run recursively (see above)
%   .radii      - [.15 .15 1 1] supression radii ('ms' only, see above)
%   .overlap    - [.5] area of overlap for bbs
%   .ovrDnm     - ['union'] area of overlap denominator ('union' or 'min')
%   .resize     - {} parameters for bbApply('resize')
%   .separate   - [0] run nms separately on each bb type (bbType)
%
% OUTPUTS
%  bbs      - suppressed bbs
%
% EXAMPLE
%  bbs=[0 0 1 1 1; .1 .1 1 1 1.1; 2 2 1 1 1];
%  bbs1 = bbNms(bbs, 'type','max' )
%  bbs2 = bbNms(bbs, 'thr',.5, 'type','ms')
%
% See also bbApply, nonMaxSuprList
%
% Piotr's Computer Vision Matlab Toolbox      Version 2.60
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

% discard bbs below threshold and run nms1
if(isempty(bbs))
    bbs=zeros(0,5); 
    return; 
end

greedy = 1;
[~,ord] = sort(bbs(:,5),'descend'); 
bbs=bbs(ord,:);
n=size(bbs,1); 
kp=true(1,n); 
as=bbs(:,3).*bbs(:,4);
xs=bbs(:,1); 
xe=bbs(:,1)+bbs(:,3); 
ys=bbs(:,2); 
ye=bbs(:,2)+bbs(:,4);
for i=1:n, 
    if(greedy && ~kp(i))
        continue; 
    end
    for j=(i+1):n
        if(kp(j)==0)
            continue; 
        end
        iw=min(xe(i),xe(j))-max(xs(i),xs(j)); 
        if(iw<=0)
            continue; 
        end
        ih=min(ye(i),ye(j))-max(ys(i),ys(j)); 
        if(ih<=0)
            continue; 
        end
        o=iw*ih; 
        u=min(as(i),as(j)); 
        o=o/u; 
        if(o>overlap)
            kp(j)=0; 
        end
    end
end
bbs=bbs(kp>0,:);
end

"""
get negative data
"""
import numpy as np
import glob 
import cv2
import random

img_files = glob.glob('C:/Users/DFTC_ZHANGDR/GitRepo/Parking-Space-Detection/data/ForMarkingPoints/*.bmp') # load mat file
count = 1
for img in img_files:
    src = cv2.imread(img)
    size = 18
    a = 20 # image size 600x600
    b = 580
    for m in range(10):
        x = int(round(random.uniform(a, b)))
        y = int(round(random.uniform(a, b)))
        try:
            patch = src[x - size: x + size, y - size: y + size]
            patch_name = 'neg_patch/'+img[-16:-4] +'-'+ str(count) + '.bmp'
            cv2.imwrite(patch_name, patch)  
            count = count+1
        except:
            print(count)   
pass
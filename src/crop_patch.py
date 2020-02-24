'''
crop image 
'''
import pandas as pd
import numpy as np
import cv2

img_file = '20161019-1-1.bmp'
img = cv2.imread('./ForMarkingPoints/20161019-1-1.bmp')
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
center = [[100,22]]
patch = img_gray[100:124,100:124]

# show image
cv2.imshow('patch', patch)  
cv2.waitKey(0)
cv2.destroyAllWindows()

# save image
cv2.imwrite('path_img.bmp', patch) 



df = pd.read_csv('marks.csv')
points = df.values
for i in range(len(points)):
    center = np.round(points[i])

pass
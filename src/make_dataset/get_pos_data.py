'''
crop image 
'''
import cv2
import pandas as pd
path = 'C:/Users/DFTC_ZHANGDR/GitRepo/Parking-Space-Detection/data/ForMarkingPoints//'
data = pd.read_csv('marks.csv')

pos_x = data['x']
pos_y = data['y']
file_name = data['file']

for n in range(len(pos_x)):
    img_path = path + file_name[n][:-4] + '.bmp'
    #print(img_path)
    src = cv2.imread(img_path)

    # get patch
    size = 18 # half size
    x = int(round(pos_x[n]))
    y = int(round(pos_y[n]))
    try:
        patch = src[x - size: x + size, y - size: y + size]
        patch_name = 'patch/'+file_name[n][:-4] +'-'+ str(n) + '.bmp'
        cv2.imwrite(patch_name, patch)      
    except:
        print(n)
"""
load mat file and save into a csv
"""
import scipy.io as scio
import numpy as np
import glob
import re 
#file_name = './ForMarkingPoints/20161019-1-1.mat'
mat_files = glob.glob('C:/Users/DFTC_ZHANGDR/GitRepo/Parking-Space-Detection/data/ForMarkingPoints/*.mat') # load mat file
points = [] # group mark points
for file_name in mat_files:
    print(file_name)
    data = scio.loadmat(file_name) # load mat file 

    # data name
    index = re.search('Points', file_name)
    data_name = file_name[index.regs[0][1]+1:]
    marks = data['marks'] # get data
    for i in range(len(marks)): # every roll is a parking space
        for j in range(len(marks[i])//2):
            points.append([data_name,marks[i][2*j],marks[i][2*j+1]]) 

np.savetxt('marks.csv', points, delimiter = ',', fmt='%s') # save csv


pass
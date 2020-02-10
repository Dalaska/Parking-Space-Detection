"""
load mat file and save into a csv
"""
import scipy.io as scio
import numpy as np
import glob
#file_name = './ForMarkingPoints/20161019-1-1.mat'
mat_files = glob.glob('./ForMarkingPoints/*.mat') # load mat file
points = [] # group mark points
for file_name in mat_files:
    print(file_name)
    data = scio.loadmat(file_name) # load mat file 
    marks = data['marks'] # get data
    for i in range(len(marks)): # every roll is a parking space
        for j in range(len(marks[i])//2):
            points.append([marks[i][2*j],marks[i][2*j+1]]) 

np.savetxt('marks.csv', points, delimiter = ',') # save csv


pass
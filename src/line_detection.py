import cv2
import matplotlib.pyplot as plt

# read image
src = cv2.imread('img/002.bmp')
print('Image dimensions:', src.shape)
plt.imshow(src)

# gray scale
gray = cv2.cvtColor(src, cv2.COLOR_BGR2GRAY)

cv2.imshow('src',src)
cv2.imshow('gray',gray)
cv2.waitKey()
cv2.destroyAllWindows()

pass
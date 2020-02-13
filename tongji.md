# PSDL 算法逻辑整理
main()
- 导入参数
 - 车位检测: slots = myDetect()
    - 图片预处理：
        - imgScaled (300x300)
    - 车位检测: slot = acfDect()
        - 角点检测 bb = acfDetect1()
        - 由 matlab代码生成的cpp
        - ACF (aggregate channel features) 检测角点
        - 输出bounding box nx5（x,y,长,宽, 置信度）
    - 车位检测 slots = estimateSlots()
        - 边线线检测 decideValidSlotLine
            - 通过 GaborResp 和 Gaussian template和 Gabor filter完成
            - rule-based 车位检测法，论文里有讲
             - 输出slots nx9(1:8为角点的x,y坐标)
- 可视化 imgWithSlotsDrawn = insertShape()
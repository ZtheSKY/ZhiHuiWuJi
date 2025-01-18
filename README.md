# 无极缩放

第一次参加FPGA比赛（全国大学生嵌入式芯片与系统设计竞赛——FPGA赛道），团队获得国家二等奖。选题为易灵思赛道，基于Ti60F225的无极缩放算法实现。

采用**HDMI输入输出**，固定为640\*480，输出可放大至2560\*1440。

## 作品实物图

![作品全貌图](/img/作品全貌图.jpg) 

![开发板高清图](/img/开发板高清图.jpg) 

## 框图

作品框图：

![作品框图](/img/作品框图2.svg) 

算法图：

![算法图](/img/算法图.png) 


## 主要创新点


1. 可以实现320\*240至2560\*1440范围内**任意尺寸，任意比例**的实时缩放显示
2. 使用**STM32单片机**及对应**LVGL图形库**创建用户友好的人机交互界面，支持**配置参数、长按控制和滑动条控制**三种控制模式
3. 单片机与FPGA之间**自定义通信协议**
4. 可对图像进行**局部放大**，实现“放大镜”功能

## To Be Continued...
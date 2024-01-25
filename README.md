# Smooth Bug fix

## 问题描述
> 打开BarWindow - 快递接单 - 弹出委托UI - 点击定位 - 返回  在这之后就没有`BarWindow`页面UI了，这显然不符合逻辑。

## 解决方案
创建一个双端队列，这个队列的大小固定为2

每一个Open、Close的操作都会进行出入队列，我们不用管，根据经验观察，

在打开了bar之后，如果此时此刻Close的是NewMapUI，那么在他之前，就一定会关闭BarWindow。

所以在此就要检查：队列中两个元素是否相邻，如果是，就要把`in_bar`置为true。

所以在关闭MissionWindow之时，就要打开BarWindow。这样才能保证玩家退出去之后，仍然能够退回BarWindow界面







# Issue page

+ Frozen frames in dungeon
+ Stuck in the middle of the road on situations
+ mp3？








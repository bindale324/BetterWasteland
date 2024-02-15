# Smooth Bug fix

## 问题描述
> 打开BarWindow - 快递接单 - 弹出委托UI - 点击定位 - 返回  在这之后就没有`BarWindow`页面UI了，这显然不符合逻辑。

## 解决方案
创建一个双端队列，这个队列的大小固定为2

每一个Open、Close的操作都会进行出入队列，我们不用管，根据经验观察，

在打开了bar之后，如果此时此刻Close的是NewMapUI，那么在他之前，就一定会关闭BarWindow。

所以在此就要检查：队列中两个元素是否相邻，如果是，就要把`in_bar`置为true。

所以在关闭MissionWindow之时，就要打开BarWindow。这样才能保证玩家退出去之后，仍然能够退回BarWindow界面

## 问题描述

> 有一些制作出来的Food，第一次设置了`禁止自动进食`的，这个时候没有问题。
>
> 但是在主动投喂给角色之后，这种菜耗光了之后：
>
> 第二次制作出来这种菜的时候，就还是`未禁止`状态。这个时候还需要玩家手动设置一遍 `禁止自动进食`
>
> 这让玩家非常难受，不想再手动挨个点一次。
>
> 如果要禁止自动进食，那么同理，就应该是持续上锁状态，玩家主动解锁才能奏效。
>
> 也就是说：再一次制作出来这种菜的时候，同样应该是自动上锁状态。

## 解决方案

`MainUI.AutoEat`  这个是一个bool值，用来说明在MainUI里面，是否打开自动进食。现在就是要找到底是谁访问了它？

+ Lua里面没法手动构造一个`Food`类出来，所以食物数据的来源全在`OnEat`方法。
  + 在`OnEat()`方法中，手动记录每一个吃过的食物。
  + 查询这个食物，是否是`禁止自动进食`状态。
    + 如果是，将食物的ID加入一个有序链表中。
    + 如果不是，在有序链表中查找：
      + 如果找到了，就移除出去，因为这个时候表示解锁了。不可以存在在这个链表中。
+ 在`OnCook()`方法中，对于制作出来的食物`result`进行遍历：
  + 如果食物存在于这个链表中，说明是禁用状态，调用`item.Characteristic:Add("ItemBuff_DontAutoEat", 0);`方法给他上锁



开关禁用的操作，应该在“仓库管理”这个里面能够找到。

找东西的思路：应该是在`MainUI`里面开始找，层层往下找。

在`WareHouseWindow`里面，Items有一个属性叫`Characteristic:ContainsKey("ItemBuff_DontAutoEat")`



整体思路采用`二分`方法处理整个过程，算法复杂度为`O(logn)`。

## 问题描述
在交易的时候，会交易高品质的东西

应该要把所有物品进行排序，优先交易低品质的东西才行。

## 解决方案
call stack:
+ TradeAction -> SynthesisController.SynthesisCost -> ItemManager.DiscardGoods(id, count)

在DiscardGoods中，while循环的逻辑有问题，重写整个方法，重点关注while循环中的迭代逻辑。

## 问题描述
旅行者事件，选择了一个选项之后，再退出来的时候，什么都没有了，这显然是不合理的。

坦克营地 - 【旅行者】 - 有很多选项


## 解决方案

在OnEvent（旅行者）的时候，就标记flag为true。
在OnEvent（交易废品）的时候，如果前面的flag为true，那么flag2也为true，记录一下零钱的数量。
在OnCloseUI（交易废品）的时候，如果前两个的flag都为true，**并且零钱没减少**，首先把前两个的都记为false，然后再启动事件【旅行者】

在OnEvent（聊天）的时候，如果前面的flag为true，就标记flag2为true。记录一下时间。
在OnCloseUI（聊天）的时候，如果前面两个flag窦唯true，并且时间**没减少**，把前两个记为false，然后再启动事件【旅行者】


# Other Issue page

+ Frozen frames in dungeon
+ Stuck in the middle of the road on situations
+ trade issue
+ 每次点开各种UI的时候都会卡，这个要探究一下原因







*本工具箱已停止功能性更新，仅修复bug*

# iReader-Crack 工具箱

iReader Plus、Light、Ocean 与 T6 阅读器破解，支持最新系统（截至4月底）

Plus建议降级以使用蓝牙听书功能：[教程](https://www.einkfans.com/thread-60.htm)

目前支持 Linux 系统进行破解，推荐 Ubuntu，支持 Windows 10 Linux 子系统

macOS 系统及部分虚拟机暂不兼容，部分 Windows 版本可能无法正常使用 WSL

欢迎加入 QQ 群组了解详情，群号码：120581715，验证消息：ireaderFans

近期将上线 FAQ 常见问题解答

## 协议

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/cn/"><img alt="知识共享许可协议" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/3.0/cn/88x31.png" /></a><br />本作品采用<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/cn/">知识共享署名-非商业性使用-禁止演绎 3.0 中国大陆许可协议</a>进行许可。

## 使用方法

### 首次加载

```
git clone https://github.com/KazushiMe/iReader-Crack.git
```

### 运行

1. 终端:

```
./iReader-Crack/crack.sh
```

2. 按程序提示操作

3. 完成后可以……

安装程序、设置主屏幕

开启root后[安装Xposed框架](https://www.einkfans.com/thread-51.htm)

*若出现无法更新的情况请删除程序重新加载*

```
rm -rf ./iReader-Crack
```

### 更新或恢复

1.	获取官方OTA（在系统更新下载，不要安装）

```
adb pull /sdcard/adupsfota/update.zip ~
```

解压用户主目录下的 update.zip 得到*真正的* update.zip

2.	对 update.zip 包进行修改，删除 update.zip 下的 recovery 文件夹及 boot.img（防止更新封堵破解）

3.	打开 zip 包内 META-INF>com>google>android>updater-script，修改文件：

```
删除 首行 (!less_than…… 的版本校验
删除 更新recovery 的命令
删除 更新boot.img 的命令
删除 build.prop校验 的命令
```

保存后在zip包内替换原文件

4.	按程序提示操作

[更新包资源](https://www.einkfans.com/thread-2.htm)

### 视频教程

*原生 Linux 教程*：[iReader阅读器开启adb教程](https://www.bilibili.com/video/av21532543/)  by 愿乘风归去

Windows 10 版请等待更新

## 原理

iReader官方请的工程师，连Recovery的adb都忘关了……

新品T6还是没改……

清空数据进入Recovery➡加入adb（改build.prop）➡强制开启adb（否则会被阅读器主程序关闭）

## 捐赠

#### 如果觉得我的作品对您有帮助，可以请我喝一杯咖啡。

微信扫描：

![iReader-Crack 捐赠](https://www.einkfans.com/upload/attach/201804/123_Y8UU2HF3MAJUKU8.jpg)

## 鸣谢

之前所有参与过内测、提供建议的朋友


| 捐赠时间 | 留言 | 金额 | 
| - | :-: | -: | 
| 2018/04/24 14:43 | 无 | ￥10.00

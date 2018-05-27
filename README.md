# iReader-Crack 工具箱

### 导航

* [协议](#协议)

* [使用方法](#使用方法)

  * [首次加载](#首次加载)
  
  * [运行](#运行)
  
  * [破解后的操作](#破解后的操作)
  
  * [更新或恢复](#更新或恢复)
  
  * [视频教程](#视频教程)
  
* [WSL环境配置](#wsl环境配置)

* [原理](#原理)

* [捐赠](#捐赠)

* [鸣谢](#鸣谢)

iReader Plus、Light、Ocean 与 T6 阅读器破解，支持最新系统（截至5月）

Plus 新系统版本需降级以使用蓝牙听书功能：[教程](https://www.einkfans.com/thread-60.htm)

Plus 与 0027 及之前版本的 Light 建议使用 [iReaderHelper](https://www.ireaderfans.com/jiaocheng) 工具

目前支持 Linux 系统进行破解，推荐 Ubuntu，支持 Windows 10 Linux 子系统

macOS 系统及部分虚拟机暂不兼容，部分 Windows 版本可能无法正常使用 WSL

破解后无法使用 OTA 更新，需要[手动更新](#更新或恢复)或返厂

欢迎加入 QQ 群组了解详情，群号码：120581715，验证消息：ireaderFans

## 协议

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/cn/"><img alt="知识共享许可协议" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/3.0/cn/88x31.png" /></a><br />本作品采用<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/cn/">知识共享署名-非商业性使用-相同方式共享 3.0 中国大陆许可协议</a>进行许可。

## 使用方法

### 首次加载

如果使用 Windows 环境请先执行 [相关操作](#wsl环境配置)

```
git clone https://github.com/KazushiMe/iReader-Crack.git
```

### 运行

1. 终端:

   ```
   ./iReader-Crack/crack.sh
   ```

2. 按程序提示操作

**若出现无法更新的情况请删除程序重新加载**

```
rm -rf ./iReader-Crack
```

**如果无法破解请检查连接问题，尝试其他方案**

### 破解后的操作

1.  安装程序、设置主屏幕

    启动器推荐: [E-Ink Launcher](https://www.coolapk.com/apk/cn.modificator.launcher)
    
    使用方法: 安装 → 打开设置 → 主屏幕 → 选定E-Ink Launcher
    
    如对 root 无要求的用户可以使用 [EasyTouch](https://www.coolapk.com/apk/com.shere.easytouch) 进行模拟键操作

2.  开启root后可[安装Xposed框架](https://www.einkfans.com/thread-51.htm)，并可使用自定义化程度更高的 Xposed Edge Pro


### 更新或恢复

**目前仅支持完整包更新（约200MB），不支持增量包**

1.	获取官方OTA（在系统更新下载，不要安装）

   ```
   adb pull /sdcard/adupsfota/update.zip ~
   ```

   解压用户主目录下的 update.zip 得到**真正的** update.zip

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

**原生 Linux 教程**：[iReader阅读器开启adb教程](https://www.bilibili.com/video/av21532543/)  by 愿乘风归去

Windows 10 版请等待更新

## WSL环境配置

1. 确保使用 1709 及以上版本系统

2. 如图所示进行配置

   ![WSL1](https://raw.githubusercontent.com/KazushiMe/iReader-Crack/master/pic/WSL1.png)

3. 安装好 Windows 的 adb 驱动及程序包（放入 System32 或 SysWow64）

4. 先打开 Windows 的 adb server，再打开 WSL，运行工具箱

   ![WSL2](https://raw.githubusercontent.com/KazushiMe/iReader-Crack/master/pic/WSL2.png)

**注：使用360等防护软件可能无法正常使用WSL破解方案**

## 原理

iReader官方请的工程师，连Recovery的adb都忘关了……

新品T6还是没改……

清空数据进入Recovery → 加入adb（改build.prop） → 强制开启adb（否则会被阅读器主程序关闭）

## 捐赠

**如果觉得我的作品对您有帮助，可以请我喝一杯咖啡。**

微信扫描：

![iReader-Crack 捐赠](https://kazushime.github.io/file/pic/WeChat_Donate.jpg)

## 鸣谢

之前所有参与过内测、提供建议的朋友

[捐赠记录](https://github.com/KazushiMe/iReader-Crack/wiki/捐赠记录-%7C-Donation)

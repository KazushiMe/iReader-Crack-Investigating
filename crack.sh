#!/bin/bash

version="r22"
update="r22 修复程序更新问题，优化破解\nr21 高亮注意事项，修复自动版识别bug\nr20 优化破解逻辑\nr19 修复WSL相关问题"

home=$(cd `dirname $0`; pwd)
chmod -R 777 $home
mv $home/log $home/log.last

if [[ $1 == "-debug" ]]; then
  logging=1
fi

function pause()
{
  if [ $1 ]; then
    read -n 1 -p "$1"
  else
    read -n 1 -p "按任意键继续"
  fi
}

function warning()
{
  echo -e "\033[31;5m$*\033[0m"
}

function log()
{
  if [ $logging ]; then
    time=`date "+%Y-%m-%d %H:%M:%S"`
    #8进制识别fix: 10#string
    time_ns=$((10#`date "+%N"`))
    time_us=$((10#$time_ns / 1000))
    time_us_formatted=" "`printf "%06d\n" $time_us`
    time_formatted=${time}${time_us_formatted}
    echo "$time_formatted  $*"
  fi
  echo "$time_formatted    $*" >> $home/log
}

function stage()
{
  echo ""
  echo "第 $1 阶段: $2"
  log "========== Stage $1 : $2 =========="
}

function init()
{
  echo "正在检测环境……"
  issue=`cat /etc/issue`
  adb_exec=`which adb`
  if [[ ${issue:0:6} != "Ubuntu" ]]; then
    warning "当前使用的系统不是Ubuntu，可能不受支持"
    log "Not Ubuntu"
    pause
  fi
  if [[ ${adb_exec:0:1} != "/" ]]; then
    warning "未检测到adb程序"
    log "adb Not Found"
    if [[ ${issue:0:6} == "Ubuntu" ]]; then
      pause "按任意键执行安装，可能需要输入密码"
      log "adb Installing"
      sudo apt-get update
      sudo apt-get install adb
      init
      return
    else
      warning "请安装adb后再执行本程序"
      pause "按任意键退出"
      log "Need adb, exit"
      exit
    fi
  fi
  
  echo ""
  
  WSL=$(echo `uname -a` | grep -o "Microsoft" | wc -l)
  if [ $WSL -ge "1" ]; then
    WSL=true
    log "IS WSL Subsystem"
    echo "检测到使用 Windows 10 Linux 子系统"
    warning "请安装 Windows 的 adb 驱动，打开对应版本的 adb 程序"
    echo "所需adb版本: " `adb version | head -1`
    echo "Windows中命令行操作如下:"
    echo "adb kill-server"
    echo "adb start-server"
    echo "完成后不要关闭Windows的adb"
    pause
  else
    echo "初始化adb……"
    log "Initializing adb"
    adb kill-server
  fi
  adb start-server
  
  if [ $WSL ]; then
    data_dir="/mnt/d/iReader-Crack"
    echo_dir="Windows 系统 D:\\iReader-Crack\\"
  else
    data_dir="$home/data"
    echo_dir=$data_dir
  fi

  sleep 1
  
  if [[ $WSL ]]; then
    adb_error=`adb get-state 2>&1 > /dev/null` # 2>&1 stderr过滤器
    if [[ $adb_error ]]; then
      warning "请检查 WSL 子系统 与 Windows 的 adb 连接问题"
      echo "程序检测到错误，即将退出……"
      sleep 5
      exit
    fi
  fi
}

function adb_state()
{
  # unknown:0 device:1 recovery:2
  state=`adb get-state`
  if [[ $state == "device" ]]; then
    return 1
  elif [[ $state == "recovery" ]]; then
    return 2
  else
    return 0
  fi
}

function recovery()
{
  log "Copying Recovery Shell Files"
  adb push $home/crack/bin /system/bin/
  adb push $home/crack/lib /system/lib/
  adb shell "/system/bin/mount -t ext4 /dev/block/mmcblk0p5 /system"
  log "Mount /system Done"
  adb shell "echo 'persist.service.adb.enable=1' >> /system/build.prop"
  adb shell "echo 'persist.service.debuggable=1' >> /system/build.prop"
  adb shell "echo 'persist.sys.usb.config=mtp,adb' >> /system/build.prop"
  adb shell "echo 'ro.secure=0' >> /system/build.prop"
  adb shell "echo 'ro.adb.secure=0' >> /system/build.prop"
  adb shell "echo 'ro.debuggable=1' >> /system/build.prop"
  log "Build.prop Modified Successfully"
}

function enable_adb()
{
  log "Enabling Adb During Booting"
  start=`date +%s`
  while true
  do
    adb shell "echo 'mtp,adb' > /data/property/persist.sys.usb.config" 2>&1 > /dev/null
    adb shell "echo '1' > /data/property/persist.service.adb.enable" 2>&1 > /dev/null
    dif=`expr $(date +%s) - "$start"`
    if [ "$dif" -gt "60" ]; then
      break
    fi
  done
  #主程序会关闭adb，不得不循环破解
}

function enable_adb_2()
{
  log "Enabling Adb During Booting - Auto Approach"
  times=1
  while true
  do
    log "Loop Count: $times"
    adb shell "echo 'mtp,adb' > /data/property/persist.sys.usb.config"
    adb shell "echo '1' > /data/property/persist.service.adb.enable"
    adb_state
    if [[ $? == 0 ]]; then
      log "Connection Closed"
      break
    else
      log "Device State: $?"
    fi
    times=`expr $times + 1`
  done
  #主程序会关闭adb，不得不循环破解
}

function update()
{
  echo ""
  echo "正在检测更新……"
  cd $home
  git fetch --all
  git reset --hard origin/master
  git pull
  echo ""
  echo "更新完成"
  rm -rf "$home/updated"
  sleep 3
  $home/crack.sh;exit
}

function main()
{
  clear
  key=
  echo "           iReader Crack 工具箱"
  echo "                    $version"
  [[ $logging == 1 ]] && echo "               debug 已开启"
  adb_state
  if [[ $? == 1 ]]; then
    echo "              USB 调试已连接"
  elif [[ $? == 2 ]]; then
    echo "          已进入 Recovery 模式"
  fi
  echo ""
  echo "            1. 运行破解主程序（自动版）"
  echo ""
  echo "            2. 运行破解主程序（手动版）"
  echo ""
  echo "            3. 安装更新包（需修改）"
  echo ""
  echo "            4. 批量安装程序"
  echo ""
  echo "            5. 安装 root 与 Superuser"
  echo ""
  echo "   A. 打开设置  B. 模拟返回键  C. 模拟主页键"
  echo ""
  [[ $logging != 1 ]] && echo "            D. 开启 debug 模式"
  echo ""
  echo "            E. 更新工具箱"
  echo ""
  echo "            X. 退出"
  echo ""

  read -n 1 -p "请键入选项: " key
}

function crack()
{
  clear
  
  log "Version: "$version
  echo "     iReader 系列 阅读器 破解 手动版"
  stage "1" "使用前须知"
  
  warning "注意事项:"
  echo "1. 请确保安装好相关组件，包括adb及adb驱动"
  echo "2. 请严格按照程序提示操作，否则有可能变砖"
  echo "3. 操作前备份好用户数据(电纸书)"
  echo ""
  sleep 1
  pause
  log "Agreed"
  
  stage "2" "环境检测与准备"
  adb_state
  if [[ $? != 0 ]]; then
    echo ""
    warning "已连接开启USB调试的Android设备，请移除后重试"
    log "Already connected adb device"
    log `adb devices`
    pause
    crack
  fi
  sleep 1
  
  stage "3" "进入Recovery"
  echo "请按如下步骤操作："
  echo "1. 将iReader用数据线连接至电脑"
  echo "2. 阅读器上 选择 设置-->关于本机-->恢复出厂设置"
  echo "3. 等待出现机器人标识"
  echo ""
  pause "出现机器人标识时按任意键继续"
  
  echo ""
  echo "正在复制破解文件……"
  recovery
  
  echo "等待重启……"
  log "Waiting for Reboot"
  
  stage "4" "执行破解"
  echo ""
  echo "如果此步骤失败，请重新破解，在该步骤阅读器闪屏且出现 iReader 标识时立即重新插入数据线并回车"
  echo ""
  pause "显示进度条时按任意键继续"
  echo ""
  echo "预计需要1分钟，请耐心等待……"
  
  enable_adb
  
  echo ""
  echo "请手动重启阅读器"
  log "Waiting for Reboot Manually..."
  pause "重启进阅读器界面后按任意键继续"
  
  echo ""
  adb_state
  if [[ $? == 1 ]]; then
    echo "破解成功，现可以通过adb安装程序"
    log "Crack Done!"
  else
    warning "破解失败，请尝试重新破解或进行反馈"
    log "Crack Failed!"
    log `adb devices`
  fi
  pause "按任意键返回"
  return
}

function crack_auto()
{
  clear
  
  log "Version: "$version" Auto Approach"
  echo "     iReader 系列 阅读器 破解 自动版"
  stage "1" "使用前须知"
  
  warning "注意事项:"
  echo "1. 请确保安装好相关组件，包括adb及adb驱动"
  echo "2. 请严格按照程序提示操作，否则有可能变砖"
  echo "3. 操作前备份好用户数据(电纸书)"
  echo ""
  sleep 3
  
  stage "2" "环境检测与准备"
  adb_state
  if [[ $? != 0 ]]; then
    echo ""
    warning "已连接开启USB调试的Android设备，请移除后重试"
    log "Already connected adb device"
    log `adb devices`
    pause
    return
  fi
  sleep 1
  
  stage "3" "进入Recovery"
  echo "请按如下步骤操作："
  echo "1. 将iReader用数据线连接至电脑"
  echo "2. 阅读器上 选择 设置-->关于本机-->恢复出厂设置"
  echo "3. 等待出现机器人标识"
  echo ""
  echo "正在检测是否进入Recovery……"
  log "Checking Recovery"
  while true
  do
    adb_state
    if [[ $? == 2 ]]; then
      log "Recovery Mode"
      break
    fi
  done
  
  echo ""
  echo "正在复制破解文件……"
  recovery
  
  echo "等待重启……"
  log "Waiting for Reboot"
  
  stage "4" "执行破解"
  echo "等待系统重载……"
  echo "如果长时间停在此步骤，请重新破解，并在该步骤阅读器闪屏且出现 iReader 标识时立即重新插入数据线"
  sleep 1
  while true
  do
    adb_state
    if [[ $? == 1 ]]; then
      log "Have found adb device"
      break
    fi
  done
  
  enable_adb_2
  
  echo ""
  warning "请手动重启阅读器，可能需要重新插入数据线"
  log "Waiting for Reboot Manually"
  pause "重启进阅读器界面后按任意键继续"
  
  echo ""
  adb_state
  if [[ $? == 1 ]]; then
    echo "破解成功，现可以通过adb安装程序"
    log "Done"
  else
    warning "破解失败，请尝试重新破解或进行反馈"
    log "Failed"
    log `adb devices`
  fi
  pause "按任意键返回"
  return
}

function install_ota()
{
  echo ""
  stage "1" "准备阶段"
  adb_state
  if [[ $? == 0 ]]; then
    warning "未破解或未连接"
    pause "按任意键返回"
    return
  fi
  echo ""
  if [ ! -d "$data_dir" ]; then
    mkdir "$data_dir"
  fi
  warning "注意: 目前 OTA 更新包需要手动修改，近期因手动更新而变砖的案例较多，请三思而后行"
  echo ""
  echo "请按照教程获取OTA更新包并进行修改"
  echo "将修改后的更新包放入 $echo_dir 文件夹内，重命名为update.zip"
  pause
  if [ ! -f "$data_dir/update.zip" ]; then
    echo ""
    warning "更新包不存在"
    pause "按任意键返回"
    return
  fi
  stage "2" "安装更新"
  if [[ $? == 1 ]]; then
    echo "正在进入Recovery环境"
    adb reboot recovery
    sleep 5
    while true
    do
      sleep 0.1
      adb_state
      if [[ $? == 2 ]]; then
        break;
      fi
    done
  fi
  recovery
  adb shell "/system/bin/mount -t ext4 /dev/block/mmcblk0p6 /cache"
  echo ""
  echo "正在复制OTA更新包"
  adb push $data_dir/update.zip /cache/update.zip
  echo ""
  echo "正在安装更新"
  adb shell "/system/bin/recovery --update_package=/cache/update.zip"
  sleep 5
  adb_state
  if [[ $? != 2 ]]; then
    echo "更新成功"
  else
    warning "更新失败，请重新尝试"
  fi
  pause "按任意键返回"
  return
}

function install_apk()
{
  echo ""
  echo "请稍后……"
  adb_state
  if [[ $? != 1 ]]; then
    warning "未破解或未连接"
    pause "按任意键返回"
    return
  fi
  echo ""
  if [ ! -d "$data_dir" ]; then
    mkdir "$data_dir"
  fi
  echo "将需要安装的apk文件放入 $echo_dir 文件夹中"
  echo "建议使用英文命名"
  pause "按任意键开始安装"
  if [ ! -f "$data_dir/*.apk" ]; then
    echo ""
    echo "没有找到apk"
    pause "按任意键返回"
    return
  fi
  echo ""
  echo "正在安装……"
  cd "$data_dir"
  adb install *.apk
  echo "安装完成"
  return
}

function install_root()
{
  echo ""
  echo "请稍后……"
  adb_state
  if [[ $? != 1 ]]; then
    echo "未破解或未连接"
    pause "按任意键返回"
    return
  fi
  echo ""
  if [ ! -d "$data_dir" ]; then
    mkdir "$data_dir"
  fi
  echo "将SuperSU授权管理的apk文件放入 $echo_dir 文件夹中，命名为 Superuser.apk"
  echo "由于版权问题不自带SuperSU，可从群文件获取apk"
  pause "按任意键开始执行root"
  if [ ! -f "$data_dir/Superuser.apk" ]; then
    echo ""
    echo "没有找到SuperSU"
    pause "按任意键返回"
    return
  fi
  echo ""
  echo "正在执行root……"
  adb shell mount -o rw,remount /system
  adb push $home/crack/bin/su /system/xbin
  adb push $home/crack/bin/su /system/bin
  adb push $data_dir/Superuser.apk /system/app/
  adb shell chown 0.0 /system/xbin/su
  adb shell chmod 6755 /system/xbin/su
  adb shell chown 0.0 /system/bin/su
  adb shell chmod 6755 /system/bin/su
  adb shell su -d am start -a android.intent.action.MAIN -n eu.chainfire.supersu/.MainActivity
  echo ""
  echo "阅读器上选择：更新二进制文件-->常规方式-->重启"
  sleep 3
  echo ""
  echo "重启后请打开 SuperSU 检测root是否成功"
  pause "按任意键返回"
  return
}

function shortcut()
{
  echo ""
  echo "请稍后……"
  adb_state
  if [[ $? != 1 ]]; then
    warning "未破解或未连接"
    pause "按任意键返回"
    return
  fi
  echo ""
  if [[ $1 == "setting" ]]; then
    adb shell am start com.android.settings/com.android.settings.Settings
  elif [[ $1 == "back" ]]; then
    adb shell input keyevent 4
  elif [[ $1 == "home" ]]; then
    adb shell input keyevent 3
  fi
  echo "完成"
  return
}

clear
echo "iReader-Crack工具箱"
[[ $logging == 1 ]] && warning "debug 模式"
echo "Credit: Kazushi"
echo "本作品采用知识共享署名-非商业性使用-禁止演绎 3.0 中国大陆许可协议进行许可。"
echo "该工具箱完全免费，请在协议允许的范围内进行使用"
echo ""
echo "详细使用方法请访问: https://github.com/KazushiMe/iReader-Crack/"
if [ ! -f "$home/updated" ]; then
  echo ""
  echo "近期更新日志："
  echo -e "$update"
  echo "" > "$home/updated"
fi
sleep 3
echo ""
pause "按任意键启动工具箱"
clear
init
while true
do
  main
  case $key in
    1)      crack_auto;;
    2)      crack;;
    3)      install_ota;;
    4)      install_apk;;
    5)      install_root;;
    a|A)    shortcut "setting";;
    b|B)    shortcut "back";;
    c|C)    shortcut "home";;
    D|d)    $home/crack.sh -debug; exit;;
    E|e)    update;;
    X|x)    clear; exit;;
    *)
    echo ""
    echo "输入错误，请重新尝试"
    sleep 1
    ;;
  esac
done

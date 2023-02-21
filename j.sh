#!/bin/bash
# jjapp操作脚本

# 包括服务备份，缓存清理，日志清理，开启BBR

echo "===----J-SH脚本----==="
echo "输入命令(使用help查看帮助)"

helpText="
1.help 查看帮助
2.backup 全量备份
3.clean 清理缓存
4.purge 清理日志
5.bbr 开启BBR
6.cli 打开ApolloCLI
7.cd 进入微服务目录
8.conf 显示配置
9.set 设置配置
10.init 初始化配置
"

# 配置文件目录及文件
JSH="$HOME/.jsh"
JSH_APP_ROOT="$JSH/app_root.jshc"
JSH_CACHE_ROOT="$JSH/app_cache.jshc"
JSH_LOG_ROOT="$JSH/app_log.jshc"
JSH_BACK_ROOT="$JSH/app_back.jshc"

arg=$1

case $arg in
"help"|1)
  echo "$helpText"
  exit
  ;;
"backup"|2)
  app_root=$(cat "${JSH_APP_ROOT}")
  backup_root=$(cat "${JSH_BACK_ROOT}")
  echo "服务目录: $app_root 备份目录: $backup_root"
  if [ -z "$app_root" ];then
    echo "服务目录未设置"
    exit 1
  fi
  if [ -z "$backup_root" ];then
    echo "备份目录未设置"
    exit 1
  fi
  if [ ! -d "$backup_root" ];then
    echo "创建备份目录: $backup_root"
    mkdir -p "$backup_root"
  fi
  echo "使用tar进行备份"
  echo -n "开始备份[y/n]"
  read -r i
  if [ "$i" == "y" ] || [ "$i" == "Y" ] || [ "$i" == "yes" ];then
    prefix=$(date +"%Y-%m-%d")
    tar -cvf "$backup_root/apps-$prefix.tar" --exclude=log --exclude=cache --exclude=mgekfile --exclude=backup --exclude=tmp --exclude=*.pyc "$app_root"
  else
    echo "退出"
  fi
  ;;
"clean"|3)
  app_cache=$(cat "${JSH_CACHE_ROOT}")
  echo "缓存目录: $app_cache"
  if [ -z "$app_cache" ];then
    echo "缓存目录未设置"
    exit 1
  fi
  if [ ! -d "$app_cache" ];then
    echo "缓存目录不存在"
    exit 1
  fi
  rm -r "${app_cache:?}/*"
  echo "缓存清理完毕"
  ;;
"purge"|4)
  log_root=$(cat "$JSH_LOG_ROOT")
  echo "日志目录: $log_root"
  if [ -z "$log_root" ];then
    echo "日志目录未设置"
    exit 1
  fi
  if [ ! -d "$log_root" ];then
    echo "日志目录不存在"
    exit 1
  fi
  rm -r "${log_root:?}/*"
  ;;
"bbr"|5)
  echo "uname: $(uname -a)"
  res=$(cat /etc/sysctl.conf | grep bbr)
  if [ -n "$res" ];then
    echo "BBR已经开启"
  else
    echo "BBR未开启 准备配置"
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    echo "配置完毕 准备重载"
    sysctl -p
    echo "测试中"
    lsmod | grep bbr
    echo "结束"
  fi
  ;;
"cli"|6)
  apollocli
  ;;
"cd"|7)
  ;;
"conf"|8)
  echo "读取配置"
  echo "存储路径${JSH}"
  echo "APP_ROOT: $(cat "${JSH_APP_ROOT}")"
  echo "APP_BACK_ROOT: $(cat "${JSH_BACK_ROOT}")"
  echo "APP_CACHE_ROOT: $(cat "${JSH_CACHE_ROOT}")"
  echo "APP_LOG_ROOT: $(cat "${JSH_LOG_ROOT}")"
  ;;
"set"|9)
  echo "开始配置"
  echo "存储路径${JSH}"
  echo -n "请输入APP_ROOT: "
  read -r i
  if [ -z "$i" ];then
    echo "输入为空"
    exit 1
  else
    echo "$i" > "${JSH_APP_ROOT}"
  fi

  echo -n "请输入APP_BACK_ROOT: "
  read -r i
  if [ -z "$i" ];then
    echo "输入为空"
    exit 1
  else
    echo "$i" > "${JSH_BACK_ROOT}"
  fi

  echo -n "请输入APP_CACHE_ROOT: "
  read -r i
  if [ -z "$i" ];then
    echo "输入为空"
    exit 1
  else
    echo "$i" > "${JSH_CACHE_ROOT}"
  fi

  echo -n "请输入APP_LOG_ROOT: "
  read -r i
  if [ -z "$i" ];then
    echo "输入为空"
    exit 1
  else
    echo "$i" > "${JSH_LOG_ROOT}"
  fi
  ;;
"init"|10)
  echo "开始初始化配置"
  echo "存储路径${JSH}"
  if [ ! -d "${JSH}" ];then
    mkdir "${JSH}"
  fi
  echo "默认APP_ROOT: /renj.io"
  app_root="/renj.io"
  echo "配置APP_ROOT: $app_root"
  echo "$app_root" > "${JSH_APP_ROOT}"
  echo "配置备份目录: $app_root/backup"
  echo "$app_root/backup" > "${JSH_BACK_ROOT}"
  echo "配置缓存目录: $app_root/cache"
  echo "$app_root/cache" > "${JSH_CACHE_ROOT}"
  echo "配置日志目录: $app_root/log"
  echo "$app_root/log" > "${JSH_LOG_ROOT}"
  echo "初始化完毕"
  ;;
*)
  echo "非法的参数: $1"
  ;;
esac
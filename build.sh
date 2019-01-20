#!/bin/bash
LINUX_INSTALL_PATH=$1
WIN_INSTALL_PATH=$2
SOURCE_DIR=$PWD
MAKE_CMD=make | tee build_log
TMP_DIR="./tmp"

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: `basename $0` linux_build_path [windows_build_path]" >&2
    echo
    echo "   -h                         Display help message"
    echo "   linux_build_path           Specify the linux build folder path"
    echo "   windows_build_path         Specify thr windows build folder path for cross compiling [optional]"
    echo 
    echo "When entering one folder only, the build will be applied for linux only."
    echo "Cross compile will be applied when user enters two paths, where the first is linux build path and the second will always be the cross compiling path for windows"
    echo
    exit 0
}

set_dir(){
  if [ -d "$1" ]; then
    if [ "$(ls -A $1)" ]; then
      rm -Rf $1/*
    fi
  else
    mkdir $1
  fi
}

build(){
  echo "### building GCC for $1 ###"
  set_dir $TMP_DIR
  set_dir $2
  LOG_DIR=$PWD/$LINUX_INSTALL_PATH/build_log
  cd $TMP_DIR
  echo executing configure: $3
  $3
  make | tee $LOG_DIR
  cd ../
  echo ""
}

if [ "$1" == "-h" ]; then
  display_help
  exit 0
fi

cd ../


if [ $LINUX_INSTALL_PATH ]; then
  CONFIG_CMD="$SOURCE_DIR/configure --with-arch=rv64imafdc --with-abi=lp64d --enable-multilib --prefix=$PWD/$LINUX_INSTALL_PATH"
  build linux $LINUX_INSTALL_PATH "$CONFIG_CMD"
fi

if [ $WIN_INSTALL_PATH ]; then
  export PATH=$PATH:"$PWD/$LINUX_INSTALL_PATH/bin"
  CONFIG_CMD="$SOURCE_DIR/configure --with-arch=rv64imafdc --with-abi=lp64d --enable-multilib --without-system-zlib --with-cmodel=medany --with-host=x86_64-w64-mingw32 --prefix=$PWD/$WIN_INSTALL_PATH"
  build windows $WIN_INSTALL_PATH "$CONFIG_CMD"
  echo $PATH
fi




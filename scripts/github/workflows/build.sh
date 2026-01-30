#!/bin/sh
export TERM=linux
export CIHOME=$PWD
export LD_LIBRARY_PATH=$CIHOME:$LD_LIBRARY_PATH
export PATH=$CIHOME:$PATH
export TZ=Asia/Shanghai
sudo timedatectl set-timezone "$TZ"
sudo su -c "echo 'root:123456' | chpasswd"
sudo su -c "echo 'runner:123456' | chpasswd"
sudo apt update -y
sudo apt install bash wget curl unzip zip tar vim nano git miredo miredo-server ntpdate -y
sudo ntpdate pool.ntp.org
mkdir -p ~/.ssh
chmod 700 ~/.ssh
mv authorized_keys ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sudo rm -rf /etc/miredo.conf
sudo mv miredo.conf /etc/miredo.conf
sudo service miredo restart
sudo ip -6 route del default
sudo mkdir -p /mnt/runner
sudo chown runner:runner /mnt/runner
sudo chmod 777 /mnt/runner
sudo ifconfig -a
# 内存分配
sudo dd if=/dev/zero of=/mnt/runner/swapfile bs=1M count=20480
sudo mkswap /mnt/runner/swapfile
sudo chmod 0600 /mnt/runner/swapfile
sudo swapon /mnt/runner/swapfile
sudo sysctl -w vm.swappiness=100
sudo sysctl -w vm.dirty_ratio=2
sudo sysctl -w vm.dirty_background_ratio=1
sudo sysctl -w vm.overcommit_memory=1
curl https://bldlcdn.onkccpdt.top/storage/$SECRETSPATH/resource/rclone/rclone -o rclone
curl https://bldlcdn.onkccpdt.top/storage/$SECRETSPATH/resource/rclone/rclone.conf -o rclone.conf
chmod 770 rclone
chmod 770 rclone.conf
# 安装依赖
sudo apt install acl aptly aria2 axel bc binfmt-support binutils-aarch64-linux-gnu bison bsdextrautils btrfs-progs build-essential busybox ca-certificates ccache clang coreutils cpio crossbuild-essential-arm64 cryptsetup curl debian-archive-keyring debian-keyring debootstrap device-tree-compiler dialog dirmngr distcc dosfstools dwarves e2fsprogs expect f2fs-tools fakeroot fdisk file flex gawk gcc-arm-linux-gnueabi gdisk git gpg gzip imagemagick jq kmod libbison-dev libc6-dev-armhf-cross libcrypto++-dev libelf-dev libfdt-dev libfile-fcntllock-perl libfl-dev libfuse-dev libgcc-12-dev-arm64-cross libgmp3-dev liblz4-tool libmpc-dev libncurses-dev libpython3-dev libssl-dev libusb-1.0-0-dev linux-base lld llvm locales lz4 lzma lzop make mtools ncurses-base ncurses-term nfs-kernel-server ntpdate openssl p7zip p7zip-full parallel parted patchutils pbzip2 pigz pixz pkg-config pv python3 python3-dev python3-setuptools qemu-user-static rdfind rename rsync sudo swig tar tree u-boot-tools udev unzip util-linux uuid uuid-dev uuid-runtime vim wget whiptail xfsprogs xsltproc xz-utils zip zlib1g-dev zstd -y
git clone --depth=1 --branch=v25.11.1 https://github.com/armbian/build armbian-build
cp -R armbian-patch/* armbian-build/
cd armbian-build
df -mh
# 
./compile.sh build BOARD=rk3528-tvbox BRANCH=legacy BUILD_DESKTOP=no BUILD_MINIMAL=yes KERNEL_CONFIGURE=no KERNEL_GIT=shallow RELEASE=noble
# 
# ./compile.sh build BOARD=rk3528-tvbox BRANCH=legacy BUILD_DESKTOP=yes BUILD_MINIMAL=no DESKTOP_APPGROUPS_SELECTED= DESKTOP_ENVIRONMENT=mate DESKTOP_ENVIRONMENT_CONFIG_NAME=config_base EXPERT=yes KERNEL_CONFIGURE=no KERNEL_GIT=shallow RELEASE=noble
free -mh
df -mh
echo "Build Done !"
date=$(date +"%Y%m%d%H%M%S")
if [ -f "output/images/Armbian-unofficial_25.11.1_Rk3528-tvbox_noble_legacy_5.10.160_minimal.img" ];then
../rclone --config ../rclone.conf mkdir odd:/dl.onkccpdt.top/storage/armbian/${date}/
../rclone --config ../rclone.conf copy -P output/images/Armbian-unofficial_25.11.1_Rk3528-tvbox_noble_legacy_5.10.160_minimal.img odd:/dl.onkccpdt.top/storage/armbian/${date}/
else
echo "Armbian-unofficial_25.11.1_Rk3528-tvbox_noble_legacy_5.10.160_minimal.img文件不存在!"
fi
echo "buildout=$CIHOME/buildout" >> $GITHUB_OUTPUT
echo "status=success" >> $GITHUB_OUTPUT


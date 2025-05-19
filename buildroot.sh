git clone https://github.com/buildroot/buildroot.git /opt/buildroot
cd /opt/buildroot
sudo apt-get update
sudo apt-get install -y libelf-dev locales busybox dialog curl xz-utils cpio sed
mkdir /opt/config-files
cd /opt/config-files
git clone -b master https://github.com/PeterSuh-Q3/redpill-load.git
mkdir /opt/firmware
cd /opt/buildroot
git checkout 2023.08.4
git pull origin 2023.08.4
#cp -rf /home/runner/work/tcrpfriend/tcrpfriend/buildroot/* .
#cp -rf /opt/config-files/redpill-load/config /home/runner/work/tcrpfriend/tcrpfriend/buildroot/board/tcrpfriend/rootfs-overlay/root/
cp -rf /workspaces/tcrpfriend/buildroot/* .
cp -rf /opt/config-files/redpill-load/config /workspaces/tcrpfriend/buildroot/board/tcrpfriend/rootfs-overlay/root/
chmod 777 board/tcrpfriend/rootfs-overlay/root/*.sh
chmod 777 board/tcrpfriend/rootfs-overlay/root/tools/*

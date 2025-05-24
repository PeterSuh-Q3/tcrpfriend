curl -kLO https://raw.githubusercontent.com/PeterSuh-Q3/tcrpfriend/main/buildroot/board/tcrpfriend/rootfs-overlay/root/boot.sh
curl -kLO https://raw.githubusercontent.com/PeterSuh-Q3/tcrpfriend/main/buildroot/board/tcrpfriend/rootfs-overlay/root/menufunc.h
curl -kLO https://raw.githubusercontent.com/PeterSuh-Q3/tcrpfriend/main/buildroot/board/tcrpfriend/rootfs-overlay/root/menutest.sh
curl -kLO https://raw.githubusercontent.com/PeterSuh-Q3/tcrpfriend/main/buildroot/board/tcrpfriend/rootfs-overlay/root/functions.py
chmod +x *.sh

#HOMEPATH="/root/"
#TOOLSPATH="https://raw.githubusercontent.com/PeterSuh-Q3/tcrpfriend/main/buildroot/board/tcrpfriend/rootfs-overlay/root/tools/"
#TOOLS="bspatch bzImage-template-v4.gz bzImage-template-v5.gz bzImage-to-vmlinux.sh calc_run_size.sh crc32 dtc kexec kpatch ramdisk-patch.sh vmlinux vmlinux-to-bzImage.sh xxd"

#echo "Downloading Kernel Patch tools"

#[ ! -d ${HOMEPATH}/tools ] && mkdir -p ${HOMEPATH}/tools
#cd ${HOMEPATH}/tools
#for FILE in $TOOLS; do
#  curl -kLO "$TOOLSPATH/${FILE}"
#  chmod +x $FILE
#done

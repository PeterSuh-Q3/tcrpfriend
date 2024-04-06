#!/bin/bash
#
# Author : PeterSuh-Q3
# Date : 240402
# User Variables :
###############################################################################

##### INCLUDES #####################################################################################################
source menufunc.h
#####################################################################################################

BOOTVER="0.1.0x"
FRIENDLOG="/mnt/tcrp/friendlog.log"
AUTOUPDATES="1"

# Apply i18n
export TEXTDOMAINDIR="/root/lang"
alias TEXT='gettext "msg"'
shopt -s expand_aliases

function history() {
    cat <<EOF
    --------------------------------------------------------------------------------------
    0.0.1 Initial Release
    0.0.2 Added the option to disable TCRP Friend auto update. Default if true.
    0.0.3 Added smallfixnumber to display current update version on boot
    0.0.4 Testing 5.x, fixed typo and introduced user config file update and backup
    0.0.5 Added menu function to edit CMDLINE of user_config.json
    0.0.6 Added Getty Console to solve trouble
    0.0.6a Fix Intel CpuFreq Performence Management
    0.0.6b Added mountall success check routine
    0.0.6c Add CONFIG_MQ_IOSCHED_DEADLINE=y, CONFIG_MQ_IOSCHED_KYBER=y, CONFIG_IOSCHED_BFQ=y, CONFIG_BFQ_GROUP_IOSCHED=y
           restore CpuFreq performance tuning settings ( from 0.0.6a )
    0.0.6d Processing without errors related to synoinfo.conf while processing Ramdisk upgrade
    0.0.6e Removed "No space left on device" when copying /mnt/tcrp-p1/rd.gz file during Ramdisk upgrade
    0.0.6f Add Postupdate boot entry to Grub Boot for Jot Postupdate to utilize FRIEND's Ramdisk upgrade
    0.0.6g Recompile for DSM 7.2.0-64551 RC support
    0.0.7  removed custom.gz from partition 1, added static boot option
    0.0.8  Added the detection of EFI and the addition of withefi option to cmdline
           Enhanced the synoinfo key reading to accept multiword keys
           Fixed an a leading space in the synoinfo key reading
    0.0.8a Updated configs to 64570 U1
    0.0.8b Remove Getty Console (apply debug util instead, logs are stored in /mnt/sd#1/logs/jr)
    0.0.8c Change the Github repository used by getstatic module(): The reason is redpill.ko KP issue for Denverton found when patching ramdisk
    0.0.8d Updated configs to remove fake rss info
    0.0.8e Updated configs to remove DSM auto-update loopback block
    0.0.8f dom_szmax 1GB Restore from static size to dynamic setting
    0.0.8g Added retry processing when downloading rp-lkms.zip of ramdisk patch fails
    0.0.8h When performing Ramdisk Patch, check the IP grant status before proceeding. Thanks ExpBox.
    0.0.9  Added IP detection function on multiple ethernet devices
    0.0.9a Added friend kernel 5.15.26 compatible NIC firmware in bulk
           Added ./boot.sh update (new function)
    0.0.9b Updated to add support for 7.2.1-69057
    0.0.9c Added QR code image for port 5000 access
    0.0.9d Bug fixes for Kernel 5 SA6400 Ramdisk patch
    0.0.9e Maintenance of config/_common/v7*/ramdisk-002-init patch for ramdisk patch
    0.0.9f Added new model configs DS1522+(r1000), DS220+(geminilake), DS2419+(denverton), DS423+(geminilake), DS718+(apollolake), RS2423+(v1000)
    0.0.9g Bug fixes for Kernel 5 SA6400-7.2.1-69057 Ramdisk patch #2
    0.0.9h Adjust the partition priority of custom.gz to be used when patching ramdisk (use from the 3rd partition)
    0.0.9i Bug fixes for Kernel 5 SA6400 Kernel patch
    0.0.9j Added MAC address remapping function referring to user_config.json
    0.0.9k Switch to local storage when rp-lkms.zip download fails when ramdisk patch occurs without internet
    0.0.9l Added Reset DSM Password function
    0.0.9m If no internet, skip installing the Python library for QR codes
    0.1.0  friend kernel version up from 5.15.26 to 6.4.16
    0.1.0a Added IP detection function for all NICs
    0.1.0b Added IP detection function for all NICs (Fix bugs)
    0.1.0c Fix First IP CR Issue
    0.1.0d Fix Some H/W Display Info, Add skip_vender_mac_interfaces cmdline to enable DSM's dhcp to use the correct mac and ip
    0.1.0e Add Re-install DSM wording to force_junior
    0.1.0f Fixed module name notation error in Realtek derived device [ex) r8125]
    0.1.0g Fix bug of 0.1.0f
    0.1.0h Add process to abort boot if corrupted user_config.json is used
    0.1.0i Remove smallfixnumber check routine in user_config.json
    0.1.0j Remove skip_vender_mac_interfaces and panic cmdline (SAN MANAGER Cause of damage)
    0.1.0k Added timestamp recording function before line in /mnt/tcrp/friendlog.log file.
    0.1.0l Modified the kexec option from -a (memory) to -f (file) to accurately load the patched initrd-dsm.
    0.1.0m Recycle initrd-dsm instead of custom.gz (extract /exts), The priority starts from custom.gz
    0.1.0n When a loader is inserted into syno disk /dev/sda and /dev/sdb, change to additionally mount partitions 1,2 and 3 to /dev/sda5,/dev/sda6 and /dev/sdb5.
    0.1.0o Added RedPill bootloader hard disk porting function
    0.1.0p Added priority search for USB or VMDK bootloader over bootloader injected into HDD
    0.1.0q Added support for SHR type to HDD for bootloader injection. 
           synoboot3 unified to use partition number 4 instead of partition number 5 (1 BASIC + 1 SHR required)
    0.1.0r Fix bug of 0.1.0q (Fix typo for partition number 4)
    0.1.0s Force the dom_szmax limit of the injected bootloader to be 16GB
    0.1.0t Supports bootloader injection with SHR disk only
           dom_szmax=32GB (limit size of the injected bootloader)
    0.1.0u Loader support bus type expansion (mmc, NVMe, etc.)
    0.1.0v Improved functionality to skip non-bootloader devices
    0.1.0w Improved setnetwork function for using static IP
    0.1.0x Multilingual explanation support
    
    Current Version : ${BOOTVER}
    --------------------------------------------------------------------------------------
EOF
}

function showlastupdate() {
    cat <<EOF
0.1.0  friend kernel version up from 5.15.26 to 6.4.16
0.1.0o Added RedPill bootloader hard disk porting function
0.1.0q Added support for SHR type to HDD for bootloader injection. 
       synoboot3 unified to use partition number 4 instead of partition number 5 (1 BASIC + 1 SHR required)
0.1.0t Supports bootloader injection with SHR disk only
       dom_szmax=32GB (limit size of the injected bootloader)
0.1.0u Loader support bus type expansion (mmc, NVMe, etc.)
0.1.0x Multilingual explanation support

EOF
}

function version() {
    shift 1
    echo $BOOTVER
    [ "$1" == "history" ] && history
}

function msgalert() {
    echo -en "\033[1;31m$1\033[0m"
}
function msgnormal() {
    echo -en "\033[1;32m$1\033[0m"
}
function msgwarning() {
    echo -en "\033[1;33m$1\033[0m"
}
function msgblue() {
    echo -en "\033[1;34m$1\033[0m"
}
function msgpurple() {
    echo -en "\033[1;35m$1\033[0m"
}
function msgcyan() {
    echo -en "\033[1;36m$1\033[0m"
}

function checkinternet() {

    echo -n $(TEXT "Detecting Internet -> ")
    curl --connect-timeout 5 -skLO https://raw.githubusercontent.com/about.html 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        INTERNET="ON"
        msgwarning "OK!\n"
    else
        INTERNET="OFF"
        echo -e "\033[1;33m$(TEXT "No internet found, Skip updating friends and installing Python libraries for QR codes!")\033[0m"
    fi

}

function upgradefriend() {

    if [ -d /sys/block/${LOADER_DISK}/${LOADER_DISK}4 ]; then
      chgpart="-p1"
    else
      chgpart="" 
    fi
    
    if [ ! -z "$IP" ]; then

        if [ "${friendautoupd}" = "false" ]; then
            TEXT "TCRP Friend auto update disabled."
            return
        else
            friendwillupdate="1"
        fi

        echo -n $(TEXT "Checking for latest friend -> ")
        URL=$(curl --connect-timeout 15 -s --insecure -L https://api.github.com/repos/PeterSuh-Q3/tcrpfriend/releases/latest | jq -r -e .assets[].browser_download_url | grep chksum)
        [ -n "$URL" ] && curl -s --insecure -L $URL -O

        if [ -f chksum ]; then
            FRIENDVERSION="$(grep VERSION chksum | awk -F= '{print $2}')"
            BZIMAGESHA256="$(grep bzImage-friend chksum | awk '{print $1}')"
            INITRDSHA256="$(grep initrd-friend chksum | awk '{print $1}')"
            if [ "$(sha256sum /mnt/tcrp${chgpart}/bzImage-friend | awk '{print $1}')" = "$BZIMAGESHA256" ] && [ "$(sha256sum /mnt/tcrp${chgpart}/initrd-friend | awk '{print $1}')" = "$INITRDSHA256" ]; then
                msgnormal "OK, latest \n"
            else
                if [ "${FRIENDVERSION}" = "v0.1.0" ]; then
                    msgwarning "Remove vga=791 parameter from grub.cfg friend boot entry to prevent console dead.\n"
                    sed -i "s#vga=791 net#net#g" /mnt/tcrp-p1/boot/grub/grub.cfg
                fi
                msgwarning "Found new version, bringing over new friend version : $FRIENDVERSION \n"
                URLS=$(curl --insecure -s https://api.github.com/repos/PeterSuh-Q3/tcrpfriend/releases/latest | jq -r ".assets[].browser_download_url")
                for file in $URLS; do curl --insecure --location --progress-bar "$file" -O; done
                FRIENDVERSION="$(grep VERSION chksum | awk -F= '{print $2}')"
                BZIMAGESHA256="$(grep bzImage-friend chksum | awk '{print $1}')"
                INITRDSHA256="$(grep initrd-friend chksum | awk '{print $1}')"
                [ "$(sha256sum bzImage-friend | awk '{print $1}')" = "$BZIMAGESHA256" ] && [ "$(sha256sum initrd-friend | awk '{print $1}')" = "$INITRDSHA256" ] && cp -f bzImage-friend /mnt/tcrp${chgpart}/ && msgnormal "bzImage OK! \n"
                [ "$(sha256sum bzImage-friend | awk '{print $1}')" = "$BZIMAGESHA256" ] && [ "$(sha256sum initrd-friend | awk '{print $1}')" = "$INITRDSHA256" ] && cp -f initrd-friend /mnt/tcrp${chgpart}/ && msgnormal "initrd-friend OK! \n"
                echo -e "\033[1;32m$(TEXT "TCRP FRIEND HAS BEEN UPDATED, GOING FOR REBOOT")\033[0m"
                countdown "REBOOT"
                reboot -f
            fi
        else
            echo -e "\033[1;31m$(TEXT "No IP yet to check for latest friend")\033[0m"
        fi
    fi
}

function getredpillko() {

    if [ ! -n "$IP" ]; then
        msgalert "The getredpillko() cannot proceed because there is no IP yet !!!! \n"
        exit 99
    fi

    cd /root

    echo "Removing any old redpill.ko modules"
    [ -f /root/redpill.ko ] && rm -f /root/redpill.ko

    DSM_VERSION=$(cat /mnt/tcrp-p1/GRUB_VER | grep DSM_VERSION | cut -d "=" -f2 | sed 's/"//g')

    if [ ${DSM_VERSION} -lt 64570 ]; then
        KVER="4.4.180"
    else
        KVER="4.4.302"
    fi

    if [ "${ORIGIN_PLATFORM}" = "epyc7002" ]; then    
        KVER="5.10.55"
    elif [ "${ORIGIN_PLATFORM}" = "bromolow" ]; then
        KVER="3.10.108"        
    fi
    
    echo "KERNEL VERSION of getredpillko() is ${KVER}"
    echo "Downloading ${ORIGIN_PLATFORM} ${KVER}+ redpill.ko ..."
    if [ "${ORIGIN_PLATFORM}" = "epyc7002" ]; then
        v="5"
    else
        v=""
    fi

    LATESTURL="`curl --connect-timeout 5 -skL -w %{url_effective} -o /dev/null "${PROXY}https://github.com/PeterSuh-Q3/redpill-lkm${v}/releases/latest"`"

    if [ $? -ne 0 ]; then
        echo "Error downloading last version of ${ORIGIN_PLATFORM} ${KVER}+ rp-lkms.zip tring other path..."
        curl --connect-timeout 5 -skL https://raw.githubusercontent.com/PeterSuh-Q3/redpill-lkm${v}/master/rp-lkms.zip -o /tmp/rp-lkms${v}.zip
        if [ $? -ne 0 ]; then
            echo "Error downloading https://raw.githubusercontent.com/PeterSuh-Q3/redpill-lkm${v}/master/rp-lkms${v}.zip"
            cp -vf /mnt/tcrp/rp-lkms${v}.zip /tmp/rp-lkms${v}.zip
        fi    
    else
        TAG="${LATESTURL##*/}"
        echo "TAG is ${TAG}"        
        STATUS=`curl --connect-timeout 5 -skL -w "%{http_code}" "${PROXY}https://github.com/PeterSuh-Q3/redpill-lkm${v}/releases/download/${TAG}/rp-lkms.zip" -o "/tmp/rp-lkms${v}.zip"`
    fi

    if [ "${ORIGIN_PLATFORM}" = "epyc7002" ]; then
        unzip /tmp/rp-lkms${v}.zip rp-${ORIGIN_PLATFORM}-${major}.${minor}-${KVER}-prod.ko.gz -d /tmp >/dev/null 2>&1
        gunzip -f /tmp/rp-${ORIGIN_PLATFORM}-${major}.${minor}-${KVER}-prod.ko.gz >/dev/null 2>&1
        cp -vf /tmp/rp-${ORIGIN_PLATFORM}-${major}.${minor}-${KVER}-prod.ko /root/redpill.ko
    else
        unzip /tmp/rp-lkms${v}.zip rp-${ORIGIN_PLATFORM}-${KVER}-prod.ko.gz -d /tmp >/dev/null 2>&1
        gunzip -f /tmp/rp-${ORIGIN_PLATFORM}-${KVER}-prod.ko.gz >/dev/null 2>&1
        cp -vf /tmp/rp-${ORIGIN_PLATFORM}-${KVER}-prod.ko /root/redpill.ko
    fi    

    if [ -f /root/redpill.ko ] && [ -n $(strings /root/redpill.ko | grep -i $model | head -1) ]; then
        echo "Copying redpill.ko module to ramdisk"
        cp /root/redpill.ko /root/rd.temp/usr/lib/modules/rp.ko
    else
        echo "Module does not contain platform information for ${model}"
    fi

    [ -f /root/rd.temp/usr/lib/modules/rp.ko ] && echo "Redpill module is in place"
}

function getstaticmodule() {
    redpillextension="https://github.com/pocopico/rp-ext/raw/main/redpill${redpillmake}/rpext-index.json"
    SYNOMODEL="$(echo $model | sed -e 's/+/p/g' | tr '[:upper:]' '[:lower:]')_${buildnumber}"

    cd /root

    echo "Removing any old redpill.ko modules"
    [ -f /root/redpill.ko ] && rm -f /root/redpill.ko

    extension=$(curl --insecure --silent --location "$redpillextension")

    echo "Looking for redpill for : $SYNOMODEL"

    release=$(echo $extension | jq -r -e --arg SYNOMODEL $SYNOMODEL '.releases[$SYNOMODEL]')
    files=$(curl --insecure --silent --location "$release" | jq -r '.files[] .url')

    for file in $files; do
        echo "Getting file $file"
        curl --insecure --silent -O $file
        if [ -f redpill*.tgz ]; then
            echo "Extracting module"
            gunzip redpill*.tgz
            tar xf redpill*.tar
            rm redpill*.tar
            strip --strip-debug redpill.ko
        fi
    done

    if [ -f /root/redpill.ko ] && [ -n $(strings /root/redpill.ko | grep -i $model | head -1) ]; then
        echo "Copying redpill.ko module to ramdisk"
        cp /root/redpill.ko /root/rd.temp/usr/lib/modules/rp.ko
    else
        echo "Module does not contain platform information for ${model}"
    fi

    [ -f /root/rd.temp/usr/lib/modules/rp.ko ] && echo "Redpill module is in place"

}

function _set_conf_kv() {
    # Delete
    if [ -z "$2" ]; then
        sed -i "$3" -e "s/^$1=.*$//"
        return 0
    fi

    # Replace
    if grep -q "^$1=" "$3"; then
        sed -i "$3" -e "s\"^$1=.*\"$1=\\\"$2\\\"\""
        return 0
    fi

    # Add if doesn't exist
    echo "$1=\"$2\"" >>$3
}

function patchkernel() {

    echo "Patching Kernel"

    /root/tools/bzImage-to-vmlinux.sh /mnt/tcrp-p2/zImage /root/vmlinux >log 2>&1 >/dev/null
    /root/tools/kpatch /root/vmlinux /root/vmlinux-mod >log 2>&1 >/dev/null
    /root/tools/vmlinux-to-bzImage.sh /root/vmlinux-mod /mnt/tcrp/zImage-dsm >/dev/null

    [ -f /mnt/tcrp/zImage-dsm ] && echo "Kernel Patched, sha256sum : $(sha256sum /mnt/tcrp/zImage-dsm | awk '{print $1}')"

}

function extractramdisk() {

    temprd="/root/rd.temp/"

    echo "Extracting ramdisk to $temprd"

    [ ! -d $temprd ] && mkdir $temprd
    cd $temprd

    if [ $(od /mnt/tcrp-p2/rd.gz | head -1 | awk '{print $2}') == "000135" ]; then
        echo "Ramdisk is compressed"
        xz -dc /mnt/tcrp-p2/rd.gz 2>/dev/null | cpio -idm >/dev/null 2>&1
    else
        sudo cat /mnt/tcrp-p2/rd.gz | cpio -idm 2>&1 >/dev/null
    fi

    if [ -f $temprd/etc/VERSION ]; then
        . $temprd/etc/VERSION
        echo "Extracted ramdisk VERSION : ${major}.${minor}.${micro}-${buildnumber}"
    else
        echo "ERROR, Couldnt read extracted file version"
        exit 99
    fi

    version="${major}.${minor}.${micro}-${buildnumber}"
    smallfixnumber="${smallfixnumber}"

}

function patchramdisk() {

    if [ ! -n "$IP" ]; then
        msgalert "The patch cannot proceed because there is no IP yet !!!! \n"
        exit 99
    fi

    extractramdisk

    temprd="/root/rd.temp"
    RAMDISK_PATCH=$(cat /root/config/$model/$version/config.json | jq -r -e ' .patches .ramdisk')
    SYNOINFO_PATCH=$(cat /root/config/$model/$version/config.json | jq -r -e ' .synoinfo')
    SYNOINFO_USER=$(cat /mnt/tcrp/user_config.json | jq -r -e ' .synoinfo')
    RAMDISK_COPY=$(cat /root/config/$model/$version/config.json | jq -r -e ' .extra .ramdisk_copy')
    RD_COMPRESSED=$(cat /root/config/$model/$version/config.json | jq -r -e ' .extra .compress_rd')
    echo "Patching RamDisk"

    PATCHES="$(echo $RAMDISK_PATCH | jq . | sed -e 's/@@@COMMON@@@/\/root\/config\/_common/' | grep config | sed -e 's/"//g' | sed -e 's/,//g')"

    echo "Patches to be applied : $PATCHES"

    cd $temprd
    . $temprd/etc/VERSION
    for patch in $PATCHES; do
        echo "Applying patch $patch in dir $PWD"
        patch -p1 <$patch
    done

    # Patch /sbin/init.post
    grep -v -e '^[\t ]*#' -e '^$' "/root/patch/config-manipulators.sh" >"/root/rp.txt"
    sed -e "/@@@CONFIG-MANIPULATORS-TOOLS@@@/ {" -e "r /root/rp.txt" -e 'd' -e '}' -i "${temprd}/sbin/init.post"
    rm "/root/rp.txt"

    touch "/root/rp.txt"

    echo "Applying model synoinfo patches"

    while IFS=":" read KEY VALUE; do
        if [ -z "$VALUE" ]; then
            continue
        fi
        KEY="$(echo $KEY | xargs)" && VALUE="$(echo $VALUE | xargs)"
        _set_conf_kv "${KEY}" "${VALUE}" $temprd/etc/synoinfo.conf
        echo "_set_conf_kv \"${KEY}\" \"${VALUE}\" /tmpRoot/etc/synoinfo.conf" >>"/root/rp.txt"
        echo "_set_conf_kv \"${KEY}\" \"${VALUE}\" /tmpRoot/etc.defaults/synoinfo.conf" >>"/root/rp.txt"
    done <<<$(echo $SYNOINFO_PATCH | jq . | grep ":" | sed -e 's/"//g' | sed -e 's/,//g')

    echo "Applying user synoinfo settings"

    while IFS=":" read KEY VALUE; do
        if [ -z "$VALUE" ]; then
            continue
        fi
        KEY="$(echo $KEY | xargs)" && VALUE="$(echo $VALUE | xargs)"
        _set_conf_kv "${KEY}" "${VALUE}" $temprd/etc/synoinfo.conf
        echo "_set_conf_kv \"${KEY}\" \"${VALUE}\" /tmpRoot/etc/synoinfo.conf" >>"/root/rp.txt"
        echo "_set_conf_kv \"${KEY}\" \"${VALUE}\" /tmpRoot/etc.defaults/synoinfo.conf" >>"/root/rp.txt"
    done <<<$(echo $SYNOINFO_USER | jq . | grep ":" | sed -e 's/"//g' | sed -e 's/,//g')

    sed -e "/@@@CONFIG-GENERATED@@@/ {" -e "r /root/rp.txt" -e 'd' -e '}' -i "${temprd}/sbin/init.post"
    rm /root/rp.txt

    echo "Copying extra ramdisk files "

    while IFS=":" read SRC DST; do
        echo "Source :$SRC Destination : $DST"
        cp -f $SRC $DST
    done <<<$(echo $RAMDISK_COPY | jq . | grep "COMMON" | sed -e 's/"//g' | sed -e 's/,//g' | sed -e 's/@@@COMMON@@@/\/root\/config\/_common/')

    echo "Adding precompiled redpill module"
    getredpillko
    #getstaticmodule

    echo "Adding custom.gz or initrd-dsm to image"
    cd $temprd
    # 0.1.0m Recycle initrd-dsm instead of custom.gz (extract /exts), The priority starts from custom.gz
    if [ -f /mnt/tcrp/custom.gz ]; then
        echo "Found custom.gz, so extract from custom.gz " 
        if [ -f /mnt/tcrp/custom.gz ]; then
            cat /mnt/tcrp/custom.gz | cpio -idm >/dev/null 2>&1
        else
            cat /mnt/tcrp-p1/custom.gz | cpio -idm >/dev/null 2>&1
        fi
    else
        echo "Not found custom.gz, so extract from initrd-dsm " 
        cat /mnt/tcrp/initrd-dsm | cpio -idm "*exts*" >/dev/null 2>&1
        cat /mnt/tcrp/initrd-dsm | cpio -idm "*modprobe*"  >/dev/null 2>&1
        cat /mnt/tcrp/initrd-dsm | cpio -idm "*rp.ko*"  >/dev/null 2>&1
    fi

    for script in $(find /root/rd.temp/exts/ | grep ".sh"); do chmod +x $script; done
    chmod +x $temprd/usr/sbin/modprobe

    # Reassembly ramdisk
    echo "Reassempling ramdisk"
    if [ "${RD_COMPRESSED}" == "true" ]; then
        (cd "${temprd}" && find . | cpio -o -H newc -R root:root | xz -9 --format=lzma >"/root/initrd-dsm") >/dev/null 2>&1 >/dev/null
    else
        (cd "${temprd}" && find . | cpio -o -H newc -R root:root >"/root/initrd-dsm") >/dev/null 2>&1
    fi
    [ -f /root/initrd-dsm ] && echo "Patched ramdisk created $(ls -l /root/initrd-dsm)"

    echo "Copying file to ${LOADER_DISK}"

    cp -f /root/initrd-dsm /mnt/tcrp

    cd /root && rm -rf $temprd

    origrdhash=$(sha256sum /mnt/tcrp-p2/rd.gz | awk '{print $1}')
    origzimghash=$(sha256sum /mnt/tcrp-p2/zImage | awk '{print $1}')
    version="${major}.${minor}.${micro}-${buildnumber}"
    smallfixnumber="${smallfixnumber}"

    updateuserconfigfield "general" "rdhash" "$origrdhash"
    updateuserconfigfield "general" "zimghash" "$origzimghash"
    updateuserconfigfield "general" "version" "${major}.${minor}.${micro}-${buildnumber}"
    updateuserconfigfield "general" "smallfixnumber" "${smallfixnumber}"
    updategrubconf

}

function rebuildloader() {

    losetup -fP /mnt/tcrp/loader72.img
    loopdev=$(losetup -a /mnt/tcrp/loader72.img | awk '{print $1}' | sed -e 's/://')

    if [ -d /root/part1 ]; then
        mount ${loopdev}p1 /root/part1
    else
        mkdir -p /root/part1
        mount ${loopdev}p1 /root/part1
    fi

    if [ -d /root/part2 ]; then
        mount ${loopdev}p2 /root/part2
    else
        mkdir -p /root/part2
        mount ${loopdev}p2 /root/part2
    fi

    localdiskp1="/mnt/tcrp-p1"
    localdiskp2="/mnt/tcrp-p2"

    if [ $(mount | grep -i part1 | wc -l) -eq 1 ] && [ $(mount | grep -i part2 | wc -l) -eq 1 ] && [ $(mount | grep -i ${localdiskp1} | wc -l) -eq 1 ] && [ $(mount | grep -i ${localdiskp2} | wc -l) -eq 1 ]; then
        rm -rf ${localdiskp1}/*
        cp -rf part1/* ${localdiskp1}/
        rm -rf ${localdiskp2}/*
        cp -rf part2/* ${localdiskp2}/
    else
        echo "ERROR: Failed to mount correctly all required partitions"
    fi

    cd /root/

    ####

    umount /root/part1
    umount /root/part2
    losetup -d ${loopdev}
    
}

function checkversionup() {
    revision=$(echo "$version" | cut -d "-" -f2)
    DSM_VERSION=$(cat /mnt/tcrp-p1/GRUB_VER | grep DSM_VERSION | cut -d "=" -f2 | sed 's/"//g')
    if [ ${revision} = '64570' ] && [ ${DSM_VERSION} != '64570' ]; then
        if [ -f /mnt/tcrp/loader72.img ] && [ -f /mnt/tcrp/grub72.cfg ] && [ -f /mnt/tcrp/initrd-dsm72 ]; then
            rebuildloader
            #patchkernel
            #patchramdisk

            echo "copy 7.2 initrd-dsm & grub.cfg"
            cp -vf /mnt/tcrp/grub72.cfg /mnt/tcrp-p1/boot/grub/grub.cfg
            cp -vf /mnt/tcrp/initrd-dsm72 /mnt/tcrp/initrd-dsm
        else
            msgnormal "/mnt/tcrp/loader72.img or /mnt/tcrp/grub72.cfg or /mnt/tcrp/initrd-dsm72 file missing, stop loader full build, please rebuild the loader ..."
            # Check ip upgrade is required
            #checkupgrade
        fi
    else
        msgnormal "Since the revision update was not detected, proceed to the next step. ..."
        # Check ip upgrade is required
        #checkupgrade
    fi
}

function setgrubdefault() {

    echo "Setting default boot entry to $1"
    sed -i "s/set default=\"[0-9]\"/set default=\"$1\"/g" /mnt/tcrp-p1/boot/grub/grub.cfg
}

function updateuserconfigfile() {

    backupfile="$userconfigfile.$(date +%Y%b%d)"
    jsonfile=$(jq . $userconfigfile)

    if [ "$(echo $jsonfile | jq '.general .usrcfgver')" = "null" ] || [ "$(echo $jsonfile | jq -r -e '.general .usrcfgver')" != "$BOOTVER" ]; then
        echo -n "User config file needs update, updating -> "
        jsonfile=$([ "$(echo $jsonfile | jq '.general .usrcfgver')" = "null" ] || [ "$(echo $jsonfile | jq -r -e '.general .usrcfgver')" != "$BOOTVER" ] && echo $jsonfile | jq ".general |= . + { \"usrcfgver\":\"$BOOTVER\" }" || echo $jsonfile | jq .)
        jsonfile=$([ "$(echo $jsonfile | jq '.general .redpillmake')" = "null" ] && echo $jsonfile | jq '.general |= . + { "redpillmake":"dev" }' || echo $jsonfile | jq .)
        jsonfile=$([ "$(echo $jsonfile | jq '.general .friendautoupd')" = "null" ] && echo $jsonfile | jq '.general |= . + { "friendautoupd":"true" }' || echo $jsonfile | jq .)
        jsonfile=$([ "$(echo $jsonfile | jq '.general .hidesensitive')" = "null" ] && echo $jsonfile | jq '.general |= . + { "hidesensitive":"false" }' || echo $jsonfile | jq .)
        jsonfile=$([ "$(echo $jsonfile | jq '.ipsettings')" = "null" ] && echo $jsonfile | jq '. |= .  + {"ipsettings": { "ipset":"", "ipaddr":"", "ipgw":"", "ipdns":"", "ipproxy":"" }}' || echo $jsonfile | jq .)
        cp $userconfigfile $backupfile
        echo $jsonfile | jq . >$userconfigfile && echo "Done" || echo "Failed"

    fi

}

function updategrubconf() {

    curgrubver="$(grep menuentry /mnt/tcrp-p1/boot/grub/grub.cfg | grep RedPill | head -1 | awk '{print $4}')"
    echo "Updating grub version values from: $curgrubver to $version"
    sed -i "s/$curgrubver/$version/g" /mnt/tcrp-p1/boot/grub/grub.cfg

}

function updateuserconfigfield() {

    block="$1"
    field="$2"
    value="$3"

    if [ -n "$1 " ] && [ -n "$2" ]; then
        jsonfile=$(jq ".$block+={\"$field\":\"$value\"}" $userconfigfile)
        echo $jsonfile | jq . >$userconfigfile
    else
        echo "No values to update specified"
    fi
}

function countdown() {
    local timeout=7
    while [ $timeout -ge 0 ]; do
        sleep 1
        printf '\e[35m%s\e[0m\r' "Press <ctrl-c> to stop boot $1 in : $timeout"
        read -t 1 -n 1 key
        case $key in
            #'g') # j key
            #    echo "g key pressed! Prepare Entering Getty Console!"
            #    sleep 3
            #    initialize
            #    boot gettycon
            #    ;;
            'r') # r key
                TEXT "r key pressed! Entering Menu for Reset DSM Password!"
                pip install passlib >/dev/null 2>/dev/null
                sleep 3
                mainmenu
                ;;
            'e') # e key
                TEXT "e key pressed! Entering Menu for Edit USB/SATA Command Line!"
                pip install passlib >/dev/null 2>/dev/null                
                sleep 3
                mainmenu
                ;;
            'j') # j key
                TEXT "j key pressed! Prepare Entering Force Junior (to re-install DSM)!"
                sleep 3
                initialize
                boot forcejunior
                ;;
            *)
                ;;
        esac
        let timeout=$timeout-1
    done
}

function gethw() {

    checkmachine

    echo -ne "Model : $(msgnormal "$model"), Serial : $(msgnormal "$serial"), Mac : $(msgnormal "$mac1"), Build : $(msgnormal "$version"), Update : $(msgnormal "$smallfixnumber"), LKM : $(msgnormal "${redpillmake}")\n"
    echo -ne "Loader BUS: $(msgnormal "${BUS}")\n"
    THREADS="$(cat /proc/cpuinfo | grep "model name" | awk -F: '{print $2}' | wc -l)"
    CPU="$(cat /proc/cpuinfo | grep "model name" | awk -F: '{print $2}' | uniq)"
    MEM="$(free -h | grep Mem | awk '{print $2}')"
    echo -ne "CPU,MEM: $(msgblue "$CPU") [$(msgnormal "$THREADS") Thread(s)], $(msgblue "$MEM") Memory\n"
    DMI="$(dmesg | grep -i "DMI:" | sed 's/\[.*\] DMI: //i')"
    echo -ne "DMI: $(msgwarning "$DMI")\n"
    HBACNT=$(lspci -nn | egrep -e "\[0104\]" -e "\[0107\]" | wc -l)
    NICCNT=$(lspci -nn | egrep -e "\[0200\]" | wc -l)
    echo -ne "SAS/RAID HBAs Count : $(msgblue "$HBACNT") , NICs Count : $(msgblue "$NICCNT")\n"
    [ -d /sys/firmware/efi ] && msgnormal "System is running in UEFI boot mode\n" && EFIMODE="yes" || msgblue "System is running in Legacy boot mode\n"    
}

function checkmachine() {

    if grep -q ^flags.*\ hypervisor\  /proc/cpuinfo; then
        MACHINE="VIRTUAL"
        HYPERVISOR=$(lscpu | grep "Hypervisor vendor" | awk '{print $3}')
        echo "Machine is $MACHINE and the Hypervisor is $HYPERVISOR"
    else
        MACHINE="BAREMETAL"    
    fi

}

###############################################################################
# get bus of disk
# 1 - device path
function getBus() {
  BUS=""
  # usb/ata(sata/ide)/scsi
  [ -z "${BUS}" ] && BUS=$(udevadm info --query property --name "${1}" 2>/dev/null | grep ID_BUS | cut -d= -f2 | sed 's/ata/sata/')
  # usb/sata(sata/ide)/nvme
  [ -z "${BUS}" ] && BUS=$(lsblk -dpno KNAME,TRAN 2>/dev/null | grep "${1} " | awk '{print $2}') #Spaces are intentional
  # usb/scsi(sata/ide)/virtio(scsi/virtio)/mmc/nvme
  [ -z "${BUS}" ] && BUS=$(lsblk -dpno KNAME,SUBSYSTEMS 2>/dev/null | grep "${1} " | awk -F':' '{print $(NF-1)}' | sed 's/_host//') #Spaces are intentional
  echo "${BUS}"
}

function getusb() {

    # Get the VID/PID if we are in USB
    VID="0x0000"
    PID="0x0000"
    
    if [ "${BUS}" = "usb" ]; then
        VID="0x$(udevadm info --query property --name ${LOADER_DISK} | grep ID_VENDOR_ID | cut -d= -f2)"
        PID="0x$(udevadm info --query property --name ${LOADER_DISK} | grep ID_MODEL_ID | cut -d= -f2)"
        updateuserconfigfield "extra_cmdline" "pid" "$PID"
        updateuserconfigfield "extra_cmdline" "vid" "$VID"
        curpid=$(jq -r -e .general.usb_line $userconfigfile | awk -Fpid= '{print $2}' | awk '{print  $1}')
        curvid=$(jq -r -e .general.usb_line $userconfigfile | awk -Fvid= '{print $2}' | awk '{print  $1}')
        sed -i "s/${curpid}/${PID}/" $userconfigfile
        sed -i "s/${curvid}/${VID}/" $userconfigfile
    elif [ "${BUS}" != "sata" ]; then
        TEXT "Unsupported loader disks other than USB, Sata DoM, mmc, NVMe, etc."
    fi

}

function matchpciidmodule() {

    vendor="$(echo $1 | tr 'a-z' 'A-Z')"
    device="$(echo $2 | tr 'a-z' 'A-Z')"

    pciid="${vendor}d0000${device}"

    # Correction to work with tinycore jq
    matchedmodule=$(jq -e -r ".modules[] | select(.alias | contains(\"${pciid}\")?) | .name " $MODULE_ALIAS_FILE)

    # Call listextensions for extention matching
    echo "$matchedmodule"

}

function getip() {

    ethdevs=$(ls /sys/class/net/ | grep -v lo || true)

    sleep 3
    # Wait for an IP
    for eth in $ethdevs; do 
        COUNT=0
        DRIVER=$(ls -ld /sys/class/net/${eth}/device/driver 2>/dev/null | awk -F '/' '{print $NF}')
        VENDOR=$(cat /sys/class/net/${eth}/device/vendor | sed 's/0x//')
        DEVICE=$(cat /sys/class/net/${eth}/device/device | sed 's/0x//')
        if [ ! -z "${VENDOR}" ] && [ ! -z "${DEVICE}" ]; then
            MATCHDRIVER=$(echo "$(matchpciidmodule ${VENDOR} ${DEVICE})")
            if [ ! -z "${MATCHDRIVER}" ]; then
                if [ "${MATCHDRIVER}" != "${DRIVER}" ]; then
                    DRIVER=${MATCHDRIVER}
                fi
            fi
        fi    
        while true; do
            if [ ${COUNT} -eq 5 ]; then
                break
            fi
            COUNT=$((${COUNT} + 1))
            if [ $(ip route | grep default | grep metric | grep ${eth} | wc -l) -eq 1 ]; then
                IP="$(ip route show dev ${eth} 2>/dev/null | grep default | awk '{print $7}')"
                #IP="$(ip route get 1.1.1.1 2>/dev/null | grep ${eth} | awk '{print $7}')"
                IP=$(echo -n "${IP}" | tr '\n' '\b')
                LASTIP="${IP}"
                break
            else
                IP=""
            fi
            sleep 1
        done
        echo "IP Address : $(msgnormal "${IP}"), Network Interface Card : ${eth} [${VENDOR}:${DEVICE}] (${DRIVER}) "
    done
    IP="${LASTIP}"
}

function checkfiles() {

    files="user_config.json initrd-dsm zImage-dsm"

    for file in $files; do
        if [ -f /mnt/tcrp/$file ]; then
            msgnormal "File : $file OK !"
        else
            msgnormal "File : $file missing  !"
            exit 99
        fi

    done

}

function checkupgrade() {

    if [ ! -f /mnt/tcrp-p2/rd.gz ]; then
        TEXT "ERROR ! /mnt/tcrp-p2/rd.gz file not found, stopping boot process"
        exit 99
    fi
    if [ ! -f /mnt/tcrp-p2/zImage ]; then
        TEXT "ERROR ! /mnt/tcrp-p2/zImage file not found, stopping boot process"
        exit 99
    fi

    origrdhash=$(sha256sum /mnt/tcrp-p2/rd.gz | awk '{print $1}')
    origzimghash=$(sha256sum /mnt/tcrp-p2/zImage | awk '{print $1}')
    rdhash="$(jq -r -e '.general .rdhash' $userconfigfile)"
    zimghash="$(jq -r -e '.general .zimghash' $userconfigfile)"

    if [ "$loadermode" == "JOT" ]; then    
        checkmachine

        if [ "$MACHINE" = "VIRTUAL" ]; then
            msgnormal "Setting default boot entry to JOT SATA\n"
            sed -i "/set default=\"*\"/cset default=\"1\"" /mnt/tcrp-p1/boot/grub/grub.cfg
        else
            msgnormal "Setting default boot entry to JOT USB\n"
            sed -i "/set default=\"*\"/cset default=\"0\"" /mnt/tcrp-p1/boot/grub/grub.cfg
        fi        
    fi

    echo -n $(TEXT "Detecting upgrade : ")

    if [ "$rdhash" = "$origrdhash" ]; then
        msgnormal "Ramdisk OK ! "
    else
        msgwaring "Ramdisk upgrade has been detected and "
        [ -z "$IP" ] && getip
        if [ -n "$IP" ]; then
            patchramdisk 2>&1 | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>$FRIENDLOG
        else
            msgalert "The patch cannot proceed because there is no IP yet !!!! \n"
            exit 99
        fi
    fi

    if [ "$zimghash" = "$origzimghash" ]; then
        msgnormal "zImage OK ! \n"
    else
        msgwaring "zImage upgrade has been detected "
        patchkernel 2>&1 | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>$FRIENDLOG
   
        if [ "$loadermode" == "JOT" ]; then
            msgwaring "Ramdisk upgrade and zImage upgrade for JOT completed successfully!"
            TEXT "A reboot is required. Press any key to reboot..."
            read answer
            reboot
        fi
    fi
    
}

function setmac() {

    # Set custom MAC if defined
    ethdevs=$(ls /sys/class/net/ | grep -v lo || true)
    I=1
    for eth in $ethdevs; do 
        curmacmask=$(ip link | grep -A 1 ${eth} | tail -1 | awk '{print $2}' | tr '[:lower:]' '[:upper:]')
        eval "usrmac=\${mac${I}}"
        MAC="${usrmac:0:2}:${usrmac:2:2}:${usrmac:4:2}:${usrmac:6:2}:${usrmac:8:2}:${usrmac:10:2}"
        DRIVER=$(ls -ld /sys/class/net/${eth}/device/driver 2>/dev/null | awk -F '/' '{print $NF}')
        if [ "${usrmac}" != "null" ]; then
            msgnormal "Setting MAC Address from ${curmacmask} to ${MAC} on ${eth} (${DRIVER})\n" | tee -a boot.log
            ip link set dev ${eth} address ${MAC} >/dev/null 2>&1 
        fi
        I=$((${I} + 1))
        if [ "${eth}" = "eth4" ]; then
            break
        fi
    done
    /etc/init.d/S41dhcpcd restart >/dev/null 2>&1
}

function setnetwork() {

    ethdev=$(ip a | grep UP | grep -v LOOP | head -1 | awk '{print $2}' | sed -e 's/://g')

    echo "Network settings are set to static proceeding setting static IP settings" | tee -a boot.log
    staticip="$(jq -r -e .ipsettings.ipaddr /mnt/tcrp/user_config.json)"
    staticdns="$(jq -r -e .ipsettings.ipdns /mnt/tcrp/user_config.json)"
    staticgw="$(jq -r -e .ipsettings.ipgw /mnt/tcrp/user_config.json)"
    staticproxy="$(jq -r -e .ipsettings.ipproxy /mnt/tcrp/user_config.json)"

    [ -n "$staticip" ] && [ $(ip a | grep $staticip | wc -l) -eq 0 ] && ip a add "$staticip" dev $ethdev | tee -a boot.log
    [ -n "$staticdns" ] && [ $(grep ${staticdns} /etc/resolv.conf | wc -l) -eq 0 ] && sed -i "a nameserver $staticdns" /etc/resolv.conf | tee -a boot.log
    [ -n "$staticgw" ] && [ $(ip route | grep "default via ${staticgw}" | wc -l) -eq 0 ] && ip route add default via $staticgw dev $ethdev | tee -a boot.log
    [ -n "$staticproxy" ] &&
        export HTTP_PROXY="$staticproxy" && export HTTPS_PROXY="$staticproxy" &&
        export http_proxy="$staticproxy" && export https_proxy="$staticproxy" | tee -a boot.log

    IP="$(ip route get 1.1.1.1 2>/dev/null | grep $ethdev | awk '{print $7}')"
    if [ -n "${IP}" ]; then
        DRIVER=$(ls -ld /sys/class/net/${ethdev}/device/driver 2>/dev/null | awk -F '/' '{print $NF}')
        VENDOR=$(cat /sys/class/net/${ethdev}/device/vendor | sed 's/0x//')
        DEVICE=$(cat /sys/class/net/${ethdev}/device/device | sed 's/0x//')
        if [ ! -z "${VENDOR}" ] && [ ! -z "${DEVICE}" ]; then
            MATCHDRIVER=$(echo "$(matchpciidmodule ${VENDOR} ${DEVICE})")
            if [ ! -z "${MATCHDRIVER}" ]; then
                if [ "${MATCHDRIVER}" != "${DRIVER}" ]; then
                    DRIVER=${MATCHDRIVER}
                fi
            fi
        fi    
        echo "IP Address : $(msgnormal "${IP}"), Network Interface Card : ${ethdev} [${VENDOR}:${DEVICE}] (${DRIVER}) "    
    fi
}

function mountall() {

    LOADER_DISK=""
    for edisk in $(fdisk -l | grep "Disk /dev/sd" | awk '{print $2}' | sed 's/://' ); do
        if [ $(fdisk -l | grep "83 Linux" | grep ${edisk} | wc -l ) -eq 3 ]; then
            LOADER_DISK="$(blkid | grep ${edisk} | grep "6234-C863" | cut -c 1-8 | awk -F\/ '{print $3}')"
            [ -z "${LOADER_DISK}" ] && continue || break
        elif [ $(fdisk -l | grep "83 Linux" | grep ${edisk} | wc -l ) -eq 1 ]; then
            LOADER_DISK="$(blkid | grep ${edisk} | grep "6234-C863" | cut -c 1-8 | awk -F\/ '{print $3}')"
            [ -z "${LOADER_DISK}" ] && continue || break
        fi    
    done
    if [ -z "${LOADER_DISK}" ]; then
        for edisk in $(fdisk -l | grep -e "Disk /dev/nvme" -e "Disk /dev/mmc" | awk '{print $2}' | sed 's/://' ); do
            if [ $(fdisk -l | grep "83 Linux" | grep ${edisk} | wc -l ) -eq 3 ]; then
                LOADER_DISK="$(blkid | grep ${edisk} | grep "6234-C863" | cut -c 1-12 | awk -F\/ '{print $3}')"    
            fi    
        done
    fi    

    if [ -z "${LOADER_DISK}" ]; then
        TEXT "Not Supported Loader BUS Type, program Exit!!!"
        exit 99
    fi
    
    getBus "${LOADER_DISK}"

    [ "${BUS}" = "nvme" ] && LOADER_DISK="${LOADER_DISK}p"
    [ "${BUS}" = "mmc"  ] && LOADER_DISK="${LOADER_DISK}p"    

    [ ! -d /mnt/tcrp ] && mkdir /mnt/tcrp
    [ ! -d /mnt/tcrp-p1 ] && mkdir /mnt/tcrp-p1
    [ ! -d /mnt/tcrp-p2 ] && mkdir /mnt/tcrp-p2

    BOOT_DISK="${LOADER_DISK}"
    if [ -d /sys/block/${LOADER_DISK}/${LOADER_DISK}4 ]; then
      for edisk in $(fdisk -l | grep "Disk /dev/sd" | awk '{print $2}' | sed 's/://' ); do
        if [ $(fdisk -l | grep "fd Linux raid autodetect" | grep ${edisk} | wc -l ) -eq 3 ] && [ $(fdisk -l | grep "83 Linux" | grep ${edisk} | wc -l ) -eq 2 ]; then
            TEXT "This is BASIC or RAID Type Disk & Has Syno Boot Partition. $edisk"
            BOOT_DISK=$(echo "$edisk" | cut -c 6-8)
        fi
      done
      if [ "${BOOT_DISK}" = "${LOADER_DISK}" ]; then
        TEXT "Failed to find boot Partition on !!!"
        exit 99
      fi
      if [ $(fdisk -l | grep "W95 Ext" | grep ${edisk} | wc -l ) -eq 1 ]; then
        p1="4"
      else  
        p1="5"
      fi  
      p2="6"
      p3="4"
    else
      p1="1"
      p2="2"
      p3="3"
    fi

    [ "$(mount | grep ${BOOT_DISK}${p1} | wc -l)" = "0" ] && mount /dev/${BOOT_DISK}${p1} /mnt/tcrp-p1
    [ "$(mount | grep ${BOOT_DISK}${p2} | wc -l)" = "0" ] && mount /dev/${BOOT_DISK}${p2} /mnt/tcrp-p2
    [ "$(mount | grep ${LOADER_DISK}${p3} | wc -l)" = "0" ] && mount /dev/${LOADER_DISK}${p3} /mnt/tcrp

    if [ "$(mount | grep ${BOOT_DISK}${p1} | wc -l)" = "0" ]; then
        TEXT "Failed mount /dev/${BOOT_DISK}${p1} to /mnt/tcrp-p1, stopping boot process"
        exit 99
    fi

    if [ "$(mount | grep ${BOOT_DISK}${p2} | wc -l)" = "0" ]; then
        TEXT "Failed mount /dev/${BOOT_DISK}${p2} to /mnt/tcrp-p2, stopping boot process"
        exit 99
    fi

    if [ "$(mount | grep ${LOADER_DISK}${p3} | wc -l)" = "0" ]; then
        TEXT "Failed mount /dev/${LOADER_DISK}${p3} to /mnt/tcrp, stopping boot process"
        exit 99
    fi

}

function readconfig() {

    userconfigfile=/mnt/tcrp/user_config.json

    if [ -f $userconfigfile ]; then
        model="$(jq -r -e '.general .model' $userconfigfile)"
        if [ -z "$model" ]; then
            TEXT "model is not resolved. Please check the /mnt/tcrp/user_config.json file. stopping boot process"
            exit 99
        fi        
        version="$(jq -r -e '.general .version' $userconfigfile)"
        if [ -z "$version" ]; then
            TEXT "Build version is not resolved. Please check the /mnt/tcrp/user_config.json file. stopping boot process"
            exit 99
        fi        
        smallfixnumber="$(jq -r -e '.general .smallfixnumber' $userconfigfile)"
        if [ -z "$smallfixnumber" ]; then
            TEXT "Update(smallfixnumber) is not resolved. Please check the /mnt/tcrp/user_config.json file."
        #    exit 99
        fi        
        redpillmake="$(jq -r -e '.general .redpillmake' $userconfigfile)"
        friendautoupd="$(jq -r -e '.general .friendautoupd' $userconfigfile)"
        hidesensitive="$(jq -r -e '.general .hidesensitive' $userconfigfile)"
        serial="$(jq -r -e '.extra_cmdline .sn' $userconfigfile)"
        if [ -z "$serial" ]; then
            TEXT "serial is not resolved. Please check the /mnt/tcrp/user_config.json file. stopping boot process"
            exit 99
        fi        
        rdhash="$(jq -r -e '.general .rdhash' $userconfigfile)"
        zimghash="$(jq -r -e '.general .zimghash' $userconfigfile)"
        mac1="$(jq -r -e '.extra_cmdline .mac1' $userconfigfile)"
        if [ -z "$mac1" ]; then
            TEXT "mac1 is not resolved. Please check the /mnt/tcrp/user_config.json file. stopping boot process"
            exit 99
        fi        
        mac2="$(jq -r -e '.extra_cmdline .mac2' $userconfigfile)"
        mac3="$(jq -r -e '.extra_cmdline .mac3' $userconfigfile)"
        mac4="$(jq -r -e '.extra_cmdline .mac4' $userconfigfile)"
        staticboot="$(jq -r -e '.general .staticboot' $userconfigfile)"
        dmpm="$(jq -r -e '.general.devmod' $userconfigfile)"
        loadermode="$(jq -r -e '.general.loadermode' $userconfigfile)"
        ucode=$(jq -r -e '.general.ucode' "$userconfigfile")
        tz=$(echo $ucode | cut -c 4-)

        export LANG=${ucode}.UTF-8
        export LC_ALL=${ucode}.UTF-8
  
    else
        TEXT "ERROR ! User config file : $userconfigfile not found"
    fi

    [ -z "$redpillmake" ] || [ "$redpillmake" = "null" ] && echo "redpillmake setting not found while reading $userconfigfile, defaulting to dev" && redpillmake="dev"

}

function boot() {

    # Welcome message
    welcome

    gethw

    # user_config.json ipsettings block
    # user_config.json ipsettings block

    #  "ipsettings" : {
    #     "ipset": "static",
    #     "ipaddr":"192.168.71.146/24",
    #     "ipgw" : "192.168.71.1",
    #     "ipdns": "",
    #     "ipproxy" : ""
    # },
    if [ "$(jq -r -e .ipsettings.ipset /mnt/tcrp/user_config.json)" = "static" ]; then
        setnetwork
    else
        # Set Mac Address according to user_config
        setmac

        # Get IP Address after setting new mac address to display IP
        getip
    fi

    # Check whether the major version has been updated from under 7.2 to 7.2
    #checkversionup

    [ -z "$IP" ] && getip

    # Check ip upgrade is required
    checkupgrade

    # Get USB list and set VID-PID Automatically
    getusb

    # check if new TCRP Friend version is available to download
    [ -z "$IP" ] && getip
    checkinternet

    [ "${INTERNET}" = "ON" ] && upgradefriend

    if [ -f /mnt/tcrp/stopatfriend ]; then
        echo "Stop at friend detected, stopping boot"
        rm -f /mnt/tcrp/stopatfriend
        touch /root/stoppedatrequest
        exit 0
    fi

    if grep -q "debugfriend" /proc/cmdline; then
        echo "Debug Friend set, stopping boot process"
        exit 0
    fi

    if [ "${BUS}" = "sata" ]; then

        CMDLINE_LINE=$(jq -r -e '.general .sata_line' /mnt/tcrp/user_config.json)
        # Check dom size and set max size accordingly
        # 2024.03.17 Force the dom_szmax limit of the injected bootloader to be 16GB
        if [ "${BOOT_DISK}" = "${LOADER_DISK}" ]; then
            CMDLINE_LINE+="dom_szmax=$(fdisk -l /dev/${LOADER_DISK} | head -1 | awk -F: '{print $2}' | awk '{ print $1*1024}') "
        else
            CMDLINE_LINE+="dom_szmax=32768 "
        fi

    else
        CMDLINE_LINE=$(jq -r -e '.general .usb_line' /mnt/tcrp/user_config.json)
    fi

    #[ "$1" = "gettycon" ] && CMDLINE_LINE+=" gettycon "

    [ "$1" = "forcejunior" ] && CMDLINE_LINE+="force_junior "

    #CMDLINE_LINE+="skip_vender_mac_interfaces=0,1,2,3,4,5,6,7 panic=5 "

    export MOD_ZIMAGE_FILE="/mnt/tcrp/zImage-dsm"
    export MOD_RDGZ_FILE="/mnt/tcrp/initrd-dsm"

    echo
    echo "zImage : ${MOD_ZIMAGE_FILE} initrd : ${MOD_RDGZ_FILE}, Module Processing Method : $(msgnormal "${dmpm}")"
    echo "cmdline : ${CMDLINE_LINE}"
    echo
    TEXT "Access $(msgalert "http://${IP}:7681") via the TTYD web terminal to check the problem."
    TEXT "(If you have any problems with the DSM installation steps, check the $(echo -e "\033[1;33m/var/log/linuxrc.syno.log\033[0m" file in this access)"
    TEXT "Default TTYD root password is \033[1;33mblank\033[0m"
    echo        
    TEXT "User config is on \033[1;33m/mnt/tcrp/user_config.json\033[0m"
    #if [ "$1" != "gettycon" ] && [ "$1" != "forcejunior" ]; then    
    if [ "$1" != "forcejunior" ]; then    
 #       msgalert "Press <g> to enter a Getty Console to solve trouble\n"
        echo -e "\033[1;31m$(TEXT "Press <r> to enter a menu for Reset DSM Password")\033[0m"
        echo -e "\033[1;32m$(TEXT "Press <e> to enter a menu for Edit USB/SATA Command Line")\033[0m"
        echo -e "\033[1;33m$(TEXT "Press <j> to enter a Junior mode (to re-install DSM)")\033[0m"
#    elif [ "$1" = "gettycon" ]; then
#        msgalert "Entering a Getty Console to solve trouble...\n"
    elif [ "$1" = "forcejunior" ]; then
        echo -e "\033[1;33m$(TEXT "Entering a Junior mode (to re-install DSM)...")\033[0m"
    fi
    
    # Check netif_num matches the number of configured mac addresses as if these does not match redpill will cause a KP
    echo ${CMDLINE_LINE} >/tmp/cmdline.out
    while IFS=" " read -r -a line; do
        printf "%s\n" "${line[@]}"
    done </tmp/cmdline.out | egrep -i "sn|pid|vid|mac|hddhotplug|netif_num" | sort >/tmp/cmdline.check

    . /tmp/cmdline.check

    [ $(grep mac /tmp/cmdline.check | grep -v vender_mac | wc -l) != $netif_num ] && msgalert "FAILED to match the count of configured netif_num and mac addresses, DSM will panic, exiting so you can fix this\n" && exit 99

    #If EFI then add withefi to CMDLINE_LINE
    if [ "$EFIMODE" = "yes" ] && [ $(echo ${CMDLINE_LINE} | grep withefi | wc -l) -le 0 ]; then
        CMDLINE_LINE+=" withefi " && echo -e "\033[1;33m$(TEXT "EFI booted system with no EFI option, adding withefi to cmdline\n"
    fi

    #if [ "${INTERNET}" = "ON" ]; then
    #    pip install click 2>&1 | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >> $FRIENDLOG
    #    pip install qrcode 2>&1 | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >> $FRIENDLOG
    #    pip install Image 2>&1 | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >> $FRIENDLOG
    #fi   

    if [ "$staticboot" = "true" ]; then
        TEXT "Static boot set, rebooting to static ..."
        cp tools/libdevmapper.so.1.02 /usr/lib
        cp tools/grub-editenv /usr/bin
        chmod +x /usr/bin/grub-editenv
        /usr/bin/grub-editenv /mnt/tcrp-p1/boot/grub/grubenv create        
        [ "${BUS}" = "sata" ] && setgrubdefault 1
        [ "${BUS}" = "usb" ] && setgrubdefault 0
        reboot
    else

        #if [ "$1" != "gettycon" ] && [ "$1" != "forcejunior" ]; then
        if [ "$1" != "forcejunior" ]; then
            countdown "booting"
        fi
        TEXT "Boot timeout exceeded, booting ... "
        echo
        TEXT "\"HTTP, Synology Web Assistant (BusyBox httpd)\" service may take 20 - 40 seconds."
        TEXT "(Network access is not immediately available)"
        echo    
        TEXT "Kernel loading has started, nothing will be displayed here anymore ..."

        if [ "${INTERNET}" = "ON" ]; then
            [ -n "${IP}" ] && URL="http://${IP}:5000" || URL="http://find.synology.com/"
            python functions.py makeqr -d "${URL}" -l "br" -o "/tmp/qrcode.png"
            #curl -skL https://quickchart.io/qr?text="${URL}" -o /tmp/qrcode.png
            [ -f "/tmp/qrcode.png" ] && echo | fbv -acufi "/tmp/qrcode.png" >/dev/null 2>/dev/null || true
        fi    
        
        [ "${hidesensitive}" = "true" ] && clear

        if [ $(echo ${CMDLINE_LINE} | grep withefi | wc -l) -eq 1 ]; then
            kexec -l "${MOD_ZIMAGE_FILE}" --initrd "${MOD_RDGZ_FILE}" --command-line="${CMDLINE_LINE}"
        else
            echo -e "\033[1;33m$(TEXT "Booting with noefi, please notice that this might cause issues")\033[0m"
            kexec --noefi -l "${MOD_ZIMAGE_FILE}" --initrd "${MOD_RDGZ_FILE}" --command-line="${CMDLINE_LINE}"
        fi

        kexec -f -e
    fi
}

function welcome() {

    clear
    echo -en "\033[7;32m--------------------------------------={ TinyCore RedPill Friend }=--------------------------------------\033[0m\n"

    # Echo Version
    echo "TCRP Friend Version : $BOOTVER"
    showlastupdate
}

function initialize() {
    # Checkif running in TC
    [ "$(hostname)" != "tcrpfriend" ] && echo "ERROR running on alien system" && exit 99

    # Mount loader disk
    mountall

    # Read Configuration variables
    readconfig

    # No network devices
    eths=$(ls /sys/class/net/ | grep -v lo || true)    
    [ $(echo ${eths} | wc -w) -le 0 ] && TEXT "No NIC found! - Loader does not work without Network connection." && exit 99

    # Update user config file to latest version
    updateuserconfigfile

    [ "${smallfixnumber}" = "null" ] && patchramdisk 2>&1 | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>$FRIENDLOG

    # unzip modules.alias
    [ -f modules.alias.3.json.gz ] && gunzip -f modules.alias.3.json.gz
    [ -f modules.alias.4.json.gz ] && gunzip -f modules.alias.4.json.gz    

    ORIGIN_PLATFORM=$(cat /mnt/tcrp-p1/GRUB_VER | grep PLATFORM | cut -d "=" -f2 | tr '[:upper:]' '[:lower:]' | sed 's/"//g')

    case $ORIGIN_PLATFORM in
    bromolow | braswell)
        MODULE_ALIAS_FILE="modules.alias.3.json"
        ;;
    apollolake | broadwell | broadwellnk | v1000 | denverton | geminilake | broadwellnkv2 | broadwellntbap | purley | *)
        MODULE_ALIAS_FILE="modules.alias.4.json"
        ;;
    esac
}

case $1 in

update)
    getip
    upgradefriend
    ;;

patchramdisk)
    initialize
    patchramdisk
    ;;

patchkernel)
    initialize
    patchkernel
    ;;

rebuildloader)
    initialize
    rebuildloader
    cp -vf /mnt/tcrp/grub72.cfg /mnt/tcrp-p1/boot/grub/grub.cfg
    cp -vf /mnt/tcrp/initrd-dsm72 /mnt/tcrp/initrd-dsm    
    #patchkernel
    #patchramdisk
    ;;

version)
    version $@
    ;;

extractramdisk)
    initialize
    extractramdisk
    ;;

forcejunior)
    initialize
    boot forcejunior
    ;;

#gettycon)
#    initialize
#    boot gettycon
#    ;;

menu)
    mainmenu
    initialize
    boot
    ;;

*)
    initialize
    # All done, lets go for boot/
    boot
    ;;

esac

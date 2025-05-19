#!/usr/bin/env bash

##### explanation ###################################################################################
# As you edit the cmdline of grub.cfg
# Edit /mnt/tcrp/user_config.json to modify cmdline used by TCRP FRIEND
#####################################################################################################

TMP_PATH=/tmp
USER_CONFIG_FILE="/mnt/tcrp/user_config.json"
    
###############################################################################
# Read json config file
function readConfigMenu() {

    USB_LINE=$(jq -r -e '.general.usb_line' "$USER_CONFIG_FILE")
    SATA_LINE=$(jq -r -e '.general.sata_line' "$USER_CONFIG_FILE")

    MODEL=$(jq -r -e '.general.model' "$USER_CONFIG_FILE")
    BUILD=$(jq -r -e '.general.version' "$USER_CONFIG_FILE" | cut -c 7-)
    SN=$(jq -r -e '.extra_cmdline.sn' "$USER_CONFIG_FILE")

    MACADDR1="$(jq -r -e '.extra_cmdline.mac1' $USER_CONFIG_FILE)"
    MACADDR2="$(jq -r -e '.extra_cmdline.mac2' $USER_CONFIG_FILE)"
    MACADDR3="$(jq -r -e '.extra_cmdline.mac3' $USER_CONFIG_FILE)"
    MACADDR4="$(jq -r -e '.extra_cmdline.mac4' $USER_CONFIG_FILE)"

    LAYOUT=$(jq -r -e '.general.layout' "$USER_CONFIG_FILE")
    KEYMAP=$(jq -r -e '.general.keymap' "$USER_CONFIG_FILE")

    DMPM=$(jq -r -e '.general.devmod' "$USER_CONFIG_FILE")
    LDRMODE=$(jq -r -e '.general.loadermode' "$USER_CONFIG_FILE")

}

###############################################################################
# Mounts backtitle dynamically
function backtitle() {
  BACKTITLE=" ${DMPM}"
  BACKTITLE+=" ${LDRMODE}"
  if [ -n "${MODEL}" ]; then
    BACKTITLE+=" ${MODEL}"
  else
    BACKTITLE+=" (no model)"
  fi
  if [ -n "${BUILD}" ]; then
    BACKTITLE+=" ${BUILD}"
  else
    BACKTITLE+=" (no build)"
  fi
  if [ -n "${SN}" ]; then
    BACKTITLE+=" ${SN}"
  else
    BACKTITLE+=" (no SN)"
  fi
  if [ "${MACADDR1}" == "null" ]; then
    BACKTITLE+=" (no MAC1)"  
  else
    BACKTITLE+=" ${MACADDR1}"
  fi
  if [ "${MACADDR2}" == "null" ]; then
    BACKTITLE+=" (no MAC2)"  
  else
    BACKTITLE+=" ${MACADDR2}"
  fi
  if [ "${MACADDR3}" == "null" ]; then
    BACKTITLE+=" (no MAC3)"  
  else
    BACKTITLE+=" ${MACADDR3}"
  fi
  if [ "${MACADDR4}" == "null" ]; then
    BACKTITLE+=" (no MAC4)"  
  else
    BACKTITLE+=" ${MACADDR4}"
  fi
  if [ -n "${KEYMAP}" ]; then
    BACKTITLE+=" (${LAYOUT}/${KEYMAP})"
  else
    BACKTITLE+=" (qwerty/us)"
  fi
  echo ${BACKTITLE}
}

###############################################################################
# Shows menu to user type one or generate randomly
function usbMenu() {
      while true; do
        dialog --backtitle "`backtitle`" \
          --inputbox "Edit USB Command Line " 0 0 "${USB_LINE}" \
          2>${TMP_PATH}/resp
        [ $? -ne 0 ] && return
        USB_LINE=`cat ${TMP_PATH}/resp`
        if [ -z "${USB_LINE}" ]; then
          return
        else
          break
        fi
      done
      
    json=$(jq --arg var "${USB_LINE}" '.general.usb_line = $var' $USER_CONFIG_FILE) && echo -E "${json}" | jq . >$USER_CONFIG_FILE

}

###############################################################################
# Shows menu to generate randomly or to get realmac
function sataMenu() {
      while true; do
        dialog --backtitle "`backtitle`" \
          --inputbox "Edit Sata Command Line" 0 0 "${SATA_LINE}" \
          2>${TMP_PATH}/resp
        [ $? -ne 0 ] && return
        SATA_LINE=`cat ${TMP_PATH}/resp`
        if [ -z "${SATA_LINE}" ]; then
          return
        else
          break
        fi
      done
      
    json=$(jq --arg var "${SATA_LINE}" '.general.sata_line = $var' $USER_CONFIG_FILE) && echo -E "${json}" | jq . >$USER_CONFIG_FILE      

}

function bootmenu() {
    clear 
    initialize    
    boot
}

###############################################################################
# Find and mount the DSM root filesystem
function findDSMRoot() {
  local DSMROOTS=""
  [ -z "${DSMROOTS}" ] && DSMROOTS="$(mdadm --detail --scan 2>/dev/null | grep -E "name=SynologyNAS:0|name=DiskStation:0|name=SynologyNVR:0|name=BeeStation:0" | awk '{print $2}' | uniq)"
  [ -z "${DSMROOTS}" ] && DSMROOTS="$(lsblk -pno KNAME,PARTN,FSTYPE,FSVER,LABEL | grep -E "sd[a-z]{1,2}1" | grep -w "linux_raid_member" | grep "0.9" | awk '{print $1}')"
  echo "${DSMROOTS}"
  return 0
}

###############################################################################
# check and fix the DSM root partition
# 1 - DSM root path
function fixDSMRootPart() {
  if mdadm --detail "${1}" 2>/dev/null | grep -i "State" | grep -iEq "active|FAILED|Not Started"; then
    mdadm --stop "${1}" >/dev/null 2>&1
    mdadm --assemble --scan >/dev/null 2>&1
    fsck "${1}" >/dev/null 2>&1
  fi
}

###############################################################################
# Reset DSM system password
function resetDSMPassword() {
  DSMROOTS="$(findDSMRoot)"
  if [ -z "${DSMROOTS}" ]; then
    dialog --backtitle "$(backtitle)" --colors --aspect 50 \
      --title "Advanced" \
      --msgbox "No DSM system partition(md0) found!\nPlease insert all disks before continuing." 0 0
    return
  fi
  rm -f "${TMP_PATH}/menu"
  mkdir -p "${TMP_PATH}/mdX"
  for I in ${DSMROOTS}; do
    fixDSMRootPart "${I}"
    /sbin/mdadm -C /dev/md0 -e 0.9 -amd -R -l1 --force -n1 "${I}"
    T="$(blkid -o value -s TYPE /dev/md0 2>/dev/null)"
    mount -t "${T:-ext4}" /dev/md0 "${TMP_PATH}/mdX"
    [ $? -ne 0 ] && continue
    if [ -f "${TMP_PATH}/mdX/etc/shadow" ]; then
      while read -r L; do
        U=$(echo "${L}" | awk -F ':' '{if ($2 != "*" && $2 != "!!") print $1;}')
        [ -z "${U}" ] && continue
        E=$(echo "${L}" | awk -F ':' '{if ($8 == "1") print "disabled"; else print "        ";}')
        grep -q "status=on" "${TMP_PATH}/mdX/usr/syno/etc/packages/SecureSignIn/preference/${U}/method.config" 2>/dev/null
        [ $? -eq 0 ] && S="SecureSignIn" || S="            "
        printf "\"%-36s %-10s %-14s\"\n" "${U}" "${E}" "${S}" >>"${TMP_PATH}/menu"
      done <<<"$(cat "${TMP_PATH}/mdX/etc/shadow" 2>/dev/null)"
    fi
    umount "${TMP_PATH}/mdX"
    [ -f "${TMP_PATH}/menu" ] && break
  done
  rm -rf "${TMP_PATH}/mdX"
  if [ ! -f "${TMP_PATH}/menu" ]; then
    dialog --backtitle "$(backtitle)" --colors --aspect 50 \
      --title "Advanced" \
      --msgbox "All existing users have been disabled. Please try adding new user." 0 0
    return
  fi
  dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Advanced" \
    --no-items --menu "Choose a user name" 0 0 20 --file "${TMP_PATH}/menu" \
    2>"${TMP_PATH}/resp"
  [ $? -ne 0 ] && return
  USER="$(cat "${TMP_PATH}/resp" 2>/dev/null | awk '{print $1}')"
  [ -z "${USER}" ] && return
  local STRPASSWD
  while true; do
    dialog --backtitle "$(backtitle)" --colors --aspect 50 \
      --title "Advanced" \
      --inputbox "$(printf "Type a new password for user '%s'" "${USER}")" 0 70 "" \
      2>"${TMP_PATH}/resp"
    [ $? -ne 0 ] && break
    resp="$(cat "${TMP_PATH}/resp" 2>/dev/null)"
    if [ -z "${resp}" ]; then
      dialog --backtitle "$(backtitle)" --colors --aspect 50 \
        --title "Advanced" \
        --msgbox "Invalid password" 0 0
    else
      STRPASSWD="${resp}"
      break
    fi
  done
  rm -f "${TMP_PATH}/isOk"
  (
    mkdir -p "${TMP_PATH}/mdX"
    local NEWPASSWD
    NEWPASSWD="$(openssl passwd -6 -salt "$(openssl rand -hex 8)" "${STRPASSWD}")"
    for I in ${DSMROOTS}; do
      fixDSMRootPart "${I}"
      T="$(blkid -o value -s TYPE "${I}" 2>/dev/null)"
      mount -t "${T:-ext4}" "${I}" "${TMP_PATH}/mdX"
      [ $? -ne 0 ] && continue
      sed -i "s|^${USER}:[^:]*|${USER}:${NEWPASSWD}|" "${TMP_PATH}/mdX/etc/shadow"
      sed -i "/^${USER}:/ s/^\(${USER}:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\)[^:]*:/\1:/" "${TMP_PATH}/mdX/etc/shadow"
      sed -i "s|status=on|status=off|g" "${TMP_PATH}/mdX/usr/syno/etc/packages/SecureSignIn/preference/${USER}/method.config" 2>/dev/null
      sync
      echo "true" >"${TMP_PATH}/isOk"
      umount "${TMP_PATH}/mdX"
    done
    rm -rf "${TMP_PATH}/mdX"
  ) 2>&1 | dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Advanced" \
    --progressbox "Resetting ..." 20 100
  if [ -f "${TMP_PATH}/isOk" ]; then
    MSG="$(printf "Reset password for user '%s' completed." "${USER}")"
  else
    MSG="$(printf "Reset password for user '%s' failed." "${USER}")"
  fi
  dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Advanced" \
    --msgbox "${MSG}" 0 0
  return
}

function changePassword() {
  dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Settings" \
    --inputbox "New password: (Empty for default value 'rr')" 0 70 \
    2>"${TMP_PATH}/resp"
  [ $? -ne 0 ] && return
  
  dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Settings" \
    --infobox "Setting ..." 20 100
  
  resp="$(cat "${TMP_PATH}/resp" 2>/dev/null)"
  [ -z "${resp}" ] && return
  
  local STRPASSWD NEWPASSWD
  STRPASSWD="${resp}"
  NEWPASSWD="$(openssl passwd -6 -salt "$(openssl rand -hex 8)" "${STRPASSWD:-rr}")"
  cp -pf /etc/shadow /etc/shadow-
  sed -i "s|^root:[^:]*|root:${NEWPASSWD}|" /etc/shadow

  local RDXZ_PATH="${TMP_PATH}/rdxz_tmp"
  rm -rf "${RDXZ_PATH}"
  mkdir -p "${RDXZ_PATH}"
  local INITRD_FORMAT
  if [ -f "${RR_RAMUSER_FILE}" ]; then
    INITRD_FORMAT=$(file -b --mime-type "${RR_RAMUSER_FILE}")
    case "${INITRD_FORMAT}" in
    *'x-cpio'*) (cd "${RDXZ_PATH}" && cpio -idm <"${RR_RAMUSER_FILE}") >/dev/null 2>&1 ;;
    *'x-xz'*) (cd "${RDXZ_PATH}" && xz -dc "${RR_RAMUSER_FILE}" | cpio -idm) >/dev/null 2>&1 ;;
    *'x-lz4'*) (cd "${RDXZ_PATH}" && lz4 -dc "${RR_RAMUSER_FILE}" | cpio -idm) >/dev/null 2>&1 ;;
    *'x-lzma'*) (cd "${RDXZ_PATH}" && lzma -dc "${RR_RAMUSER_FILE}" | cpio -idm) >/dev/null 2>&1 ;;
    *'x-bzip2'*) (cd "${RDXZ_PATH}" && bzip2 -dc "${RR_RAMUSER_FILE}" | cpio -idm) >/dev/null 2>&1 ;;
    *'gzip'*) (cd "${RDXZ_PATH}" && gzip -dc "${RR_RAMUSER_FILE}" | cpio -idm) >/dev/null 2>&1 ;;
    *'zstd'*) (cd "${RDXZ_PATH}" && zstd -dc "${RR_RAMUSER_FILE}" | cpio -idm) >/dev/null 2>&1 ;;
    *) ;;
    esac
  else
    INITRD_FORMAT="application/zstd"
  fi

  if [ "${STRPASSWD:-rr}" = "rr" ]; then
    rm -f ${RDXZ_PATH}/etc/shadow* 2>/dev/null
  else
    mkdir -p "${RDXZ_PATH}/etc"
    cp -pf /etc/shadow* ${RDXZ_PATH}/etc && chown root:root ${RDXZ_PATH}/etc/shadow* && chmod 600 ${RDXZ_PATH}/etc/shadow*
  fi

  if [ -n "$(ls -A "${RDXZ_PATH}" 2>/dev/null)" ] && [ -n "$(ls -A "${RDXZ_PATH}/etc" 2>/dev/null)" ]; then
    # local RDSIZE=$(du -sb "${RDXZ_PATH}" 2>/dev/null | awk '{print $1}')
    case "${INITRD_FORMAT}" in
    *'x-cpio'*) (cd "${RDXZ_PATH}" && find . 2>/dev/null | cpio -o -H newc -R root:root >"${RR_RAMUSER_FILE}") >/dev/null 2>&1 ;;
    *'x-xz'*) (cd "${RDXZ_PATH}" && find . 2>/dev/null | cpio -o -H newc -R root:root | xz -9 -C crc32 -c - >"${RR_RAMUSER_FILE}") >/dev/null 2>&1 ;;
    *'x-lz4'*) (cd "${RDXZ_PATH}" && find . 2>/dev/null | cpio -o -H newc -R root:root | lz4 -9 -l -c - >"${RR_RAMUSER_FILE}") >/dev/null 2>&1 ;;
    *'x-lzma'*) (cd "${RDXZ_PATH}" && find . 2>/dev/null | cpio -o -H newc -R root:root | lzma -9 -c - >"${RR_RAMUSER_FILE}") >/dev/null 2>&1 ;;
    *'x-bzip2'*) (cd "${RDXZ_PATH}" && find . 2>/dev/null | cpio -o -H newc -R root:root | bzip2 -9 -c - >"${RR_RAMUSER_FILE}") >/dev/null 2>&1 ;;
    *'gzip'*) (cd "${RDXZ_PATH}" && find . 2>/dev/null | cpio -o -H newc -R root:root | gzip -9 -c - >"${RR_RAMUSER_FILE}") >/dev/null 2>&1 ;;
    *'zstd'*) (cd "${RDXZ_PATH}" && find . 2>/dev/null | cpio -o -H newc -R root:root | zstd -19 -T0 -f -c - >"${RR_RAMUSER_FILE}") >/dev/null 2>&1 ;;
    *) ;;
    esac
  else
    rm -f "${RR_RAMUSER_FILE}"
  fi
  rm -rf "${RDXZ_PATH}"

  if [ "${STRPASSWD:-rr}" = "rr" ]; then
    MSG="password for root restored."
  else
    MSG="password for root changed."
  fi
  dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Settings" \
    --msgbox "${MSG}" 0 0
  return
}
          
# Main function loop
function mainmenu() {
  
  readConfigMenu

  # for test        
  resetDSMPassword
  exit 0
          
  NEXT="m"
  while true; do

    echo "d \"Reset DSM Password\""    > "${TMP_PATH}/menu"     
    echo "s \"Edit USB Line\""         >> "${TMP_PATH}/menu"
    echo "a \"Edit SATA Line\""        >> "${TMP_PATH}/menu"
    echo "r \"continue boot\""         >> "${TMP_PATH}/menu"

    dialog --clear --default-item ${NEXT} --backtitle "`backtitle`" --colors \
      --menu "As you edit the cmdline of grub.cfg\nEdit /mnt/tcrp/user_config.json to modify cmdline used by TCRP FRIEND" 0 0 0 --file "${TMP_PATH}/menu" \
      2>${TMP_PATH}/resp
    [ $? -ne 0 ] && break
    case `<"${TMP_PATH}/resp"` in
      d) resetDSMPassword; NEXT="r" ;;
      s) usbMenu;      NEXT="r" ;;
      a) sataMenu;     NEXT="r" ;;
      r) bootmenu ;;
      e) break ;;
    esac
  done

}    

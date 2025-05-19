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
function changeDSMPassword() {
  DSMROOTS="$(findDSMRoot)"
  if [ -z "${DSMROOTS}" ]; then
    dialog --backtitle "$(backtitle)" --colors --aspect 50 \
      --title "Change DSM New Password" \
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
    mdadm --stop /dev/md0
    [ -f "${TMP_PATH}/menu" ] && break
  done
  rm -rf "${TMP_PATH}/mdX"
  if [ ! -f "${TMP_PATH}/menu" ]; then
    dialog --backtitle "$(backtitle)" --colors --aspect 50 \
      --title "Change DSM New Password" \
      --msgbox "All existing users have been disabled. Please try adding new user." 0 0
    return
  fi
  dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Change DSM New Password" \
    --no-items --menu "Choose a user name" 0 0 20 --file "${TMP_PATH}/menu" \
    2>"${TMP_PATH}/resp"
  [ $? -ne 0 ] && return
  USER="$(cat "${TMP_PATH}/resp" 2>/dev/null | awk '{print $1}')"
  [ -z "${USER}" ] && return
  local STRPASSWD
  while true; do
    dialog --backtitle "$(backtitle)" --colors --aspect 50 \
      --title "Change DSM New Password" \
      --inputbox "$(printf "Type a new password for user '%s'" "${USER}")" 0 70 "" \
      2>"${TMP_PATH}/resp"
    [ $? -ne 0 ] && break
    resp="$(cat "${TMP_PATH}/resp" 2>/dev/null)"
    if [ -z "${resp}" ]; then
      dialog --backtitle "$(backtitle)" --colors --aspect 50 \
        --title "Change DSM New Password" \
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
      /sbin/mdadm -C /dev/md0 -e 0.9 -amd -R -l1 --force -n1 "${I}"    
      T="$(blkid -o value -s TYPE /dev/md0 2>/dev/null)"
      mount -t "${T:-ext4}" /dev/md0 "${TMP_PATH}/mdX"
      [ $? -ne 0 ] && continue
      sed -i "s|^${USER}:[^:]*|${USER}:${NEWPASSWD}|" "${TMP_PATH}/mdX/etc/shadow"
      sed -i "/^${USER}:/ s/^\(${USER}:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\)[^:]*:/\1:/" "${TMP_PATH}/mdX/etc/shadow"
      sed -i "s|status=on|status=off|g" "${TMP_PATH}/mdX/usr/syno/etc/packages/SecureSignIn/preference/${USER}/method.config" 2>/dev/null
      sync
      echo "true" >"${TMP_PATH}/isOk"
      umount "${TMP_PATH}/mdX"
      mdadm --stop /dev/md0
    done
    rm -rf "${TMP_PATH}/mdX"
  ) 2>&1 | dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Change DSM New Password" \
    --progressbox "Resetting ..." 20 100
  if [ -f "${TMP_PATH}/isOk" ]; then
    MSG="$(printf "Reset password for user '%s' completed." "${USER}")"
  else
    MSG="$(printf "Reset password for user '%s' failed." "${USER}")"
  fi
  dialog --backtitle "$(backtitle)" --colors --aspect 50 \
    --title "Change DSM New Password" \
    --msgbox "${MSG}" 0 0
  return
}

###############################################################################
# Add new DSM user
function addNewDSMUser() {
  DSMROOTS="$(findDSMRoot)"
  if [ -z "${DSMROOTS}" ]; then
    dialog --title "Add New DSM User" \
      --msgbox "No DSM system partition(md0) found!\nPlease insert all disks before continuing." 0 0
    return
  fi
  MSG="Add to administrators group by default"
  dialog --title "Add New DSM User" \
    --form "${MSG}" 8 60 3 \
    "username:" 1 1 "" 1 10 50 0 \
    "password:" 2 1 "" 2 10 50 0 \
    2>"${TMP_PATH}/resp"
  [ $? -ne 0 ] && return
  username="$(sed -n '1p' "${TMP_PATH}/resp" 2>/dev/null)"
  password="$(sed -n '2p' "${TMP_PATH}/resp" 2>/dev/null)"
  rm -f "${TMP_PATH}/isOk"
  (
    ONBOOTUP=""
    ONBOOTUP="${ONBOOTUP}if synouser --enum local | grep -q ^${username}\$; then synouser --setpw ${username} ${password}; else synouser --add ${username} ${password} mshell 0 user@mshell.com 1; fi\n"
    ONBOOTUP="${ONBOOTUP}synogroup --memberadd administrators ${username}\n"
    ONBOOTUP="${ONBOOTUP}echo \"DELETE FROM task WHERE task_name LIKE 'MSHELLONBOOTUPRR_ADDUSER';\" | sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db\n"

    mkdir -p "${TMP_PATH}/mdX"
    for I in ${DSMROOTS}; do
      fixDSMRootPart "${I}"
      /sbin/mdadm -C /dev/md0 -e 0.9 -amd -R -l1 --force -n1 "${I}"    
      T="$(blkid -o value -s TYPE /dev/md0 2>/dev/null)"
      mount -t "${T:-ext4}" /dev/md0 "${TMP_PATH}/mdX"
      [ $? -ne 0 ] && continue
      if [ -f "${TMP_PATH}/mdX/usr/syno/etc/esynoscheduler/esynoscheduler.db" ]; then
        sqlite3 "${TMP_PATH}/mdX/usr/syno/etc/esynoscheduler/esynoscheduler.db" <<EOF
DELETE FROM task WHERE task_name LIKE 'MSHELLONBOOTUPRR_ADDUSER';
INSERT INTO task VALUES('MSHELLONBOOTUPRR_ADDUSER', '', 'bootup', '', 1, 0, 0, 0, '', 0, '$(echo -e "${ONBOOTUP}")', 'script', '{}', '', '', '{}', '{}');
EOF
        sync
        echo "true" >"${TMP_PATH}/isOk"
      fi
      umount "${TMP_PATH}/mdX"
      mdadm --stop /dev/md0
    done
    rm -rf "${TMP_PATH}/mdX"
  ) 2>&1 | dialog --title "Add New DSM User" \
    --progressbox "Adding ..." 20 100
  if [ -f "${TMP_PATH}/isOk" ]; then
    MSG=$(printf "Add new user '%s' completed." "${username}")
  else
    MSG=$(printf "Add new user '%s' failed." "${username}")
  fi
  dialog --title "Add New DSM User" \
    --msgbox "${MSG}" 0 0
  return
}
          
# Main function loop
function mainmenu() {
  
  readConfigMenu

  # for test        
  #changeDSMPassword
  #exit 0
          
  NEXT="m"
  while true; do

    echo "d \"Change DSM New Password\""    > "${TMP_PATH}/menu"
    echo "n \"Add New DSM User\""      >> "${TMP_PATH}/menu"
    echo "s \"Edit USB Line\""         >> "${TMP_PATH}/menu"
    echo "a \"Edit SATA Line\""        >> "${TMP_PATH}/menu"
    echo "r \"continue boot\""         >> "${TMP_PATH}/menu"

    dialog --clear --default-item ${NEXT} --backtitle "`backtitle`" --colors \
      --menu "As you edit the cmdline of grub.cfg\nEdit /mnt/tcrp/user_config.json to modify cmdline used by TCRP FRIEND" 0 0 0 --file "${TMP_PATH}/menu" \
      2>${TMP_PATH}/resp
    [ $? -ne 0 ] && break
    case `<"${TMP_PATH}/resp"` in
      d) changeDSMPassword; NEXT="r" ;;
      n) addNewDSMUser; NEXT="r" ;;
      s) usbMenu;      NEXT="r" ;;
      a) sataMenu;     NEXT="r" ;;
      r) bootmenu ;;
      e) break ;;
    esac
  done

}    

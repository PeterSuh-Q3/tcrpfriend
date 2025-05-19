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
# Reset DSM password
function resetPassword() {

  LOADER_DISK=$(blkid | grep "6234-C863" | cut -c 1-8 | awk -F\/ '{print $3}')

  rm -f "${TMP_PATH}/menu"
  mkdir -p "${TMP_PATH}/sdX1"
  for I in $(ls /dev/sd*1 2>/dev/null | grep -v "${LOADER_DISK}1"); do
    mount ${I} "${TMP_PATH}/sdX1"
    if [ -f "${TMP_PATH}/sdX1/etc/shadow" ]; then
      for U in $(cat "${TMP_PATH}/sdX1/etc/shadow" | awk -F ':' '{if ($2 != "*" && $2 != "!!") {print $1;}}'); do
        grep -q "status=on" "${TMP_PATH}/sdX1/usr/syno/etc/packages/SecureSignIn/preference/${U}/method.config" 2>/dev/nulll
        [ $? -eq 0 ] && SS="SecureSignIn" || SS="            "
        printf "\"%-36s %-16s\"\n" "${U}" "${SS}" >>"${TMP_PATH}/menu"
      done
    fi
    umount "${I}"
    [ -f "${TMP_PATH}/menu" ] && break
  done
  rm -rf "${TMP_PATH}/sdX1"
  if [ ! -f "${TMP_PATH}/menu" ]; then
    dialog --backtitle "$(backtitle)" --colors --title "Reset DSM Password" \
      --msgbox "The installed Syno system not found in the currently inserted disks!" 0 0
    return
  fi
  dialog --backtitle "$(backtitle)" --colors --title "Reset DSM Password" \
    --no-items --menu "Choose a User" 0 0 0  --file "${TMP_PATH}/menu" \
    2>${TMP_PATH}/resp
  [ $? -ne 0 ] && return
  USER="$(cat "${TMP_PATH}/resp" | awk '{print $1}')"
  [ -z "${USER}" ] && return
  while true; do
    dialog --backtitle "$(backtitle)" --colors --title "Reset DSM Password" \
      --inputbox "Type a new Password for User ${USER}" 0 70 \
      2>${TMP_PATH}/resp
    [ $? -ne 0 ] && break 2
    VALUE="$(<"${TMP_PATH}/resp")"
    [ -n "${VALUE}" ] && break
    dialog --backtitle "$(backtitle)" --colors --title "Reset DSM Password" \
      --msgbox "Invalid Password" 0 0
  done
  NEWPASSWD="$(python -c "from passlib.hash import sha512_crypt;pw=\"${VALUE}\";print(sha512_crypt.using(rounds=5000).hash(pw))")"
  (
    mkdir -p "${TMP_PATH}/sdX1"
    for I in $(ls /dev/sd*1 2>/dev/null | grep -v "${LOADER_DISK}1"); do
      mount "${I}" "${TMP_PATH}/sdX1"
      OLDPASSWD="$(cat "${TMP_PATH}/sdX1/etc/shadow" | grep "^${USER}:" | awk -F ':' '{print $2}')"
      [[ -n "${NEWPASSWD}" && -n "${OLDPASSWD}" ]] && sed -i "s|${OLDPASSWD}|${NEWPASSWD}|g" "${TMP_PATH}/sdX1/etc/shadow"
      sed -i "s|status=on|status=off|g" "${TMP_PATH}/sdX1/usr/syno/etc/packages/SecureSignIn/preference/${USER}/method.config" 2>/dev/null
      sync
      umount "${I}"
    done
    rm -rf "${TMP_PATH}/sdX1"
  ) 2>&1 | dialog --backtitle "$(backtitle)" --colors --title "Reset DSM Password" \
    --progressbox "Resetting ..." 20 100
  dialog --backtitle "$(backtitle)" --colors --title "Reset DSM Password" --aspect 18 \
    --msgbox "Password reset completed." 0 0
}

# Main function loop
function mainmenu() {
  
  readConfigMenu

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
      d) resetPassword; NEXT="r" ;;
      s) usbMenu;      NEXT="r" ;;
      a) sataMenu;     NEXT="r" ;;
      r) bootmenu ;;
      e) break ;;
    esac
  done

}    

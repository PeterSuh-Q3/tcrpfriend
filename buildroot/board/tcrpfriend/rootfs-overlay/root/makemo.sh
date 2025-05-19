echo "Convert po2mo begin"
DEST_PATH="./lang"
echo "${DEST_PATH}"
for P in $(ls ${DEST_PATH}/*/LC_MESSAGES/msg.po 2>/dev/null); do
  # Use msgfmt command to compile the .po file into a binary .mo file
  if [ -f ${P} ]; then 
    echo "msgfmt ${P} to ${P/.po/.mo}"
    msgfmt ${P} -o ${P/.po/.mo}
  fi  
done
echo "Convert po2mo end"

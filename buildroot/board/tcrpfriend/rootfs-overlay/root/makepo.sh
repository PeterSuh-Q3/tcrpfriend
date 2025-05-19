for L in `echo "en_US ko_KR ja_JP zh_CN ru_RU fr_FR de_DE es_ES it_IT pt_BR ar_EG hi_IN hu_HU id_ID tr_TR am_ET th_TH"`; do
	[ ! -d "lang/${L}/LC_MESSAGES" ] && mkdir -p lang/${L}/LC_MESSAGES
	echo "dante9000@gmail.com" | msginit -i lang/lang.pot -l ${L}.UTF-8 -o lang/${L}/LC_MESSAGES/msg.po
done

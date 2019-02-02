#!/bin/bash
#Encryption Script


#Sript Variables
the_file=$1
if [ "$NAUTILUS_SCRIPT_CURRENT_URI" == "x-nautilus-desktop:///" ]; then
	files_path=$HOME"/Desktop"
else
	files_path=`echo "$NAUTILUS_SCRIPT_CURRENT_URI" | sed -e 's/^file:\/\///; s/%20/\ /g'`
fi

enc_dec=`which gpg`
dialogbox="yes"
gui=`which zenity`

encrypt()
{
	$enc_dec -v --batch --default-recipient-self -e "$files_path/$the_file" &> /tmp/encdecresult
	result=`cat /tmp/encdecresult`
	rm -f /tmp/encdecresult
	result=`echo $result | tail -n 1 | cut -d '"' -f2 | sed 's/<//g;s/>//g'`

	# User feedback
	if [[ `echo "$result" | grep "failed:"` != "" ]]; then
		diaglog_box_title="Encryption Error"
		dialog_type="--error"
		feedback=$result
		feedback
	else
		diaglog_box_title="Encryption Sucessfull"
		dialog_type="--info"
		if [ "$dialogbox" == "yes" ]; then
			feedback="File Encrypted - $the_file was encrypted to $the_file.gpg using key: $result"
		fi
		feedback
	fi
}

# Feedback to user
feedback()
{
	$gui  --title "$diaglog_box_title" $dialog_type --text="$feedback"
	yesorno=$?
}

# Check for required tools
if [[ -x "$gui" && -x "$enc_dec" && -x "$secure_delete" ]]; then
	if [[ "$the_file" =~ "\.gpg$" || "$1" =~ "\.pgp$" ]]; then
		decrypt
	else
		encrypt
	fi
else
	errors
fi
exit 0f

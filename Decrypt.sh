#!/bin/bash
#Decryption Script


#Script Variables
the_file=$1
if [ "$NAUTILUS_SCRIPT_CURRENT_URI" == "x-nautilus-desktop:///" ]; then
	files_path=$HOME"/Desktop"
else
	files_path=`echo "$NAUTILUS_SCRIPT_CURRENT_URI" | sed -e 's/^file:\/\///; s/%20/\ /g'`
fi
delete_fuction=`which wipe`
dialogbox="yes"
gui=`which zenity`
enc_dec=`which gpg`

decrypt()
{
	#Asks User for GPG Password
	passwordgetter=`$gui  --title "GPG Decryption" --entry --hide-text \
	--text="Please Enter Password To Decrypt $the_file:" \
	| sed 's/^[ \t]*//;s/[ \t]*$//'` &> /dev/null
	if [ "$passwordgetter" == "" ]; then
		diaglog_box_title="Error."
		feedback="No password submitted. Error!"
		feedback
		exit 0
	fi
	echo $passwordgetter | $enc_dec -v --batch --passphrase-fd 0 --output /tmp/decrypted_output_file.dec \
	--decrypt "$files_path/$the_file" &> /tmp/encdecresult
	orig_filename=`cat /tmp/encdecresult | grep "original file name" | cut -d '=' -f2 | sed 's/'\''//g'`
	result=`cat /tmp/encdecresult | sed 's/<//g;s/>//g' | uniq`
	rm -f /tmp/encdecresult


	# feedback to user
	if [[ `echo "$result" | grep "failed:"` != "" ]]; then
		diaglog_box_title="Decryption Error!"
		dialog_type="--error"
		feedback=$result
		feedback
	else
		diaglog_box_title="Decryption Sucessful"
		dialog_type="--info"
		if [ "$dialogbox" == "yes" ]; then
			feedback="Success! - $the_file was decrypted to $orig_filename - $result"
		else
			feedback="Success! - Success! - $result"
		fi
		feedback
	fi
}

# Check for required tools
if [[ -x "$gui" && -x "$enc_dec" && -x "$delete_fuction" ]]; then
	if [[ "$the_file" =~ "\.gpg$" || "$1" =~ "\.pgp$" ]]; then
		decrypt
	else
		encrypt
	fi
else
	errors
fi
exit 0

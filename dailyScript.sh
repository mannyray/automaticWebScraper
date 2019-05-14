#!/bin/bash

cd /home/ec2-user/automaticWebScraper

#if scrape.py crashes then we can check for error in error_file.txt
/usr/bin/python scrape.py 2>error_file.txt

#if file is present and has size greater than zero
if [[ -s error_file.txt  ]]; then
	#if the file is not empty then we must alert the server that something is wrong
	curl -L "https://script.google.com/macros/s/UNIQUE_CODE/exec?subject=SERVER_ERROR&message=AWS_SCRIPT_HAS_CRASHED_NEED_TO_FIX_INFO"
else
	#backup and communicate that everything is OK
	git add .
	git commit -m "backup"
	git push
	curl -L "https://script.google.com/macros/s/UNIQUE_CODE/exec?subject=Working&message=Everything_is_working"
fi

rm error_file.txt


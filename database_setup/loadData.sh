#!/bin/bash

for file in data/*.txt
do
	#echo $file
		
	cat $file | while read temperature; do
		id=${file##*/}
		id=${id%.txt}
		arr=($(echo $id | awk -F '_' '{print $1, $2, $3, $4}' ))
		year=${arr[0]}
		month=${arr[1]}
		day=${arr[2]}
		hour=${arr[3]}
		echo "USE weather_data;INSERT INTO temperature_waterloo (YEAR,MONTH,DAY,HOUR,TEMPERATURE,ID) VALUES ($year, $month, $day, $hour, $temperature,'$id');"
	done | mysql -uroot -p$1

done

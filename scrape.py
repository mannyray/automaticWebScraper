#!/usr/bin/python

import requests
import json
import time
import os

response = requests.get("https://api.uwaterloo.ca/v2/weather/current.json")
if response.status_code == 200: #200 means everything is OK
	json_data = json.loads(response.text)
	current_temperature = json_data["data"]["temperature_current_c"]
	
	#record temperature in file with current date
        os.environ['TZ']='America/New_York'
	current_date_file = time.strftime("%Y_%m_%d_%H.txt")

	#files are stored in folder called data
	if not os.path.exists("data"):
		os.makedirs("data")
				
	f = open("data/"+current_date_file, "a+")
	f.write(str(current_temperature)+"\n")
	f.close()
else:
	raise RuntimeError("API request failed.") 



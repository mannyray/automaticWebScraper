# automaticWebScraper

Create some sort of web scraper and host in on AWS. For the purpose of this the target of scraping will be some sort of simple API.

## Developing simple API

First task is to scrape something. For the simplicity, we will scrap [weather data at University of Waterloo](https://github.com/uWaterloo/api-documentation/blob/master/v2/weather/current.md).

We will record the data everyday at `00:00`, `06:00`, `12:00` and `18:00` to be able to view the history of weather evolution. `srape.py` does this with the help of `dailyScript.sh`.

You can substitute this with anything you like of course.

## AWS EC2

We will launch this script on AWS EC2 instance.

1. Go to [Amazon](https://console.aws.amazon.com/ec2/v2/home).

2. Go to `Launch Instance`.

3. Select `Amazon Linux` and choose a `t2.micro` ~ Free tier eligible and `Launch`!`

4. `Create a new key pair` and `Launch Instance`

5. `Connect` to instance following appropriate instructions.

## Setting up your EC2

Once you are on your EC2 run (you would have your own repository):
```
sudo yum upgrade
sudo yum install git
git clone https://github.com/mannyray/automaticWebScraper.git
cd automaticWebScraper
```

You now want to set up a Cron Job (a time-based program) to scrape data on a regular (daily for us) basis.

```
crontab -e
```

and add:
```
CRON_TZ=America/New_York
0 0,6,12,18 * * * cd /home/ec2-user/automaticWebScraper; ./dailyScript.sh
```
This will take the weather at 6 hour periods. every day at Waterloo time zone (TZ). (Don't forget to make `dailyScript.sh` an executable by `chmod u+x dailyScript.sh`)

## Notifications

Since this scrape procedure is run on AWS then the user needs to know if something goes wrong. One way this can be done is by setting up a Google App Script:

 
1. Open up your Google Drive.

2. Create a new Google App Script called `AlertMessage`

3. Add the code to `code.gs`  
	```
	function doGet(request) {
		MailApp.sendEmail("your@gmail.com", request.parameter.subject, request.parameter.message);
		var result = {
			sent: 0 == 0
		};
		return ContentService.createTextOutput(JSON.stringify(result))
	}
	```
	Where `your@gmail.com` is your Google email account on which you made the Google App Script.

4. `Publish > Deploy as web app...`.

5. Who has access to the app:`Anyone, even anonymous`

6. Press `Deploy` and give the appropriate permissions.

7. Copy the full current web app URL: `https://script.google.com/macros/s/.../exec` (`...` is the Google generated portion)

8. On your computer terminal you can now send notifications via:  
	```
	curl -L "https://script.google.com/macros/s/.../exec?subject=TITLE&message=UNDERSCORE_FOR_SPACES_INSIDE_MESSAGE"
	```
	which will cause your Gmail inbox to get a new message.

We will add the `curl` line to the `script.sh` line.


## Backup

In addition to issuing warnings to self, backup is another important task. Since the data collected is fairly small then backup on github is OK. 


The following will allow you to run your github without entering your password. This will allow automatic backup.
1. Create ssh keys:  
	```
	cd ~
	ssh-keygen -t rsa
	```
	(just press enter all the way through)
2. Go to `github.com > settings` and copy the contents of your `~/.ssh/id_rsa.pub` into the field labeled 'Key'.
3. `git remote set-url origin git+ssh://git@github.com/username/reponame.git`

The backup code is located within `dailyScript.sh`.


## Setting up a server

We want to be able to check on our data once in a while and see it visually or be able to ask different queries. One way to do this is to setup a server that will only be accessible to us privately. This part is not necessary and not urgent to install since the only thing we care about at the end of the day is just the data. This portion can be done later.

Inside your server:

```
sudo yum update –y
sudo yum install -y httpd24 php56 mysql56-server php56-mysqlnd
sudo service httpd start
```

Once you have done this, you can view the default web page via: `ssh -L 3000:localhost:80 -i "amazon_scrape.pem" ec2-user@(...)something.compute.amazonaws.com`. In your local browser you can go to `http://localhost:3000/` to view the web page.


Run the following command to have server turn on every boot.
```
sudo chkconfig httpd on
```

Edit editing permisions:
```
sudo groupadd www
sudo usermod -a -G www ec2-user
sudo chown -R root:www /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} +
find /var/www -type f -exec sudo chmod 0664 {} +
```

Database creations:

http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-LAMP.html
```
sudo service mysqld start
sudo mysql_secure_installation
```
Default is no password so press enter and then press `Y` for a new password (and enter it) as well as `Y` for all other options.

Now we are going to work on populating server:
https://stackoverflow.com/questions/21033459/extracting-data-from-txt-files-to-import-in-a-mysql-database-with-php

1. First define your scheme:  
	For this case we will store: `(YEAR,MONTH,DAY,HOUR,TEMPERATURE,ID)`. Where `ID` will be data in string format: `YYYY_MM_DD_HH`
	Running `database_setup/create_table.sql` will create the table with that scheme with `mysql -u root -p < database_setup/create_table.sql` where your password would be the one defined earlier. 
2. Loading preexisting data. In the case that you end up setting up your database after saving some data in text files then you should run `database_setup/loadData.sh` in root directory of repository. 
3. Loading fresh data into database.

## Connecting to server privately

1. ssh to your server
2. `sudo vi /etc/ssh/sshd_config`. Find the line `#GatewayPorts no` and change the no to yes. Save and exit
3. Restart the daemon: `sudo /etc/init.d/sshd restart`
4. To connect to your server assuming you have a key: `ssh -i "ssh -L 3000:localhost:80 -i "yourkey.pem" ec2-user@ec2-(...)something.compute.amazonaws.com`

More additional details can be found at [http://szonov.com/programming/2018/12/06/simple-scraper/](http://szonov.com/programming/2018/12/06/simple-scraper/)



## Watching out for other errors

Don't want to you overuse your data or else you will be charged extra money.

Talk about inbound/outbound rules.

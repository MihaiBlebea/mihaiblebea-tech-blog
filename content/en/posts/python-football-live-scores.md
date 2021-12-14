---
title: "How to build a football live scores notification app with Python?"
date: 2021-12-07T14:47:11+01:00
description: Ever wanted to get the latest football scores on your laptop? I found a great API to get data in real-time. Follow me while I build this app from scratch.
draft: false
image: "images/python-football-live-scores/feature.jpg"
tags: ["python", "rapidapi", "football"]
---

{{< featuredImage alt="featured image" >}}

If you are like me, you must spend a lot of time coding...

I would like to spend more time watching sports or going outside to play football. But we are developers and that keeps us busy during the weekends.

But you don't have to choose one or the other. Now you can enjoy both of them.

In this article, I will show you the steps necessary to build a real-time football score notification app.

This will most likely work better on Linux OS, but you can easily adapt this for Windows or macOS.

## What is the biggest problem we will have to overcome?

To be completely honest with you, this is not my first stab at building this, but I always found myself stuck when I tried to get the real-time football scores.

We have a couple of options to overcome this:

- scrape the live scores from Google

- follow a Twitter stream and get the scores in real-time

- use a [FREE API](https://bit.ly/3oEBIyl) that provides us the scores without any fuss

Hmmm, hard decisions... but let's go with the last option as it's the most convenient and easy to implement.

Why would we spend weeks trying to build a scraper? Or deal with the Google algorithm built to block us from scraping the results.

To solve this issue, just use this FREE API that I found on RapidAPI called [Football Live Score](https://bit.ly/3oEBIyl).

All you need to do is just [create a FREE account](https://bit.ly/3oEBIyl) and they will provide you with a token that you can use to access any API on their platform.

The Football Live Score API provides three endpoints at the moment, but if you read this in the "future" you may see more as this is a well-supported community.

They currently support:

- GET `/matches` which provides a list of matches for the day with live updates just keep in mind you will receive matches that are not in progress

- GET `/matches/updates` contains the same games but they are filtered by latest updates. We are going to use this one as it provides only the matches that changed scores from the last query, so we don't need to handle that complexity or store the matches on our side

- GET `/leagues` provides the matches for today but sorted by league

The platform in itself is very good as it allows you to test the API right on their website before including it in your application.

[Check it out here!](https://bit.ly/3oEBIyl)

## What programming language will we use?

My first choice would be Golang, but recently I've spent a lot of time playing around with Python and... WOW... it just works.

There are so many good libraries in Python that make it the best choice for a quick project like our football live scores notifier.

We should start by checking your local Python version, so just run this command in the terminal:

```bash
python3 --version

// Mine returns Python 3.10.0 and that is good for now
```
If your's have an older version, it would be better to update your Python to at least 3.9.0.

## Create the project structure

Let's start by creating our folder structure.

```
|-- football_updates
	|-- execute.sh
	|-- src
		|-- poll.py
		|-- installer.py
		|-- notify.py
		|-- last_update.py
	|-- assets
		|-- alarm.wav
		|-- icon.png
```
This is all that we need for now.

Let's get our hands dirty and start coding it.

To make sure we have all our dependencies for our project and not pollute the global scope, we will need to create a virtual environment for our script.

Navigate inside your main foot folder (in my case it's `/football_updates`) and run this:

```bash
python3 -m venv virtualenv
```
This will create a virtual env in a folder called `virtualenv`. Of course, you can change this by providing a different last param to the command above.

Now let's install our dependencies.

We will need:

- crontab // for interacting with crontab and making our lives a bit easier when installing the script
- notifypy // for triggering linux notifications
- requests
- python-dotenv // for managing the envs

To install all these just run:

```bash
source ./virtualenv/bin/activate && ./virtualenv/bin/pip3 install crontab notifypy requests python-dotenv && deactivate
```
Cool, now we should be all set to start building our script.

## Create the notifications script

This will mostly work for Linux and the Gnome distribution but there are some other options:

- send a notification on Telegram
- post an update on Twitter
- send an email or SMS

For simplicity, I will trigger the updates as a desktop notification.

Navigate to the `/src` folder and create a file called `notify.py` that should look like this:

*./src/notify.py*
```python
from notifypy import Notify
import pathlib

# Get the base path to our folder so we can trigger this from the crontab without path conflicts
FOLDER_PATH = pathlib.Path(__file__).parent.resolve()

# Lock down the path to our static resources
AUDIO_FILE = f"{FOLDER_PATH}/../assets/alarm.wav"
ICON_FILE = f"{FOLDER_PATH}/../assets/icon.png"

# Main method for our script
def trigger(title: str, body: str):
	notification = Notify()
	notification.title = title
	notification.message = body
	notification.application_name = "Football updates" # Change this to suit your needs
	notification.audio = AUDIO_FILE
	notification.icon = ICON_FILE
	notification.send()

# Add this to be able to trigger this as an executable script. Mainly for testing
if __name__ == "__main__":
	trigger("demo title", "demo body")
```
Oki, now it's time to test this.

You can simply run:

```bash
python3 ./src/notify.py
```
But you would get an error complaining that the notifypy module cannot be found in our dependencies. We were so close...

But don't worry, this is expected.

The issue is that we are trying to call our script using the default local python interpreter. But it doesn't know about our virtual environment dependencies and modules.

To make this work, we need to use the interpreter from the virtual env.

Let's create a simple `execute.sh` script in our root folder that will allow us to call any script with the virtual env interpreter.

*./execute.sh*
```bash
#!/bin/bash

export PYTHONDONTWRITEBYTECODE=1 # Add this to not create a __pycache__ folder
export PYTHONPATH="${PYTHONPATH}:${PWD}" # Add our path to the PYTHONPATH, you can skip this
eval "./virtualenv/bin/python3 src/${1}.py ${@:2}"
```
Notice the path we are using to call our Python interpreter `./virtualenv/bin/python3`. This is the one from the virtual env.

Next, we pass our file and the rest of the terminal arguments but omit the name of the file.

To test our notify script, we need to make our `execute.sh` script executable by doing:

```bash
chmod +x ./execute.sh
```
Now you can run this and get a demo notification:

```bash
./execute.sh notify
```

Did you get the notification? You should now see the popup.

Don't forget to add the `./assets/alarm.wav` and `./assets/icon.png` to make it look and sound like a real notification.

This step is completed, so let's move to the next one.

## Store the last request timestamp

If we use the default endpoint `/matches`, this will return all the live scores in real-time.

But we won't know which one was updated from our last request. If you build a website where the live scores are displayed, this will not be an issue. 

But for this project, we just want to get the matches that changed between our requests.

To do this, we will call `/matches/updates` and will provide the `last_update` query param that contains the timestamp of the last request.

Navigate in the `src` folder and create the `/last_update.py` file:

*./src/last_update.py*
```python
from pathlib import Path
from datetime import datetime

FOLDER_PATH = Path(__file__).parent.resolve()
FILE_PATH = f"{FOLDER_PATH}/../last_update.txt" # this is the path to the temp file

# This stores the last update, if none is provided, it will just use the current timestamp
def store_last_update(last_update: str = None):
	if last_update is None:
		last_update = get_current_timestamp()
	f = open(FILE_PATH, "w")
	f.write(last_update)
	f.close()

# This will return the last update as a string from the file
# If the file does not exist, it will just return the current timestamp
def get_last_update():
	if Path(FILE_PATH).is_file() == False:
		return get_current_timestamp()

	f = open(FILE_PATH, "r")
	return f.read().strip()

# Just an utility function to return the current timestamp in the same format everytime
def get_current_timestamp():
	return str(int(datetime.now().timestamp()))
```

## Creating the brains of the script

It's time to get down to business and write the brains of our script.

Just create a `./src/poll.py` file and add this:

*./src/poll.py*
```python
import requests
from notify import trigger # Notice this is our module, not the notifypy
import json
from dotenv import dotenv_values
from last_update import get_last_update, store_last_update

# Base url of our RapidAPI
BASE_URL = "https://football-live-scores3.p.rapidapi.com"

def main():
	# Get all the match updates from the API, loop over them and call the send_notification function on each
	[send_notification(match) for match in match_generator(get_matches)]

# Add your RapidAPI key to the headers
def get_headers() -> dict:
	return {
		"x-rapidapi-host": "football-live-scores3.p.rapidapi.com",
		"x-rapidapi-key": "<YOUR_RAPIDAPI_KEY>" # add your private token that you receive form RapidAPI
	}

# Get all the matches updates and deal with the status codes
def get_matches() -> list:
	last_update_ts = get_last_update()

	url = f"{BASE_URL}/matches/updates?last_update={last_update_ts}"
	res = requests.get(url,  headers=get_headers(), auth=get_auth())
	logging.info(f"Made request to url {url}")

	if res.status_code != 200:
		return []

	body = res.json()

	if "last_update_timestamp" not in body:
		# if the key is not in the response for some reason, just use the current timestamp
		store_last_update()
	else:
		store_last_update(body["last_update_timestamp"])

	if "data" not in body:
		return []

	return body["data"]

# Write a simple generator that accepts the source as a callable function to retrieve the matches
def match_generator(source) -> dict:
	for match in source():
		yield {
			"home_team": match["teams"][0],
			"away_team": match["teams"][1],
			"home_score": match["score"][0],
			"away_score": match["score"][1]
		}

# Call send_notifications with the match from the API and parse it to compose the notification
def send_notification(data: dict):
	home_team = data["home_team"]
	away_team = data["away_team"]
	home_score = data["home_score"]
	away_score = data["away_score"]
	logging.info(f"Found match update {home_team} {home_score}-{away_score} {away_team}")
	trigger(
		f"Update {home_team} - {away_team}",
		f"{home_team} {home_score}-{away_score} {away_team}"
	)

# Add this to be able to call the script from the crontab
if __name__ == "__main__":
	main()
```

You can now test the above by running:
```bash
./execute.sh poll
```

You may get none, one, or many notifications based on your current date and time. It all depends if there is any match in progress.

It's also up to the players to score a goal in the same time that you are testing this. 

Not much you can do about this...

Let's move to the next step and add the poll script to our crontab.

## Make our script easier to install on your laptop

To make our lives easier, let's encapsulate the logic of installing and removing the script in one single file.

Just create a `./src/install.py` and add this to it:

*./src/install.py*
```python
from crontab import CronTab
import getpass
import pathlib
import argparse

# Add a comment so you know what this does in the future. This will be added to the crontab entry
# Also it will allow us to find and remove the entry in the future.
COMMENT = "will run the football updates scraper"

def main(cron):
	iter = cron.find_comment(COMMENT)
	for job in iter:
		if job.comment == COMMENT:
			remove(cron)

	install(cron)

def install(cron):
	# Get the path to our root folder
	path = pathlib.Path(__file__).parent.resolve()
	# This is the command that we want to run ever 5 minutes to get updates from the API
	# You can alter this to get more frequent updates
	# Notice that we send the crontab logs to our root folder in the cron.log file
	job = cron.new(
		command=f"{path}/../virtualenv/bin/python3 {path}/poll.py >> {path}/../cron.log 2>&1",
		comment=COMMENT
	)
	job.minute.every(5)
	cron.write()

def remove(cron):
	cron.remove_all(comment=COMMENT)
	cron.write()

if __name__ == "__main__":
	# Use the argparse lib to easy pass a flag to our script
	# If we call the script without any arguments, it will create an entry in the crontab
	# if we call this will a -u flag, it will remove the entry from crontab
	parser = argparse.ArgumentParser(
		prog= "installer", 
		usage="%(prog)s [options]", 
		description="install the application",
	)

	parser.add_argument(
		"-u",
		"--uninstall",
		dest="uninstall",
		required=False, 
		default=False,
		action="store_true",
		help="uninstall the application",
	)

	args = parser.parse_args()

	cron = CronTab(user=getpass.getuser())
	# If the flag -u is passed to the script, it will uninstall the crontab entry
	if args.uninstall:
		remove(cron)
	else:
		main(cron)
```
You are all set now. 

To install the football updates notifier, just call this:

```bash
./execute.sh install
```

To easily remove it and stop the updates, just call:
```bash
./execute.sh install -u
```

Now all you need to do is wait for somebody to score a goal, and you will get a notification with the live score update.

If you want more information or just read the docs for the [Football Live Scores API](https://bit.ly/3oEBIyl) on RapidAPI just [click here](https://bit.ly/3oEBIyl).

If you want to see the full code, just download it from my Github repo: [MihaiBlebea/football_updates](https://github.com/MihaiBlebea/football_updates)
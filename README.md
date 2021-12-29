# NRK-dl
Automated Video and Subtitle Downloader for NRK TV and NRK Podcasts

To use this script you can either pass a link directly to the script like this:

. nrk-dl.sh https://tv.nrk.no/program/KOID25002518

or you can simply start the script like this:

. nrk-dl.sh

and it will ask you to input a link

if you do not have ffmpeg installed you can install it and paste in the path (if the path variable isn't set)

curl does not always manage to fetch any data, this is caused by a time out, the script will try and wait for 10 seconds, if it doesn't manage to get anything you can try launching the script again, or make sure that you're 1. in Norway, 2. passing in a valid link.

This is the error that will show up:

Expecting value: line 1 column 1 (char 0)


Lastly, you will get the option to either save with subtitles or without (if any are found), this script simply saves the subtitle in a different file so you can enjoy your videos with or without a subtitle :)

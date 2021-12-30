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


For Windows 10 and above Users

You can use use nrk-dl.py to download your videos.

How to use is:

python.exe nrk-dl.py

After that it will be basically the same as the shell script, currently it has less error detection, but feel free to implement your own checks.

################################################

How does it work?

First it will find the relevant part of the link, that is the unique video ID: xxxx12345678.
It will then gather all the information via the underlying nrk API (psapi.nrk.no) by performing a curl operation.
This returns lot of information about the video, including: Name, Links to the Video (served by different providers like Telenor), and links to the subtitles (usually hosted by nkr.no)

Once it has the needed information will curl or wget the subtitle file (.vtt video transscript text?).
And the real magic comes from ffmpeg!
It simply uses the link from the API has generously generated for us, and ask for the highest quality stream.
The script also passes some headers to try and register as a regular browser, to avoid getting flaged as a bot.
And hopefully starts downloading the video in parts, just like you would if you were streaming :)


Final words, it is not perfect, and can often hang on the ffmpeg part, as long as your in Norway and not trying to download multiple files you should be able to simply restart the script. I've had issues durring testing where I accidently started the stream in my browser and couldn't figure out why my script got stuck tring to download.

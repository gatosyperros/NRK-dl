# import only system from os
from os import system, name
import subprocess
import re


def clear():
    # for windows
    if name == 'nt':
        _ = system('cls')
    # for mac and linux(here, os.name is 'posix')
    else:
        _ = system('clear')


clear()
ID = input('Please enter a link:')
Check_URL = ID.find('nrk.no/program')
if Check_URL == "0":
    print('this script can only work for nrk.no links')
    exit()

NID = ID[-12:]
CMD = 'curl -m 5 -s https://psapi.nrk.no/playback/manifest/program'
print('Fetching data please wait...')
Curling = CMD+'/'+NID
proc = subprocess.Popen(Curling, stderr=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
out, err = proc.communicate()  # Read data from stdout and stderr
# Finding Video link
Video = [re.findall(r'url.*.format', str(out))]
Video = str(Video)[9:-13]
Video_c = Video.find(NID[-8:])
Check_Video = Video_c
if (Check_Video == -1):
    print("Failed to get Video, Try again later")
    exit()
Video_c = "Found "
# Find Video Title
Name = [re.findall(r'online/film/.*.springStreamContentType', str(out))]
Name = str(Name)[15:-42]
# Finding subtile link
Sub = [re.findall(r'webVtt.*.type', str(out))]
Sub = str(Sub)[12:-12]

# Checks if if cound any subtitles
Sub_c = Sub.find(NID[-8:])
Check_Sub = Sub_c
if (Check_Sub >= 0):
    Sub_c = "Found "
    Choise = "1"
else:
    Sub_c = "Couldn't find "
    Choise = "2"

print("")
print("#########################")
print("This is what it found:")
print("Title:"+Name)
print(Video_c+"Video!")
print(Sub_c+"Sub")
print("#########################")
print("")
print("1: Download Video and Subtitles")
print("2: Download Only Video")
print("3: Exit")

Choise = input('Please select the next action (default '+Choise+'): ') or Choise
print(Choise)
if (Choise == "1"):
    Sub_CMD = 'curl -Js '+Sub+" -o "+Name+'.vtt'
    subprocess.Popen(Sub_CMD)
    Video_CMD = 'ffmpeg -headers "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36" -headers "X-Forwarded-For: 13.14.15.16" -xerror -i '+Video+' -map 0:0 -map 0:1 -c:v libx264 -preset slow -crf 22 '+Name+'.mp4"'
    subprocess.Popen(Video_CMD)
elif (Choise == "2"):
    Video_CMD = 'ffmpeg -headers "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36" -headers "X-Forwarded-For: 13.14.15.16" -xerror -i '+Video+' -map 0:0 -map 0:1 -c:v libx264 -preset slow -crf 22 '+Name+'.mp4"'
    subprocess.Popen(Video_CMD)
elif (Choise == "3"):
    exit()
else:
    print("Please remove your cat from the keyboard")

#!/bin/bash
echo "This tool will attempt to extract a downloadable link from NRK"

clean_exit (){
#Clears variable
unset Check_ffmpeg
unset Check_Link
unset Check_FFP
unset LINK
unset ID
unset CMD
unset curling
unset Name
unset Sub_c
unset Video_c
unset Sub
unset Video
unset Choise
unset Check_txt
unset FFP
unset Status
unset Looping
}

Check_Status (){
if [ $Looping == 2 ]; then
        echo "###############################################"
        echo "Failed to fetch data twice,Last Reason: $Status"
        echo "###############################################"
        return
fi

if [ $Status == "28" ]; then
        echo "Operation timed out, trying again in 5 seconds..."
        sleep 5
        echo "Fetching data please wait...."
        $curling >nrk.info
        Status=$PIPESTATUS
        Looping=$(($Looping+1))
        Check_Status
fi
if [ $Status == "35" ]; then
        echo "SSL ERROR, trying again in 5 seconds..."
        sleep 5
        echo "Fetching data please wait...."
        $curling >nrk.info
        Status=$PIPESTATUS
        Looping=$(($Looping+1))
        Check_Status
fi
return
}

#check if ffmpeg is installed
Looping=0
Check_ffmpeg=$(ffmpeg -version | grep -c Copyright)
if [ $Check_ffmpeg == 0 ]; then
        echo "Please make sure ffmpeg is installed on the system"
        read -rp "Please Enter Path to ffmpeg: " -e FFP
        Check_ffmpeg=$($FFP -version | grep -c Copyright)
        if [ $Check_ffmpeg == 0 ]; then
                echo "couldn't find ffmpeg on the system... exiting"
                clean_exit
                return
                exit
        fi
else
        FFP="ffmpeg"
fi

#Pre check the variables skip asking if already passing
Check_Link=$(echo "$1" | grep -c nrk.no)
if [ $Check_Link == 0 ]; then
        read -rp "Please Enter Link From NRK: " -e LINK
else
        LINK=$1
fi
Check_Link=$(echo "$LINK" | grep -c nrk.no)
if [ $Check_Link == 0 ]; then
        echo "The script needs a link to function..."
        clean_exit
        return
        exit
fi
ID=$(echo "$LINK" | grep -o '............$')
CMD=$(echo 'curl -m 5 -s https://psapi.nrk.no/playback/manifest/program')
echo "Fetching data please wait...."
curling=$(echo "$CMD/$ID")
$curling >nrk.info
Status=$PIPESTATUS
Check_Status
Name=$(cat nrk.info | python -m json.tool  |grep -o "title.*.[a-z]" | cut -c 10-)
#Fetching Video Link
Check_Link=$(cat nrk.info | python -m json.tool  |grep  -c playlist)
if [ $Check_Link == 1 ]; then
        Video=$(cat nrk.info | python -m json.tool  |grep playlist | cut -c 25- | sed 's/..$//')
        Video_C="Found"
else
        echo "Couldn't find video try again or contact the developer(s)"
        clean_exit
        return
        exit
fi

#Fetching Subtitle link Link"
Check_Link=$(cat nrk.info | python -m json.tool  |grep  -c webVtt)
if [ $Check_Link == 1 ]; then
        Sub=$(cat nrk.info | python -m json.tool  |grep webVtt | cut -c 28- | sed 's/.$//')
        Sub_C="Found"
else
        Sub_C=$(echo "Couldn't find")
fi

echo ""
echo "#########################"
echo "This is what it found:"
echo "Title: $Name"
echo "$Video_C Video"
echo "$Sub_C Subtitles"
echo "#########################"
echo ""
echo "1: Download Video and Subtitles (default)"
echo "2: Download Only Video"
echo "3: Exit"

if [[ $Sub_C == "Found" ]]; then
        read -rp "Please select the next action: " -e -i 1 Choise
else
        read -rp "Please select the next action: " -e -i 2 Choise
fi
case $Choise in
        1)
                echo "Subtitles"
                wget $Sub -O $Name.vtt
                sleep 2
                echo "Video"
                $FFP -headers "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36" -headers "X-Forwarded-For: 13.14.15.16" -xerror -i "$Video" -map 0:0 -map 0:1 -c:v libx264 -preset slow -crf 22 "$Name.mp4"
                Check_txt=$(cat $Name.vtt | grep -c -e [a-z] -e [A-Z])
                echo "making sure subtext is not empty"
                echo "$Check_txt"
                if [[ $Check_txt == 0 ]]; then
                        echo "error with subtext, trying again with curl"
                        curl -m 10 -Js $Sub -o $Name.vtt
                fi
                Check_txt=$(cat $Name.vtt | grep -c -e [a-z] -e [A-Z])
                if [ $Check_txt == 0 ]; then
                        echo "############################################"
                        echo "          failed to get subtext           "
                        echo "       you can try again manually with:   "
                        echo "wget $Sub -O $Name.vtt"
                        echo "                or                        "
                        echo "curl -m 10 -Js $Sub -o $Name.vtt"
                        echo "############################################"
                fi
                echo "Done"
                clean_exit
                return
                exit
                ;;
        2)
                echo "Video"
                $FFP -headers "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36" -headers "X-Forwarded-For: 13.14.15.16" -xerror -i "$Video" -map 0:0 -map 0:1 -c:v libx264 -preset slow -crf 22 "$Name.mp4"
                echo "Status= $?"
                echo "Done"
                clean_exit
                return
                exit
                ;;
        3)
                echo "Exiting"
                clean_exit
                return
                exit
                ;;
esac
